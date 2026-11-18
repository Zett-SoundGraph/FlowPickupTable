import 'package:flow_updater_sdk/flow_updater_sdk.dart' as sdk;
import 'package:pickup_table/data/mappers/device_info_mapper.dart';
import 'package:pickup_table/data/platform/flow_updater_service.dart';
import 'package:pickup_table/domain/entities/device/device.dart';
import 'package:pickup_table/domain/repositories/device_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DeviceRepository)
class DeviceRepositoryImpl implements DeviceRepository {
  const DeviceRepositoryImpl(this._flowUpdater);

  final FlowUpdaterService _flowUpdater;

  @override
  Stream<void> get deviceInfoChanges => _flowUpdater.deviceInfoChanges;

  @override
  Future<Device> getDeviceInfo() async {
    final sdk.IpcResult<sdk.DeviceInfo> result = await _flowUpdater
        .getDeviceInfo();
    final sdk.IpcErrorPayload? error = result.error;
    if (error != null) {
      throw Exception('${error.code.wire}: ${error.message}');
    }
    return result.value!.toDomain();
  }
}
