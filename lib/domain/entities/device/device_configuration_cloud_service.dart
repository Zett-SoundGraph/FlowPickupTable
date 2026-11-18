import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_configuration_cloud_service.freezed.dart';

@freezed
abstract class DeviceConfigurationCloudService
    with _$DeviceConfigurationCloudService {
  const factory DeviceConfigurationCloudService({
    @Default(0) int cloudDownloader,
    @Default(false) bool isShowNotification,
  }) = _DeviceConfigurationCloudService;
}
