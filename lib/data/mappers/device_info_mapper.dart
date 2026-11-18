import 'package:flow_updater_sdk/flow_updater_sdk.dart' as sdk;
import 'package:pickup_table/domain/entities/device/device.dart';

/// `device.getInfo` replies with the whole device record; only the fields
/// this app uses are kept.
extension DeviceInfoMapper on sdk.DeviceInfo {
  /// Maps the SDK's device record to the domain [Device].
  Device toDomain() => Device(
    deviceId: deviceId,
    deviceName: deviceName,
    storeId: storeId,
    storeName: storeName,
    storeCode: storeCode,
    isRegistered: isRegistered,
  );
}
