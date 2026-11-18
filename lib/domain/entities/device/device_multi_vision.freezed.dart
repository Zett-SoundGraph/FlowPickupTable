// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_multi_vision.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceMultiVision {
  DeviceRole get role;
  String get leaderIp;
  List<String> get followers;

  /// Create a copy of DeviceMultiVision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeviceMultiVisionCopyWith<DeviceMultiVision> get copyWith =>
      _$DeviceMultiVisionCopyWithImpl<DeviceMultiVision>(
          this as DeviceMultiVision, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeviceMultiVision &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.leaderIp, leaderIp) ||
                other.leaderIp == leaderIp) &&
            const DeepCollectionEquality().equals(other.followers, followers));
  }

  @override
  int get hashCode => Object.hash(runtimeType, role, leaderIp,
      const DeepCollectionEquality().hash(followers));

  @override
  String toString() {
    return 'DeviceMultiVision(role: $role, leaderIp: $leaderIp, followers: $followers)';
  }
}

/// @nodoc
abstract mixin class $DeviceMultiVisionCopyWith<$Res> {
  factory $DeviceMultiVisionCopyWith(
          DeviceMultiVision value, $Res Function(DeviceMultiVision) _then) =
      _$DeviceMultiVisionCopyWithImpl;
  @useResult
  $Res call({DeviceRole role, String leaderIp, List<String> followers});
}

/// @nodoc
class _$DeviceMultiVisionCopyWithImpl<$Res>
    implements $DeviceMultiVisionCopyWith<$Res> {
  _$DeviceMultiVisionCopyWithImpl(this._self, this._then);

  final DeviceMultiVision _self;
  final $Res Function(DeviceMultiVision) _then;

  /// Create a copy of DeviceMultiVision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? leaderIp = null,
    Object? followers = null,
  }) {
    return _then(_self.copyWith(
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as DeviceRole,
      leaderIp: null == leaderIp
          ? _self.leaderIp
          : leaderIp // ignore: cast_nullable_to_non_nullable
              as String,
      followers: null == followers
          ? _self.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [DeviceMultiVision].
extension DeviceMultiVisionPatterns on DeviceMultiVision {
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
    TResult Function(_DeviceMultiVision value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceMultiVision() when $default != null:
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
    TResult Function(_DeviceMultiVision value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceMultiVision():
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
    TResult? Function(_DeviceMultiVision value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceMultiVision() when $default != null:
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
    TResult Function(DeviceRole role, String leaderIp, List<String> followers)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceMultiVision() when $default != null:
        return $default(_that.role, _that.leaderIp, _that.followers);
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
    TResult Function(DeviceRole role, String leaderIp, List<String> followers)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceMultiVision():
        return $default(_that.role, _that.leaderIp, _that.followers);
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
    TResult? Function(DeviceRole role, String leaderIp, List<String> followers)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceMultiVision() when $default != null:
        return $default(_that.role, _that.leaderIp, _that.followers);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DeviceMultiVision implements DeviceMultiVision {
  const _DeviceMultiVision(
      {this.role = DeviceRole.none,
      this.leaderIp = '',
      final List<String> followers = const <String>[]})
      : _followers = followers;

  @override
  @JsonKey()
  final DeviceRole role;
  @override
  @JsonKey()
  final String leaderIp;
  final List<String> _followers;
  @override
  @JsonKey()
  List<String> get followers {
    if (_followers is EqualUnmodifiableListView) return _followers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followers);
  }

  /// Create a copy of DeviceMultiVision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeviceMultiVisionCopyWith<_DeviceMultiVision> get copyWith =>
      __$DeviceMultiVisionCopyWithImpl<_DeviceMultiVision>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeviceMultiVision &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.leaderIp, leaderIp) ||
                other.leaderIp == leaderIp) &&
            const DeepCollectionEquality()
                .equals(other._followers, _followers));
  }

  @override
  int get hashCode => Object.hash(runtimeType, role, leaderIp,
      const DeepCollectionEquality().hash(_followers));

  @override
  String toString() {
    return 'DeviceMultiVision(role: $role, leaderIp: $leaderIp, followers: $followers)';
  }
}

/// @nodoc
abstract mixin class _$DeviceMultiVisionCopyWith<$Res>
    implements $DeviceMultiVisionCopyWith<$Res> {
  factory _$DeviceMultiVisionCopyWith(
          _DeviceMultiVision value, $Res Function(_DeviceMultiVision) _then) =
      __$DeviceMultiVisionCopyWithImpl;
  @override
  @useResult
  $Res call({DeviceRole role, String leaderIp, List<String> followers});
}

/// @nodoc
class __$DeviceMultiVisionCopyWithImpl<$Res>
    implements _$DeviceMultiVisionCopyWith<$Res> {
  __$DeviceMultiVisionCopyWithImpl(this._self, this._then);

  final _DeviceMultiVision _self;
  final $Res Function(_DeviceMultiVision) _then;

  /// Create a copy of DeviceMultiVision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? role = null,
    Object? leaderIp = null,
    Object? followers = null,
  }) {
    return _then(_DeviceMultiVision(
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as DeviceRole,
      leaderIp: null == leaderIp
          ? _self.leaderIp
          : leaderIp // ignore: cast_nullable_to_non_nullable
              as String,
      followers: null == followers
          ? _self._followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
