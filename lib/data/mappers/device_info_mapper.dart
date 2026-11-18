import 'package:flow_updater_sdk/flow_updater_sdk.dart' as sdk;
import 'package:pickup_table/domain/entities/device/index.dart';
import 'package:pickup_table/domain/enums/index.dart';

/// `device.getInfo` replies with the device record itself.
extension DeviceInfoMapper on sdk.DeviceInfo {
  Device toDomain() => Device(
    deviceId: deviceId,
    deviceName: deviceName,
    brandId: brandId,
    brandName: brandName,
    projectId: projectId,
    projectName: projectName,
    storeId: storeId,
    storeName: storeName,
    storeCode: storeCode,
    resolution: resolution,
    ratio: ratio,
    deviceType: deviceType,
    deviceTypeName: deviceTypeName,
    resolutionWidth: resolutionWidth,
    resolutionHeight: resolutionHeight,
    activeAreaWidth: activeAreaWidth,
    activeAreaHeight: activeAreaHeight,
    outDimensionWidth: outDimensionWidth,
    outDimensionHeight: outDimensionHeight,
    outDimensionDepth: outDimensionDepth,
    timezone: timezone,
    orderX: orderX,
    orderY: orderY,
    storeTags: <DeviceStoreTag>[
      for (final sdk.DeviceStoreTag t in storeTags)
        DeviceStoreTag(tag: t.tag, startTime: t.startTime, endTime: t.endTime),
    ],
    multiVision: DeviceMultiVision(
      role: DeviceRole.fromValue(multiVision.role),
      leaderIp: multiVision.leaderIp,
      followers: multiVision.followers,
    ),
    configuration: configuration.toDomain(),
    allowEnvSwitch: allowEnvSwitch,
    isRegistered: isRegistered,
    settings: DeviceSettings(
      playMode: PlayScreenMode.fromValue(settings.playMode),
    ),
    storage: DeviceExternalStorageConfig(useExtStorage: storage.useExtStorage),
  );
}

extension DeviceConfigurationMapper on sdk.DeviceConfiguration {
  DeviceConfiguration toDomain() => DeviceConfiguration(
    notification: notification,
    cloudService: DeviceConfigurationCloudService(
      cloudDownloader: cloudService.cloudDownloader,
      isShowNotification: cloudService.isShowNotification,
    ),
    multiVision: DeviceConfigurationMultiVision(
      notUsed: multiVision.notUsed,
      isMaster: multiVision.isMaster,
      group: multiVision.group,
    ),
    autoUpdate: autoUpdate,
    rebootDevice: rebootDevice,
    soundDevice: soundDevice,
    timezone: timezone,
    videoPlayerLib: VideoPlayerLib.fromValue(videoPlayerLib),
    group: group,
    multiVisionDebugMode: multiVisionDebugMode,
    flowApp: FlowApp.fromValue(flowApp),
    defaultFlowApp: FlowApp.fromValue(defaultFlowApp),
    flowAppSynced: flowAppSynced,
  );
}
