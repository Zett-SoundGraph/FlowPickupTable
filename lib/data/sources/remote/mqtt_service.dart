import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:pickup_table/core/constants/app_constants.dart';
import 'package:pickup_table/core/constants/local_subnet_resolver.dart';
import 'package:pickup_table/domain/entities/index.dart';
import 'package:pickup_table/data/sources/local/order_manager.dart';

// Publishes pickup-complete events and a periodic heartbeat to the local
// MQTT broker (Message Hub), plus everything kds/pickup table exchange
// about order-ready/calibration (ORDER_READY, START_CALIBRATION,
// VALIDATION_MODE, CALIB_EXIT) and the Raspberry Pi's ToF object data
// (beta/tof/objects/beta/tof/control) — fully replaced SocketClientService's
// WS handling, no dual-path.
class MqttService {
  MqttServerClient? _client;
  Timer? _heartbeatTimer;
  Timer? _retryTimer;
  // autoReconnect only takes over once a client has connected successfully
  // at least once — it never fires for a connect() call that fails outright
  // (e.g. broker/network not up yet), so a failed FIRST attempt would
  // otherwise never retry on its own. Most visible at boot: a race against
  // this device's own network stack coming up can lose once and then sit
  // disconnected forever without this.
  static const _retryInterval = Duration(seconds: 5);

  static const String _topicPickupComplete = 'beta/pickuptable/pickup';
  // 라즈베리파이(PiMqttManager)와 짝을 이루는 토픽 — beta/tof/objects는
  // Pi가 publish하는 물체 데이터, beta/tof/control은 Pi가 subscribe하는
  // set_ir/cal_restart/set_roi/rpi_reboot 명령 채널 (PiMqtt_Man.h와 이름을
  // 반드시 맞춰야 함)
  static const String _topicTofObjects = 'beta/tof/objects';
  static const String _topicTofControl = 'beta/tof/control';
  // kds → pickup table: ORDER_READY(주문 완료 알림)/START_CALIBRATION(캘리브레이션
  // 시작 지시)를 "type" 필드로 구분해서 같은 토픽으로 받음 — MqttDataSource.
  // publishOrderReady/publishStartCalibration과 짝을 이룸
  static const String _topicPickuptableCommand = 'beta/flowhub/pickuptable';
  // pickup table → kds: VALIDATION_MODE/CALIB_EXIT — MqttDataSource의
  // calibrationStatusStream과 짝을 이룸
  static const String _topicCalibrationStatus =
      'beta/pickuptable/calibration_status';
  // beta/flowhub/pickuptable에 ORDER_READY/START_CALIBRATION과 같은 채널을
  // 공유하는 3번째 type — FlowHub의 Pickup Table Theme 화면이 보냄.
  // MqttDataSource.publishPickupTableTheme/ResetPickupTableTheme와 짝을 이룸.
  // Customer scans their receipt's QR (currently tested by scanning a label
  // instead, since the receipt-printer QR isn't wired up yet) — payload
  // just needs an `orderNo` field; whichever station scans it is
  // responsible for extracting that from whatever it scanned (a receipt
  // QR will only ever contain the bare order number, but a label QR also
  // carries dispenser/pkey data the scanner must strip first).
  static const String _topicCustomerScan = 'beta/qr/customer';
  static const String _topicHeartbeat =
      'beta/system/heartbeat/${AppConstants.mqttDeviceId}';
  // Message Hub's online-timeout window sits between 6s (stable) and 9s
  // (flapping) — 5s keeps a safety margin under that threshold.
  static const Duration _heartbeatInterval = Duration(seconds: 5);

  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  final Function(String message)? onLog;
  final Function(String orderNo)? onCustomerScan;
  final Function(TofFrame frame)? onTofFrame;
  // beta/flowhub/pickuptable에서 온 ORDER_READY/START_CALIBRATION 처리 콜백
  final VoidCallback? onOrderReady;
  final Function(double height, String displayModel, double edgeMarginMm,
      double? displayWidthMm, double? displayHeightMm)? onCalibrationRequested;
  // See SET_PICKUP_TABLE_THEME's dispatch above — the raw {background,
  // style, dotStyle, backgroundImage, colorOverrides} JSON when a theme is
  // selected, or null on Reset.
  final Function(Map<String, dynamic>? themeJson)? onThemeChanged;
  // FlowHub's Pickup Table Theme screen's "Create/Clear Test Orders"
  // buttons — see CREATE_TEST_ORDERS/CLEAR_TEST_ORDERS dispatch below.
  final VoidCallback? onCreateTestOrders;
  final VoidCallback? onClearTestOrders;

