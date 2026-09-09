// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'env.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Env {
  String get apiUrl;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EnvCopyWith<Env> get copyWith =>
      _$EnvCopyWithImpl<Env>(this as Env, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Env &&
            (identical(other.apiUrl, apiUrl) || other.apiUrl == apiUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, apiUrl);

  @override
  String toString() {
    return 'Env(apiUrl: $apiUrl)';
  }
}

/// @nodoc
abstract mixin class $EnvCopyWith<$Res> {
  factory $EnvCopyWith(Env value, $Res Function(Env) _then) = _$EnvCopyWithImpl;
  @useResult
  $Res call({String apiUrl});
}

/// @nodoc
class _$EnvCopyWithImpl<$Res> implements $EnvCopyWith<$Res> {
  _$EnvCopyWithImpl(this._self, this._then);

  final Env _self;
  final $Res Function(Env) _then;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiUrl = null,
  }) {
    return _then(_self.copyWith(
      apiUrl: null == apiUrl
          ? _self.apiUrl
          : apiUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Env].
extension EnvPatterns on Env {
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
    TResult Function(_Env value)? $default, {
    TResult Function(_EnvDev value)? dev,
    TResult Function(_EnvProd value)? prod,
    TResult Function(_EnvStaging value)? staging,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Env() when $default != null:
        return $default(_that);
      case _EnvDev() when dev != null:
        return dev(_that);
      case _EnvProd() when prod != null:
        return prod(_that);
      case _EnvStaging() when staging != null:
        return staging(_that);
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
    TResult Function(_Env value) $default, {
    required TResult Function(_EnvDev value) dev,
    required TResult Function(_EnvProd value) prod,
    required TResult Function(_EnvStaging value) staging,
  }) {
    final _that = this;
    switch (_that) {
      case _Env():
        return $default(_that);
      case _EnvDev():
        return dev(_that);
      case _EnvProd():
        return prod(_that);
      case _EnvStaging():
        return staging(_that);
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
    TResult? Function(_Env value)? $default, {
    TResult? Function(_EnvDev value)? dev,
    TResult? Function(_EnvProd value)? prod,
    TResult? Function(_EnvStaging value)? staging,
  }) {
    final _that = this;
    switch (_that) {
      case _Env() when $default != null:
        return $default(_that);
      case _EnvDev() when dev != null:
        return dev(_that);
      case _EnvProd() when prod != null:
        return prod(_that);
      case _EnvStaging() when staging != null:
        return staging(_that);
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
    TResult Function(String apiUrl)? $default, {
    TResult Function(String apiUrl)? dev,
    TResult Function(String apiUrl)? prod,
    TResult Function(String apiUrl)? staging,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Env() when $default != null:
        return $default(_that.apiUrl);
      case _EnvDev() when dev != null:
        return dev(_that.apiUrl);
      case _EnvProd() when prod != null:
        return prod(_that.apiUrl);
      case _EnvStaging() when staging != null:
        return staging(_that.apiUrl);
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
    TResult Function(String apiUrl) $default, {
    required TResult Function(String apiUrl) dev,
    required TResult Function(String apiUrl) prod,
    required TResult Function(String apiUrl) staging,
  }) {
    final _that = this;
    switch (_that) {
      case _Env():
        return $default(_that.apiUrl);
      case _EnvDev():
        return dev(_that.apiUrl);
      case _EnvProd():
        return prod(_that.apiUrl);
      case _EnvStaging():
        return staging(_that.apiUrl);
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
    TResult? Function(String apiUrl)? $default, {
    TResult? Function(String apiUrl)? dev,
    TResult? Function(String apiUrl)? prod,
    TResult? Function(String apiUrl)? staging,
  }) {
    final _that = this;
    switch (_that) {
      case _Env() when $default != null:
        return $default(_that.apiUrl);
      case _EnvDev() when dev != null:
        return dev(_that.apiUrl);
      case _EnvProd() when prod != null:
        return prod(_that.apiUrl);
      case _EnvStaging() when staging != null:
        return staging(_that.apiUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Env extends Env {
  const _Env({this.apiUrl = ""}) : super._();

  @override
  @JsonKey()
  final String apiUrl;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EnvCopyWith<_Env> get copyWith =>
      __$EnvCopyWithImpl<_Env>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Env &&
            (identical(other.apiUrl, apiUrl) || other.apiUrl == apiUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, apiUrl);

  @override
  String toString() {
    return 'Env(apiUrl: $apiUrl)';
  }
}

/// @nodoc
abstract mixin class _$EnvCopyWith<$Res> implements $EnvCopyWith<$Res> {
  factory _$EnvCopyWith(_Env value, $Res Function(_Env) _then) =
      __$EnvCopyWithImpl;
  @override
  @useResult
  $Res call({String apiUrl});
}

/// @nodoc
class __$EnvCopyWithImpl<$Res> implements _$EnvCopyWith<$Res> {
  __$EnvCopyWithImpl(this._self, this._then);

  final _Env _self;
  final $Res Function(_Env) _then;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? apiUrl = null,
  }) {
    return _then(_Env(
      apiUrl: null == apiUrl
          ? _self.apiUrl
          : apiUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _EnvDev extends Env {
  _EnvDev({this.apiUrl = ""}) : super._();

  @override
  @JsonKey()
  final String apiUrl;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EnvDevCopyWith<_EnvDev> get copyWith =>
      __$EnvDevCopyWithImpl<_EnvDev>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EnvDev &&
            (identical(other.apiUrl, apiUrl) || other.apiUrl == apiUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, apiUrl);

  @override
  String toString() {
    return 'Env.dev(apiUrl: $apiUrl)';
  }
}

/// @nodoc
abstract mixin class _$EnvDevCopyWith<$Res> implements $EnvCopyWith<$Res> {
  factory _$EnvDevCopyWith(_EnvDev value, $Res Function(_EnvDev) _then) =
      __$EnvDevCopyWithImpl;
  @override
  @useResult
  $Res call({String apiUrl});
}

/// @nodoc
class __$EnvDevCopyWithImpl<$Res> implements _$EnvDevCopyWith<$Res> {
  __$EnvDevCopyWithImpl(this._self, this._then);

  final _EnvDev _self;
  final $Res Function(_EnvDev) _then;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? apiUrl = null,
  }) {
    return _then(_EnvDev(
      apiUrl: null == apiUrl
          ? _self.apiUrl
          : apiUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _EnvProd extends Env {
  _EnvProd({this.apiUrl = ""}) : super._();

  @override
  @JsonKey()
  final String apiUrl;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EnvProdCopyWith<_EnvProd> get copyWith =>
      __$EnvProdCopyWithImpl<_EnvProd>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EnvProd &&
            (identical(other.apiUrl, apiUrl) || other.apiUrl == apiUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, apiUrl);

  @override
  String toString() {
    return 'Env.prod(apiUrl: $apiUrl)';
  }
}

/// @nodoc
abstract mixin class _$EnvProdCopyWith<$Res> implements $EnvCopyWith<$Res> {
  factory _$EnvProdCopyWith(_EnvProd value, $Res Function(_EnvProd) _then) =
      __$EnvProdCopyWithImpl;
  @override
  @useResult
  $Res call({String apiUrl});
}

/// @nodoc
class __$EnvProdCopyWithImpl<$Res> implements _$EnvProdCopyWith<$Res> {
  __$EnvProdCopyWithImpl(this._self, this._then);

  final _EnvProd _self;
  final $Res Function(_EnvProd) _then;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? apiUrl = null,
  }) {
    return _then(_EnvProd(
      apiUrl: null == apiUrl
          ? _self.apiUrl
          : apiUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _EnvStaging extends Env {
  _EnvStaging({this.apiUrl = ""}) : super._();

  @override
  @JsonKey()
  final String apiUrl;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EnvStagingCopyWith<_EnvStaging> get copyWith =>
      __$EnvStagingCopyWithImpl<_EnvStaging>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EnvStaging &&
            (identical(other.apiUrl, apiUrl) || other.apiUrl == apiUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, apiUrl);

  @override
  String toString() {
    return 'Env.staging(apiUrl: $apiUrl)';
  }
}

/// @nodoc
abstract mixin class _$EnvStagingCopyWith<$Res> implements $EnvCopyWith<$Res> {
  factory _$EnvStagingCopyWith(
          _EnvStaging value, $Res Function(_EnvStaging) _then) =
      __$EnvStagingCopyWithImpl;
  @override
  @useResult
  $Res call({String apiUrl});
}

/// @nodoc
class __$EnvStagingCopyWithImpl<$Res> implements _$EnvStagingCopyWith<$Res> {
  __$EnvStagingCopyWithImpl(this._self, this._then);

  final _EnvStaging _self;
  final $Res Function(_EnvStaging) _then;

  /// Create a copy of Env
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? apiUrl = null,
  }) {
    return _then(_EnvStaging(
      apiUrl: null == apiUrl
          ? _self.apiUrl
          : apiUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
