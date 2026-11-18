import 'package:pickup_table/domain/entities/device/device.dart';
import 'package:pickup_table/domain/repositories/device_repository.dart';
import 'package:injectable/injectable.dart';

/// Reads the device record from FlowUpdater (`device.getInfo`). Throws when
/// FlowUpdater does not answer.
@injectable
class GetDeviceInfoUseCase {
  const GetDeviceInfoUseCase(this._repository);

  final DeviceRepository _repository;

  Future<Device> call() => _repository.getDeviceInfo();
}
