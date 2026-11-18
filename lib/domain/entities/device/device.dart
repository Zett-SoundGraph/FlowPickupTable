import 'package:pickup_table/domain/entities/device/device_configuration.dart';
import 'package:pickup_table/domain/entities/device/device_external_storage_config.dart';
import 'package:pickup_table/domain/entities/device/device_multi_vision.dart';
import 'package:pickup_table/domain/entities/device/device_settings.dart';
import 'package:pickup_table/domain/entities/device/device_store_tag.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';

/// The device record FlowManager holds. Mirrors FlowUpdater's `Device`.
@freezed
abstract class Device with _$Device {
  const factory Device({
    @Default('') String deviceId,
    @Default('') String deviceName,
    @Default('') String brandId,
    @Default('') String brandName,
    @Default('') String projectId,
    @Default('') String projectName,
    @Default('') String storeId,
    @Default('') String storeName,
    @Default('') String storeCode,
    @Default('') String resolution,
    @Default('') String ratio,
    @Default(-1) int deviceType,
    @Default('') String deviceTypeName,
    @Default(0) double resolutionWidth,
    @Default(0) double resolutionHeight,
    @Default(0) double activeAreaWidth,
    @Default(0) double activeAreaHeight,
    @Default(0) double outDimensionWidth,
    @Default(0) double outDimensionHeight,
    @Default(0) double outDimensionDepth,
    @Default(0) int timezone,
    @Default(0) int orderX,
    @Default(0) int orderY,
    @Default(<DeviceStoreTag>[]) List<DeviceStoreTag> storeTags,
    @Default(DeviceMultiVision()) DeviceMultiVision multiVision,
    @Default(DeviceConfiguration()) DeviceConfiguration configuration,
    @Default(false) bool allowEnvSwitch,

    /// Whether FlowManager holds this device. `false` means it is not
    /// registered yet: the record carries defaults, not the cloud's values.
    @Default(false) bool isRegistered,
    @Default(DeviceSettings()) DeviceSettings settings,
    @Default(DeviceExternalStorageConfig()) DeviceExternalStorageConfig storage,
  }) = _Device;
}
