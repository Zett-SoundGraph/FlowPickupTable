// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Device {
  String get deviceId;
  String get deviceName;
  String get storeId;
  String get storeName;

  /// The store code (store_code) Flow uses to name the store.
  String get storeCode;

  /// Whether FlowManager holds this device. `false` means it is not
  /// registered yet: the record carries defaults, not the cloud's values.
  bool get isRegistered;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeviceCopyWith<Device> get copyWith =>
      _$DeviceCopyWithImpl<Device>(this as Device, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Device &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.storeCode, storeCode) ||
                other.storeCode == storeCode) &&
            (identical(other.isRegistered, isRegistered) ||
                other.isRegistered == isRegistered));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, deviceName, storeId,
      storeName, storeCode, isRegistered);

  @override
  String toString() {
    return 'Device(deviceId: $deviceId, deviceName: $deviceName, storeId: $storeId, storeName: $storeName, storeCode: $storeCode, isRegistered: $isRegistered)';
  }
}

/// @nodoc
abstract mixin class $DeviceCopyWith<$Res> {
  factory $DeviceCopyWith(Device value, $Res Function(Device) _then) =
      _$DeviceCopyWithImpl;
  @useResult
  $Res call(
      {String deviceId,
      String deviceName,
      String storeId,
      String storeName,
      String storeCode,
      bool isRegistered});
}

/// @nodoc
class _$DeviceCopyWithImpl<$Res> implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._self, this._then);

  final Device _self;
  final $Res Function(Device) _then;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? deviceName = null,
    Object? storeId = null,
    Object? storeName = null,
    Object? storeCode = null,
    Object? isRegistered = null,
  }) {
    return _then(_self.copyWith(
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _self.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _self.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      storeName: null == storeName
          ? _self.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      storeCode: null == storeCode
          ? _self.storeCode
          : storeCode // ignore: cast_nullable_to_non_nullable
              as String,
      isRegistered: null == isRegistered
          ? _self.isRegistered
          : isRegistered // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [Device].
extension DevicePatterns on Device {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Device value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Device() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Device value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Device():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Device value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Device() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String deviceId, String deviceName, String storeId,
            String storeName, String storeCode, bool isRegistered)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Device() when $default != null:
        return $default(_that.deviceId, _that.deviceName, _that.storeId,
            _that.storeName, _that.storeCode, _that.isRegistered);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String deviceId, String deviceName, String storeId,
            String storeName, String storeCode, bool isRegistered)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Device():
        return $default(_that.deviceId, _that.deviceName, _that.storeId,
            _that.storeName, _that.storeCode, _that.isRegistered);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String deviceId, String deviceName, String storeId,
            String storeName, String storeCode, bool isRegistered)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Device() when $default != null:
        return $default(_that.deviceId, _that.deviceName, _that.storeId,
            _that.storeName, _that.storeCode, _that.isRegistered);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Device implements Device {
  const _Device(
      {this.deviceId = '',
      this.deviceName = '',
      this.storeId = '',
      this.storeName = '',
      this.storeCode = '',
      this.isRegistered = false});

  @override
  @JsonKey()
  final String deviceId;
  @override
  @JsonKey()
  final String deviceName;
  @override
  @JsonKey()
  final String storeId;
  @override
  @JsonKey()
  final String storeName;

  /// The store code (store_code) Flow uses to name the store.
  @override
  @JsonKey()
  final String storeCode;

  /// Whether FlowManager holds this device. `false` means it is not
  /// registered yet: the record carries defaults, not the cloud's values.
  @override
  @JsonKey()
  final bool isRegistered;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeviceCopyWith<_Device> get copyWith =>
      __$DeviceCopyWithImpl<_Device>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Device &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.storeCode, storeCode) ||
                other.storeCode == storeCode) &&
            (identical(other.isRegistered, isRegistered) ||
                other.isRegistered == isRegistered));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, deviceName, storeId,
      storeName, storeCode, isRegistered);

  @override
  String toString() {
    return 'Device(deviceId: $deviceId, deviceName: $deviceName, storeId: $storeId, storeName: $storeName, storeCode: $storeCode, isRegistered: $isRegistered)';
  }
}

/// @nodoc
abstract mixin class _$DeviceCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$DeviceCopyWith(_Device value, $Res Function(_Device) _then) =
      __$DeviceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String deviceId,
      String deviceName,
      String storeId,
      String storeName,
      String storeCode,
      bool isRegistered});
}

/// @nodoc
class __$DeviceCopyWithImpl<$Res> implements _$DeviceCopyWith<$Res> {
  __$DeviceCopyWithImpl(this._self, this._then);

  final _Device _self;
  final $Res Function(_Device) _then;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? deviceId = null,
    Object? deviceName = null,
    Object? storeId = null,
    Object? storeName = null,
    Object? storeCode = null,
    Object? isRegistered = null,
  }) {
    return _then(_Device(
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _self.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _self.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      storeName: null == storeName
          ? _self.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      storeCode: null == storeCode
          ? _self.storeCode
          : storeCode // ignore: cast_nullable_to_non_nullable
              as String,
      isRegistered: null == isRegistered
          ? _self.isRegistered
          : isRegistered // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
