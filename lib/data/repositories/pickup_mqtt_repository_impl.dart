import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:pickup_table/data/sources/remote/mqtt_service.dart';
import 'package:pickup_table/domain/entities/index.dart';
import 'package:pickup_table/domain/repositories/pickup_mqtt_repository.dart';

/// Adapts [MqttService]'s callback-style construction into the
/// stream-based convention the rest of the fleet's data sources use — the
/// actual connect/publish/parse logic is unchanged, still owned entirely
/// by [MqttService].
@Singleton(as: PickupMqttRepository)
class PickupMqttRepositoryImpl implements PickupMqttRepository {
  late final MqttService _service;

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<String> _logController = StreamController<String>.broadcast();
  final StreamController<String> _customerScanController = StreamController<String>.broadcast();
  final StreamController<TofFrame> _tofFrameController = StreamController<TofFrame>.broadcast();
  final StreamController<void> _orderReadyController = StreamController<void>.broadcast();
  final StreamController<double> _calibrationRequestedController =
      StreamController<double>.broadcast();

  PickupMqttRepositoryImpl() {
    _service = MqttService(
      onLog: (msg) => _logController.add(msg),
      onCustomerScan: (orderNo) => _customerScanController.add(orderNo),
      onTofFrame: (frame) => _tofFrameController.add(frame),
      onOrderReady: () => _orderReadyController.add(null),
      onCalibrationRequested: (height) => _calibrationRequestedController.add(height),
    );
    _service.isConnected.addListener(_forwardConnectionState);
  }

  void _forwardConnectionState() => _connectionController.add(_service.isConnected.value);

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  Stream<String> get logStream => _logController.stream;

  @override
  Stream<String> get customerScanStream => _customerScanController.stream;

  @override
  Stream<TofFrame> get tofFrameStream => _tofFrameController.stream;

  @override
  Stream<void> get orderReadyStream => _orderReadyController.stream;

  @override
  Stream<double> get calibrationRequestedStream => _calibrationRequestedController.stream;

  @override
  Future<void> connect() => _service.connect();

  @override
  void sendPickupComplete(String orderNo) => _service.sendPickupComplete(orderNo);

  @override
  void publishControlCommand(Map<String, dynamic> payload) =>
      _service.publishControlCommand(payload);

  @override
  void publishCalibrationStatus(String type) => _service.publishCalibrationStatus(type);

  @override
  void dispose() {
    _service.isConnected.removeListener(_forwardConnectionState);
    _service.dispose();
    unawaited(_connectionController.close());
    unawaited(_logController.close());
    unawaited(_customerScanController.close());
    unawaited(_tofFrameController.close());
    unawaited(_orderReadyController.close());
    unawaited(_calibrationRequestedController.close());
  }
}
