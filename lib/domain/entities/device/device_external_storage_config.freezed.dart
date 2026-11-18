// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_external_storage_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceExternalStorageConfig {
  bool get useExtStorage;

  /// Create a copy of DeviceExternalStorageConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeviceExternalStorageConfigCopyWith<DeviceExternalStorageConfig>
      get copyWith => _$DeviceExternalStorageConfigCopyWithImpl<
              DeviceExternalStorageConfig>(
          this as DeviceExternalStorageConfig, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeviceExternalStorageConfig &&
            (identical(other.useExtStorage, useExtStorage) ||
                other.useExtStorage == useExtStorage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, useExtStorage);

  @override
  String toString() {
    return 'DeviceExternalStorageConfig(useExtStorage: $useExtStorage)';
  }
}

/// @nodoc
abstract mixin class $DeviceExternalStorageConfigCopyWith<$Res> {
  factory $DeviceExternalStorageConfigCopyWith(
          DeviceExternalStorageConfig value,
          $Res Function(DeviceExternalStorageConfig) _then) =
      _$DeviceExternalStorageConfigCopyWithImpl;
  @useResult
  $Res call({bool useExtStorage});
}

/// @nodoc
class _$DeviceExternalStorageConfigCopyWithImpl<$Res>
    implements $DeviceExternalStorageConfigCopyWith<$Res> {
  _$DeviceExternalStorageConfigCopyWithImpl(this._self, this._then);

  final DeviceExternalStorageConfig _self;
  final $Res Function(DeviceExternalStorageConfig) _then;

  /// Create a copy of DeviceExternalStorageConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? useExtStorage = null,
  }) {
    return _then(_self.copyWith(
      useExtStorage: null == useExtStorage
          ? _self.useExtStorage
          : useExtStorage // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [DeviceExternalStorageConfig].
extension DeviceExternalStorageConfigPatterns on DeviceExternalStorageConfig {
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
    TResult Function(_DeviceExternalStorageConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceExternalStorageConfig() when $default != null:
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
    TResult Function(_DeviceExternalStorageConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceExternalStorageConfig():
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
    TResult? Function(_DeviceExternalStorageConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceExternalStorageConfig() when $default != null:
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
    TResult Function(bool useExtStorage)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceExternalStorageConfig() when $default != null:
        return $default(_that.useExtStorage);
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
    TResult Function(bool useExtStorage) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceExternalStorageConfig():
        return $default(_that.useExtStorage);
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
    TResult? Function(bool useExtStorage)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceExternalStorageConfig() when $default != null:
        return $default(_that.useExtStorage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DeviceExternalStorageConfig implements DeviceExternalStorageConfig {
  const _DeviceExternalStorageConfig({this.useExtStorage = false});

  @override
  @JsonKey()
  final bool useExtStorage;

  /// Create a copy of DeviceExternalStorageConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeviceExternalStorageConfigCopyWith<_DeviceExternalStorageConfig>
      get copyWith => __$DeviceExternalStorageConfigCopyWithImpl<
          _DeviceExternalStorageConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeviceExternalStorageConfig &&
            (identical(other.useExtStorage, useExtStorage) ||
                other.useExtStorage == useExtStorage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, useExtStorage);

  @override
  String toString() {
    return 'DeviceExternalStorageConfig(useExtStorage: $useExtStorage)';
  }
}

/// @nodoc
abstract mixin class _$DeviceExternalStorageConfigCopyWith<$Res>
    implements $DeviceExternalStorageConfigCopyWith<$Res> {
  factory _$DeviceExternalStorageConfigCopyWith(
          _DeviceExternalStorageConfig value,
          $Res Function(_DeviceExternalStorageConfig) _then) =
      __$DeviceExternalStorageConfigCopyWithImpl;
  @override
  @useResult
  $Res call({bool useExtStorage});
}

/// @nodoc
class __$DeviceExternalStorageConfigCopyWithImpl<$Res>
    implements _$DeviceExternalStorageConfigCopyWith<$Res> {
  __$DeviceExternalStorageConfigCopyWithImpl(this._self, this._then);

  final _DeviceExternalStorageConfig _self;
  final $Res Function(_DeviceExternalStorageConfig) _then;

  /// Create a copy of DeviceExternalStorageConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? useExtStorage = null,
  }) {
    return _then(_DeviceExternalStorageConfig(
      useExtStorage: null == useExtStorage
          ? _self.useExtStorage
          : useExtStorage // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
