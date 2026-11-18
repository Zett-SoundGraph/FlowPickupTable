import 'package:pickup_table/domain/entities/device/device.dart';

abstract class DeviceRepository {
  /// Asks FlowUpdater for the device record (`device.getInfo`). Throws when
  /// FlowUpdater does not answer (not installed, not connected, timeout).
  Future<Device> getDeviceInfo();

  /// Fires when FlowUpdater refreshed the device record (`device.changed`):
  /// call [getDeviceInfo] again.
  Stream<void> get deviceInfoChanges;
}
