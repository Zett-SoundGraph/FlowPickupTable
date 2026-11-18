// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_store_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceStoreTag {
  String get tag;
  String get startTime;
  String get endTime;

  /// Create a copy of DeviceStoreTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeviceStoreTagCopyWith<DeviceStoreTag> get copyWith =>
      _$DeviceStoreTagCopyWithImpl<DeviceStoreTag>(
          this as DeviceStoreTag, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeviceStoreTag &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tag, startTime, endTime);

  @override
  String toString() {
    return 'DeviceStoreTag(tag: $tag, startTime: $startTime, endTime: $endTime)';
  }
}

/// @nodoc
abstract mixin class $DeviceStoreTagCopyWith<$Res> {
  factory $DeviceStoreTagCopyWith(
          DeviceStoreTag value, $Res Function(DeviceStoreTag) _then) =
      _$DeviceStoreTagCopyWithImpl;
  @useResult
  $Res call({String tag, String startTime, String endTime});
}

/// @nodoc
class _$DeviceStoreTagCopyWithImpl<$Res>
    implements $DeviceStoreTagCopyWith<$Res> {
  _$DeviceStoreTagCopyWithImpl(this._self, this._then);

  final DeviceStoreTag _self;
  final $Res Function(DeviceStoreTag) _then;

  /// Create a copy of DeviceStoreTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tag = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_self.copyWith(
      tag: null == tag
          ? _self.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [DeviceStoreTag].
extension DeviceStoreTagPatterns on DeviceStoreTag {
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
    TResult Function(_DeviceStoreTag value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceStoreTag() when $default != null:
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
    TResult Function(_DeviceStoreTag value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceStoreTag():
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
    TResult? Function(_DeviceStoreTag value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceStoreTag() when $default != null:
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
    TResult Function(String tag, String startTime, String endTime)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceStoreTag() when $default != null:
        return $default(_that.tag, _that.startTime, _that.endTime);
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
    TResult Function(String tag, String startTime, String endTime) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceStoreTag():
        return $default(_that.tag, _that.startTime, _that.endTime);
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
    TResult? Function(String tag, String startTime, String endTime)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceStoreTag() when $default != null:
        return $default(_that.tag, _that.startTime, _that.endTime);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DeviceStoreTag implements DeviceStoreTag {
  const _DeviceStoreTag(
      {this.tag = '', this.startTime = '', this.endTime = ''});

  @override
  @JsonKey()
  final String tag;
  @override
  @JsonKey()
  final String startTime;
  @override
  @JsonKey()
  final String endTime;

  /// Create a copy of DeviceStoreTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeviceStoreTagCopyWith<_DeviceStoreTag> get copyWith =>
      __$DeviceStoreTagCopyWithImpl<_DeviceStoreTag>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeviceStoreTag &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tag, startTime, endTime);

  @override
  String toString() {
    return 'DeviceStoreTag(tag: $tag, startTime: $startTime, endTime: $endTime)';
  }
}

/// @nodoc
abstract mixin class _$DeviceStoreTagCopyWith<$Res>
    implements $DeviceStoreTagCopyWith<$Res> {
  factory _$DeviceStoreTagCopyWith(
          _DeviceStoreTag value, $Res Function(_DeviceStoreTag) _then) =
      __$DeviceStoreTagCopyWithImpl;
  @override
  @useResult
  $Res call({String tag, String startTime, String endTime});
}

/// @nodoc
class __$DeviceStoreTagCopyWithImpl<$Res>
    implements _$DeviceStoreTagCopyWith<$Res> {
  __$DeviceStoreTagCopyWithImpl(this._self, this._then);

  final _DeviceStoreTag _self;
  final $Res Function(_DeviceStoreTag) _then;

  /// Create a copy of DeviceStoreTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? tag = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_DeviceStoreTag(
      tag: null == tag
          ? _self.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