  MqttService({
    this.onLog,
    this.onCustomerScan,
    this.onTofFrame,
    this.onOrderReady,
    this.onCalibrationRequested,
    this.onThemeChanged,
    this.onCreateTestOrders,
    this.onClearTestOrders,
  });

  Future<void> connect() async {
    // Guard against duplicate live connections under the same client ID
    // (would otherwise fight the broker for the same identity every reconnect).
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }
    _retryTimer?.cancel();
    _client?.disconnect();

    // Waits for this device's own subnet to be confirmed before ever
    // dialing out — a brand-new site (whose subnet doesn't match
    // AppConstants.mqttBrokerHost's currently-deployed-site fallback) would
    // otherwise always waste a doomed first attempt before self-correcting
    // on a later retry.
    await LocalSubnetResolver.ready;

    final client = MqttServerClient(
      AppConstants.mqttBrokerHost,
      AppConstants.mqttDeviceId,
    );
    client.port = AppConstants.mqttBrokerPort;
    client.keepAlivePeriod = 30;
    client.autoReconnect = true;
    client.logging(on: false);
    client.onConnected = () {
      isConnected.value = true;
      onLog?.call(
          'MQTT 브로커 연결됨 (${AppConstants.mqttBrokerHost}:${AppConstants.mqttBrokerPort})');
      _startHeartbeat();
    };
    client.onDisconnected = () {
      isConnected.value = false;
      onLog?.call('MQTT 브로커 연결 끊김 — 재연결 시도 중...');
    };

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(AppConstants.mqttDeviceId)
        .authenticateAs(AppConstants.mqttUsername, AppConstants.mqttPassword)
        .startClean();

