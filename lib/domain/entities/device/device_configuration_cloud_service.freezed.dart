// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_configuration_cloud_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceConfigurationCloudService {
  int get cloudDownloader;
  bool get isShowNotification;

  /// Create a copy of DeviceConfigurationCloudService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeviceConfigurationCloudServiceCopyWith<DeviceConfigurationCloudService>
      get copyWith => _$DeviceConfigurationCloudServiceCopyWithImpl<
              DeviceConfigurationCloudService>(
          this as DeviceConfigurationCloudService, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeviceConfigurationCloudService &&
            (identical(other.cloudDownloader, cloudDownloader) ||
                other.cloudDownloader == cloudDownloader) &&
            (identical(other.isShowNotification, isShowNotification) ||
                other.isShowNotification == isShowNotification));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, cloudDownloader, isShowNotification);

  @override
  String toString() {
    return 'DeviceConfigurationCloudService(cloudDownloader: $cloudDownloader, isShowNotification: $isShowNotification)';
  }
}

/// @nodoc
abstract mixin class $DeviceConfigurationCloudServiceCopyWith<$Res> {
  factory $DeviceConfigurationCloudServiceCopyWith(
          DeviceConfigurationCloudService value,
          $Res Function(DeviceConfigurationCloudService) _then) =
      _$DeviceConfigurationCloudServiceCopyWithImpl;
  @useResult
  $Res call({int cloudDownloader, bool isShowNotification});
}

/// @nodoc
class _$DeviceConfigurationCloudServiceCopyWithImpl<$Res>
    implements $DeviceConfigurationCloudServiceCopyWith<$Res> {
  _$DeviceConfigurationCloudServiceCopyWithImpl(this._self, this._then);

  final DeviceConfigurationCloudService _self;
  final $Res Function(DeviceConfigurationCloudService) _then;

  /// Create a copy of DeviceConfigurationCloudService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cloudDownloader = null,
    Object? isShowNotification = null,
  }) {
    return _then(_self.copyWith(
      cloudDownloader: null == cloudDownloader
          ? _self.cloudDownloader
          : cloudDownloader // ignore: cast_nullable_to_non_nullable
              as int,
      isShowNotification: null == isShowNotification
          ? _self.isShowNotification
          : isShowNotification // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [DeviceConfigurationCloudService].
extension DeviceConfigurationCloudServicePatterns
    on DeviceConfigurationCloudService {
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
    TResult Function(_DeviceConfigurationCloudService value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationCloudService() when $default != null:
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
    TResult Function(_DeviceConfigurationCloudService value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationCloudService():
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
    TResult? Function(_DeviceConfigurationCloudService value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationCloudService() when $default != null:
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
    TResult Function(int cloudDownloader, bool isShowNotification)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationCloudService() when $default != null:
        return $default(_that.cloudDownloader, _that.isShowNotification);
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
    TResult Function(int cloudDownloader, bool isShowNotification) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationCloudService():
        return $default(_that.cloudDownloader, _that.isShowNotification);
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
    TResult? Function(int cloudDownloader, bool isShowNotification)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationCloudService() when $default != null:
        return $default(_that.cloudDownloader, _that.isShowNotification);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DeviceConfigurationCloudService
    implements DeviceConfigurationCloudService {
  const _DeviceConfigurationCloudService(
      {this.cloudDownloader = 0, this.isShowNotification = false});

  @override
  @JsonKey()
  final int cloudDownloader;
  @override
  @JsonKey()
  final bool isShowNotification;

  /// Create a copy of DeviceConfigurationCloudService
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeviceConfigurationCloudServiceCopyWith<_DeviceConfigurationCloudService>
      get copyWith => __$DeviceConfigurationCloudServiceCopyWithImpl<
          _DeviceConfigurationCloudService>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeviceConfigurationCloudService &&
            (identical(other.cloudDownloader, cloudDownloader) ||
                other.cloudDownloader == cloudDownloader) &&
            (identical(other.isShowNotification, isShowNotification) ||
                other.isShowNotification == isShowNotification));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, cloudDownloader, isShowNotification);

  @override
  String toString() {
    return 'DeviceConfigurationCloudService(cloudDownloader: $cloudDownloader, isShowNotification: $isShowNotification)';
  }
}

/// @nodoc
abstract mixin class _$DeviceConfigurationCloudServiceCopyWith<$Res>
    implements $DeviceConfigurationCloudServiceCopyWith<$Res> {
  factory _$DeviceConfigurationCloudServiceCopyWith(
          _DeviceConfigurationCloudService value,
          $Res Function(_DeviceConfigurationCloudService) _then) =
      __$DeviceConfigurationCloudServiceCopyWithImpl;
  @override
  @useResult
  $Res call({int cloudDownloader, bool isShowNotification});
}

/// @nodoc
class __$DeviceConfigurationCloudServiceCopyWithImpl<$Res>
    implements _$DeviceConfigurationCloudServiceCopyWith<$Res> {
  __$DeviceConfigurationCloudServiceCopyWithImpl(this._self, this._then);

  final _DeviceConfigurationCloudService _self;
  final $Res Function(_DeviceConfigurationCloudService) _then;

  /// Create a copy of DeviceConfigurationCloudService
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? cloudDownloader = null,
    Object? isShowNotification = null,
  }) {
    return _then(_DeviceConfigurationCloudService(
      cloudDownloader: null == cloudDownloader
          ? _self.cloudDownloader
          : cloudDownloader // ignore: cast_nullable_to_non_nullable
              as int,
      isShowNotification: null == isShowNotification
          ? _self.isShowNotification
          : isShowNotification // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
