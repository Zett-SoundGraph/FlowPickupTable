import 'package:pickup_table/domain/entities/device/device_configuration_cloud_service.dart';
import 'package:pickup_table/domain/entities/device/device_configuration_multi_vision.dart';
import 'package:pickup_table/domain/enums/flow_app.dart';
import 'package:pickup_table/domain/enums/video_player_lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_configuration.freezed.dart';

/// The device configuration FlowManager holds. Mirrors FlowUpdater's
/// `DeviceConfiguration`.
@freezed
abstract class DeviceConfiguration with _$DeviceConfiguration {
  const DeviceConfiguration._();

  const factory DeviceConfiguration({
    @Default(false) bool notification,
    @Default(DeviceConfigurationCloudService())
    DeviceConfigurationCloudService cloudService,
    @Default(DeviceConfigurationMultiVision())
    DeviceConfigurationMultiVision multiVision,
    @Default(false) bool autoUpdate,
    @Default(false) bool rebootDevice,
    @Default(true) bool soundDevice,

    /// UTC offset in hours.
    @Default(9) int timezone,
    @Default(VideoPlayerLib.videoplayer) VideoPlayerLib videoPlayerLib,
    @Default('') String group,
    @Default(false) bool multiVisionDebugMode,

    /// The app the device runs: [FlowApp.unknown] until the device first
    /// reports one.
    @Default(FlowApp.unknown) FlowApp flowApp,

    /// The app to install when the device has none.
    @Default(FlowApp.unknown) FlowApp defaultFlowApp,

    /// `true` once the device confirmed [flowApp].
    @Default(false) bool flowAppSynced,
  }) = _DeviceConfiguration;

  /// The app the device is meant to run: [flowApp], or [defaultFlowApp]
  /// before the device has reported one.
  FlowApp get targetFlowApp =>
      flowApp != FlowApp.unknown ? flowApp : defaultFlowApp;
}