    try {
      await client.connect();
    } catch (e) {
      onLog?.call('⚠️ MQTT 연결 실패: $e — ${_retryInterval.inSeconds}초 뒤 재시도');
      client.disconnect();
      _scheduleRetry();
      return;
    }

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      onLog?.call('⚠️ MQTT 연결 실패 — ${_retryInterval.inSeconds}초 뒤 재시도');
      client.disconnect();
      _scheduleRetry();
      return;
    }

    _client = client;

    client.subscribe(_topicCustomerScan, MqttQos.atLeastOnce);
    // 물체 데이터는 매 프레임 오는 고빈도/휘발성 데이터라 QoS 0 —
    // PiMqttManager의 publish 쪽 QoS(0)와 맞춤
    client.subscribe(_topicTofObjects, MqttQos.atMostOnce);
    client.subscribe(_topicPickuptableCommand, MqttQos.atLeastOnce);
    client.updates?.listen((events) {
      for (final event in events) {
        if (event.topic == _topicTofObjects) {
          final recMess = event.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message);
          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            onTofFrame?.call(TofFrame.fromJson(json));
          } catch (e) {
            onLog?.call('⚠️ $_topicTofObjects 파싱 실패: $e');
          }
          continue;
        }
        if (event.topic == _topicPickuptableCommand) {
          final recMess = event.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message);
          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            final type = json['type']?.toString() ?? '';
            if (type == 'ORDER_READY') {
              final total = json['totalRequired'] ??
                  ((json['drinkCount'] ?? 0) as num) +
                      ((json['foodCount'] ?? 0) as num) +
                      ((json['bottleCount'] ?? 0) as num);
              OrderManager.addReadyOrder(
                json['orderNo'].toString(),
                json['menuName'] ?? '',
                json['nickname'] ?? '',
                json['drinkCount'] ?? 0,
                json['foodCount'] ?? 0,
                json['bottleCount'] ?? 0,
                total is int ? total : (total as num).toInt(),
                json['lang'] ?? '',
              );
              onLog?.call('📥 ORDER_READY 수신: ${json['orderNo']}');
              onOrderReady?.call();
            } else if (type == 'START_CALIBRATION') {
              onCalibrationRequested?.call(
                (json['height'] as num?)?.toDouble() ?? 1000.0,
                json['displayModel']?.toString() ?? 'AIO_550A',
                (json['edgeMarginMm'] as num?)?.toDouble() ?? 40.0,
                (json['displayWidthMm'] as num?)?.toDouble(),
                (json['displayHeightMm'] as num?)?.toDouble(),
              );
            } else if (type == 'SET_PICKUP_TABLE_THEME') {
              // FlowHub's Pickup Table Theme screen. No `theme` name field
              // at all (only ever this one design), so `background`
              // absent/null is what signals Reset (back to the original,
              // unthemed circle-based rendering — see
              // PickupTableState.themeOverride).
              final background = json['background']?.toString();
              onThemeChanged?.call(background == null || background.isEmpty ? null : json);
            } else if (type == 'CREATE_TEST_ORDERS') {
              onCreateTestOrders?.call();
            } else if (type == 'CLEAR_TEST_ORDERS') {
              onClearTestOrders?.call();
            } else {
              onLog?.call('⚠️ $_topicPickuptableCommand: 알 수 없는 type=$type');
            }
          } catch (e) {
            onLog?.call('⚠️ $_topicPickuptableCommand 파싱 실패: $e');
          }
          continue;
        }
        if (event.topic != _topicCustomerScan) continue;
        final recMess = event.payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          // barcode_scanner (scanner-customer-xx) publishes the scanned
          // string as-is under `raw`, not a pre-parsed `orderNo` — see
          // ScannerMqttService.sendBarcode. `orderNo` is kept as a fallback
          // key in case a future publisher (e.g. a receipt-QR reader) sends
          // an already-bare order number directly under that name instead.
          final raw = (json['raw'] ?? json['orderNo'])?.toString() ?? '';
          final orderNo = _extractOrderNo(raw);
          if (orderNo.isNotEmpty) {
            onLog?.call('📥 고객 QR 스캔 수신: $orderNo (raw: $raw)');
            onCustomerScan?.call(orderNo);
          } else if (raw.isNotEmpty) {
            onLog?.call('⚠️ $_topicCustomerScan: orderNo 추출 실패 (raw: $raw)');
          }
        } catch (e) {
          onLog?.call('⚠️ $_topicCustomerScan 파싱 실패: $e');
        }
      }
    });
  }

  // A scanned label is pipe-delimited — `dispenserData|orderNo.seq.totSeq,pkey:X`
  // (see order_label_widget.dart in KDS and KdsCubit._parseLabelScan, which
  // this mirrors) — so the bare order number is the part before the first
  // '.' in the segment right after '|'. Once the receipt-printer QR exists,
  // its payload will just be the bare order number with no '|' at all, so
  // that case is passed through unchanged.
  String _extractOrderNo(String raw) {
    final trimmed = raw.trim();
    if (!trimmed.contains('|')) return trimmed;

    final rightPart = trimmed.split('|').length > 1 ? trimmed.split('|')[1] : '';
    if (rightPart.isEmpty) return '';
    final fullOrderId = rightPart.split(',')[0];
    return fullOrderId.split('.')[0];
  }

  void sendPickupComplete(String orderNo) {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      onLog?.call('⚠️ 전송 실패: MQTT 미연결');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(jsonEncode({
      'orderNo': orderNo,
      'eventId':
          '${AppConstants.mqttDeviceId}-${DateTime.now().millisecondsSinceEpoch}',
    }));
    client.publishMessage(
      _topicPickupComplete,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    onLog?.call('📤 픽업완료 전송: $orderNo');
  }

  // 라즈베리파이(PiMqttManager)로 set_ir/cal_restart/set_roi 등 명령을 보냄 —
  // payload는 기존 SocketClientService.sendMessage와 완전히 같은 JSON
  // 형태를 그대로 재사용(예: {"event_type":"set_ir","ir_value":51}).
  // QoS 1 — PiMqttManager가 beta/tof/control을 QoS 1로 구독하고 있음
  void publishControlCommand(Map<String, dynamic> payload) {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      onLog?.call('⚠️ 전송 실패: MQTT 미연결 (control: ${payload['event_type']})');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(jsonEncode(payload));
    client.publishMessage(
      _topicTofControl,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    onLog?.call('📤 [MQTT] control 전송: ${payload['event_type']}');
  }

  // kds로 VALIDATION_MODE/CALIB_EXIT 캘리브레이션 상태를 알림 —
  // MqttDataSource.calibrationStatusStream과 짝을 이룸
  void publishCalibrationStatus(String type) {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      onLog?.call('⚠️ 전송 실패: MQTT 미연결 (calibration_status: $type)');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(jsonEncode({'type': type}));
    client.publishMessage(
      _topicCalibrationStatus,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    onLog?.call('📤 [MQTT] calibration_status 전송: $type');
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _publishHeartbeat();
    _heartbeatTimer =
        Timer.periodic(_heartbeatInterval, (_) => _publishHeartbeat());
  }

  void _publishHeartbeat() {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(jsonEncode({
      'status': 'online',
      'deviceName': AppConstants.mqttDeviceName,
      'deviceId': AppConstants.mqttDeviceId,
    }));
    client.publishMessage(
      _topicHeartbeat,
      MqttQos.atMostOnce,
      builder.payload!,
      retain: true,
    );
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryInterval, () => unawaited(connect()));
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _retryTimer?.cancel();
    _client?.disconnect();
    isConnected.dispose();
  }
}
