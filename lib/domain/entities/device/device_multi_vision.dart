import 'package:pickup_table/domain/enums/device_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_multi_vision.freezed.dart';

/// The device's place in a multi-vision wall.
@freezed
abstract class DeviceMultiVision with _$DeviceMultiVision {
  const factory DeviceMultiVision({
    @Default(DeviceRole.none) DeviceRole role,
    @Default('') String leaderIp,
    @Default(<String>[]) List<String> followers,
  }) = _DeviceMultiVision;
}
