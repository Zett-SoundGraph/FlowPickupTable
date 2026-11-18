import 'package:pickup_table/domain/repositories/device_repository.dart';
import 'package:injectable/injectable.dart';

/// Fires when FlowUpdater refreshed the device record (`device.changed`).
@injectable
class ObserveDeviceInfoChangedUseCase {
  const ObserveDeviceInfoChangedUseCase(this._repository);

  final DeviceRepository _repository;

  Stream<void> call() => _repository.deviceInfoChanges;
}
