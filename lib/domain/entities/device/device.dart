import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';

/// The device record from FlowUpdater, reduced to what this app uses.
/// Add a field here (and in the mapper) when the app starts to need it.
@freezed
abstract class Device with _$Device {
  const factory Device({
    @Default('') String deviceId,
    @Default('') String deviceName,
    @Default('') String storeId,
    @Default('') String storeName,

    /// The store code (store_code) Flow uses to name the store.
    @Default('') String storeCode,

    /// Whether FlowManager holds this device. `false` means it is not
    /// registered yet: the record carries defaults, not the cloud's values.
    @Default(false) bool isRegistered,
  }) = _Device;
}
