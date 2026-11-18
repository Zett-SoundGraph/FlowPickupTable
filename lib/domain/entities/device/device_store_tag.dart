import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_store_tag.freezed.dart';

@freezed
abstract class DeviceStoreTag with _$DeviceStoreTag {
  const factory DeviceStoreTag({
    @Default('') String tag,
    @Default('') String startTime,
    @Default('') String endTime,
  }) = _DeviceStoreTag;
}
