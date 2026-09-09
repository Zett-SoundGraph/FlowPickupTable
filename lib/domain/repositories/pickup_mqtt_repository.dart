import 'package:pickup_table/domain/entities/index.dart';

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
  Stream<double> get calibrationRequestedStream;

  Future<void> connect();

  void sendPickupComplete(String orderNo);

  void publishControlCommand(Map<String, dynamic> payload);

  void publishCalibrationStatus(String type);

  void dispose();
}
