import 'package:pickup_table/domain/enums/play_screen_mode.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_settings.freezed.dart';

@freezed
abstract class DeviceSettings with _$DeviceSettings {
  const factory DeviceSettings({
    @Default(PlayScreenMode.idle) PlayScreenMode playMode,
  }) = _DeviceSettings;
}
