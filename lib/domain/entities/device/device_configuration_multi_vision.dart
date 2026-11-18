import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_configuration_multi_vision.freezed.dart';

@freezed
abstract class DeviceConfigurationMultiVision
    with _$DeviceConfigurationMultiVision {
  const factory DeviceConfigurationMultiVision({
    @Default(false) bool notUsed,
    @Default(false) bool isMaster,
    @Default('') String group,
  }) = _DeviceConfigurationMultiVision;
}
