import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_external_storage_config.freezed.dart';

@freezed
abstract class DeviceExternalStorageConfig with _$DeviceExternalStorageConfig {
  const factory DeviceExternalStorageConfig({
    @Default(false) bool useExtStorage,
  }) = _DeviceExternalStorageConfig;
}
