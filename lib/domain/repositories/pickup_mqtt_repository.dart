import 'package:pickup_table/domain/entities/index.dart';

/// FlowHub's START_CALIBRATION payload: the sensor height plus the table's
/// physical geometry (display model + real edge margin, mm) needed to relay
/// a set_table_geometry command on to the ToF sensor before calibration
/// starts — see PickupTableCubit._handleCalibrationRequested.
/// displayWidthMm/displayHeightMm are only non-null when the display isn't
/// one of the 430A/500A/550A presets and FlowHub's calibration dialog sent
/// its real mm size directly instead of a model name.
typedef CalibrationRequest = ({
  double height,
  String displayModel,
  double edgeMarginMm,
  double? displayWidthMm,
  double? displayHeightMm,
});

/// Thin interface over the pickup table's MQTT traffic — connection to the
/// broker, inbound ToF/customer-scan/order-ready/calibration events, and
/// outbound pickup-complete/control/calibration-status commands. The
/// actual MQTT plumbing lives unchanged in
/// data/sources/remote/mqtt_service.dart's MqttService; this repository
/// just adapts its callback-style API into streams, matching the rest of
/// the fleet's data-source convention.
abstract interface class PickupMqttRepository {
  Stream<bool> get connectionStream;
  Stream<String> get logStream;
  Stream<String> get customerScanStream;
  Stream<TofFrame> get tofFrameStream;
  Stream<void> get orderReadyStream;
  Stream<CalibrationRequest> get calibrationRequestedStream;
  // Raw {background,style,dotStyle,backgroundImage,colorOverrides} JSON on
  // a theme selection, or null on Reset — see MqttService.onThemeChanged.
  Stream<Map<String, dynamic>?> get themeChangedStream;
  // FlowHub's Pickup Table Theme screen's "Create/Clear Test Orders"
  // buttons — see MqttService.onCreateTestOrders/onClearTestOrders.
  Stream<void> get createTestOrdersStream;
  Stream<void> get clearTestOrdersStream;

  Future<void> connect();

  void sendPickupComplete(String orderNo);

  void publishControlCommand(Map<String, dynamic> payload);

  void publishCalibrationStatus(String type);

  void dispose();
}
