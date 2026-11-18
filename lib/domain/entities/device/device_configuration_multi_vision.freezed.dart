// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_configuration_multi_vision.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceConfigurationMultiVision {
  bool get notUsed;
  bool get isMaster;
  String get group;

  /// Create a copy of DeviceConfigurationMultiVision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeviceConfigurationMultiVisionCopyWith<DeviceConfigurationMultiVision>
      get copyWith => _$DeviceConfigurationMultiVisionCopyWithImpl<
              DeviceConfigurationMultiVision>(
          this as DeviceConfigurationMultiVision, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeviceConfigurationMultiVision &&
            (identical(other.notUsed, notUsed) || other.notUsed == notUsed) &&
            (identical(other.isMaster, isMaster) ||
                other.isMaster == isMaster) &&
            (identical(other.group, group) || other.group == group));
  }

  @override
  int get hashCode => Object.hash(runtimeType, notUsed, isMaster, group);

  @override
  String toString() {
    return 'DeviceConfigurationMultiVision(notUsed: $notUsed, isMaster: $isMaster, group: $group)';
  }
}

/// @nodoc
abstract mixin class $DeviceConfigurationMultiVisionCopyWith<$Res> {
  factory $DeviceConfigurationMultiVisionCopyWith(
          DeviceConfigurationMultiVision value,
          $Res Function(DeviceConfigurationMultiVision) _then) =
      _$DeviceConfigurationMultiVisionCopyWithImpl;
  @useResult
  $Res call({bool notUsed, bool isMaster, String group});
}

/// @nodoc
class _$DeviceConfigurationMultiVisionCopyWithImpl<$Res>
    implements $DeviceConfigurationMultiVisionCopyWith<$Res> {
  _$DeviceConfigurationMultiVisionCopyWithImpl(this._self, this._then);

  final DeviceConfigurationMultiVision _self;
  final $Res Function(DeviceConfigurationMultiVision) _then;

  /// Create a copy of DeviceConfigurationMultiVision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notUsed = null,
    Object? isMaster = null,
    Object? group = null,
  }) {
    return _then(_self.copyWith(
      notUsed: null == notUsed
          ? _self.notUsed
          : notUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      isMaster: null == isMaster
          ? _self.isMaster
          : isMaster // ignore: cast_nullable_to_non_nullable
              as bool,
      group: null == group
          ? _self.group
          : group // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [DeviceConfigurationMultiVision].
extension DeviceConfigurationMultiVisionPatterns
    on DeviceConfigurationMultiVision {
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
    TResult Function(_DeviceConfigurationMultiVision value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationMultiVision() when $default != null:
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
    TResult Function(_DeviceConfigurationMultiVision value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationMultiVision():
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
    TResult? Function(_DeviceConfigurationMultiVision value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationMultiVision() when $default != null:
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
    TResult Function(bool notUsed, bool isMaster, String group)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationMultiVision() when $default != null:
        return $default(_that.notUsed, _that.isMaster, _that.group);
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
    TResult Function(bool notUsed, bool isMaster, String group) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationMultiVision():
        return $default(_that.notUsed, _that.isMaster, _that.group);
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
    TResult? Function(bool notUsed, bool isMaster, String group)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfigurationMultiVision() when $default != null:
        return $default(_that.notUsed, _that.isMaster, _that.group);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DeviceConfigurationMultiVision
    implements DeviceConfigurationMultiVision {
  const _DeviceConfigurationMultiVision(
      {this.notUsed = false, this.isMaster = false, this.group = ''});

  @override
  @JsonKey()
  final bool notUsed;
  @override
  @JsonKey()
  final bool isMaster;
  @override
  @JsonKey()
  final String group;

  /// Create a copy of DeviceConfigurationMultiVision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeviceConfigurationMultiVisionCopyWith<_DeviceConfigurationMultiVision>
      get copyWith => __$DeviceConfigurationMultiVisionCopyWithImpl<
          _DeviceConfigurationMultiVision>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeviceConfigurationMultiVision &&
            (identical(other.notUsed, notUsed) || other.notUsed == notUsed) &&
            (identical(other.isMaster, isMaster) ||
                other.isMaster == isMaster) &&
            (identical(other.group, group) || other.group == group));
  }

  @override
  int get hashCode => Object.hash(runtimeType, notUsed, isMaster, group);

  @override
  String toString() {
    return 'DeviceConfigurationMultiVision(notUsed: $notUsed, isMaster: $isMaster, group: $group)';
  }
}

/// @nodoc
abstract mixin class _$DeviceConfigurationMultiVisionCopyWith<$Res>
    implements $DeviceConfigurationMultiVisionCopyWith<$Res> {
  factory _$DeviceConfigurationMultiVisionCopyWith(
          _DeviceConfigurationMultiVision value,
          $Res Function(_DeviceConfigurationMultiVision) _then) =
      __$DeviceConfigurationMultiVisionCopyWithImpl;
  @override
  @useResult
  $Res call({bool notUsed, bool isMaster, String group});
}

/// @nodoc
class __$DeviceConfigurationMultiVisionCopyWithImpl<$Res>
    implements _$DeviceConfigurationMultiVisionCopyWith<$Res> {
  __$DeviceConfigurationMultiVisionCopyWithImpl(this._self, this._then);

  final _DeviceConfigurationMultiVision _self;
  final $Res Function(_DeviceConfigurationMultiVision) _then;

  /// Create a copy of DeviceConfigurationMultiVision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? notUsed = null,
    Object? isMaster = null,
    Object? group = null,
  }) {
    return _then(_DeviceConfigurationMultiVision(
      notUsed: null == notUsed
          ? _self.notUsed
          : notUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      isMaster: null == isMaster
          ? _self.isMaster
          : isMaster // ignore: cast_nullable_to_non_nullable
              as bool,
      group: null == group
          ? _self.group
          : group // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
