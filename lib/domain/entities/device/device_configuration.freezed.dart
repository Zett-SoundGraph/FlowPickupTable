// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceConfiguration {
  bool get notification;
  DeviceConfigurationCloudService get cloudService;
  DeviceConfigurationMultiVision get multiVision;
  bool get autoUpdate;
  bool get rebootDevice;
  bool get soundDevice;

  /// UTC offset in hours.
  int get timezone;
  VideoPlayerLib get videoPlayerLib;
  String get group;
  bool get multiVisionDebugMode;

  /// The app the device runs: [FlowApp.unknown] until the device first
  /// reports one.
  FlowApp get flowApp;

  /// The app to install when the device has none.
  FlowApp get defaultFlowApp;

  /// `true` once the device confirmed [flowApp].
  bool get flowAppSynced;

  /// Create a copy of DeviceConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeviceConfigurationCopyWith<DeviceConfiguration> get copyWith =>
      _$DeviceConfigurationCopyWithImpl<DeviceConfiguration>(
          this as DeviceConfiguration, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeviceConfiguration &&
            (identical(other.notification, notification) ||
                other.notification == notification) &&
            (identical(other.cloudService, cloudService) ||
                other.cloudService == cloudService) &&
            (identical(other.multiVision, multiVision) ||
                other.multiVision == multiVision) &&
            (identical(other.autoUpdate, autoUpdate) ||
                other.autoUpdate == autoUpdate) &&
            (identical(other.rebootDevice, rebootDevice) ||
                other.rebootDevice == rebootDevice) &&
            (identical(other.soundDevice, soundDevice) ||
                other.soundDevice == soundDevice) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.videoPlayerLib, videoPlayerLib) ||
                other.videoPlayerLib == videoPlayerLib) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.multiVisionDebugMode, multiVisionDebugMode) ||
                other.multiVisionDebugMode == multiVisionDebugMode) &&
            (identical(other.flowApp, flowApp) || other.flowApp == flowApp) &&
            (identical(other.defaultFlowApp, defaultFlowApp) ||
                other.defaultFlowApp == defaultFlowApp) &&
            (identical(other.flowAppSynced, flowAppSynced) ||
                other.flowAppSynced == flowAppSynced));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      notification,
      cloudService,
      multiVision,
      autoUpdate,
      rebootDevice,
      soundDevice,
      timezone,
      videoPlayerLib,
      group,
      multiVisionDebugMode,
      flowApp,
      defaultFlowApp,
      flowAppSynced);

  @override
  String toString() {
    return 'DeviceConfiguration(notification: $notification, cloudService: $cloudService, multiVision: $multiVision, autoUpdate: $autoUpdate, rebootDevice: $rebootDevice, soundDevice: $soundDevice, timezone: $timezone, videoPlayerLib: $videoPlayerLib, group: $group, multiVisionDebugMode: $multiVisionDebugMode, flowApp: $flowApp, defaultFlowApp: $defaultFlowApp, flowAppSynced: $flowAppSynced)';
  }
}

/// @nodoc
abstract mixin class $DeviceConfigurationCopyWith<$Res> {
  factory $DeviceConfigurationCopyWith(
          DeviceConfiguration value, $Res Function(DeviceConfiguration) _then) =
      _$DeviceConfigurationCopyWithImpl;
  @useResult
  $Res call(
      {bool notification,
      DeviceConfigurationCloudService cloudService,
      DeviceConfigurationMultiVision multiVision,
      bool autoUpdate,
      bool rebootDevice,
      bool soundDevice,
      int timezone,
      VideoPlayerLib videoPlayerLib,
      String group,
      bool multiVisionDebugMode,
      FlowApp flowApp,
      FlowApp defaultFlowApp,
      bool flowAppSynced});

  $DeviceConfigurationCloudServiceCopyWith<$Res> get cloudService;
  $DeviceConfigurationMultiVisionCopyWith<$Res> get multiVision;
}

/// @nodoc
class _$DeviceConfigurationCopyWithImpl<$Res>
    implements $DeviceConfigurationCopyWith<$Res> {
  _$DeviceConfigurationCopyWithImpl(this._self, this._then);

  final DeviceConfiguration _self;
  final $Res Function(DeviceConfiguration) _then;

  /// Create a copy of DeviceConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notification = null,
    Object? cloudService = null,
    Object? multiVision = null,
    Object? autoUpdate = null,
    Object? rebootDevice = null,
    Object? soundDevice = null,
    Object? timezone = null,
    Object? videoPlayerLib = null,
    Object? group = null,
    Object? multiVisionDebugMode = null,
    Object? flowApp = null,
    Object? defaultFlowApp = null,
    Object? flowAppSynced = null,
  }) {
    return _then(_self.copyWith(
      notification: null == notification
          ? _self.notification
          : notification // ignore: cast_nullable_to_non_nullable
              as bool,
      cloudService: null == cloudService
          ? _self.cloudService
          : cloudService // ignore: cast_nullable_to_non_nullable
              as DeviceConfigurationCloudService,
      multiVision: null == multiVision
          ? _self.multiVision
          : multiVision // ignore: cast_nullable_to_non_nullable
              as DeviceConfigurationMultiVision,
      autoUpdate: null == autoUpdate
          ? _self.autoUpdate
          : autoUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      rebootDevice: null == rebootDevice
          ? _self.rebootDevice
          : rebootDevice // ignore: cast_nullable_to_non_nullable
              as bool,
      soundDevice: null == soundDevice
          ? _self.soundDevice
          : soundDevice // ignore: cast_nullable_to_non_nullable
              as bool,
      timezone: null == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as int,
      videoPlayerLib: null == videoPlayerLib
          ? _self.videoPlayerLib
          : videoPlayerLib // ignore: cast_nullable_to_non_nullable
              as VideoPlayerLib,
      group: null == group
          ? _self.group
          : group // ignore: cast_nullable_to_non_nullable
              as String,
      multiVisionDebugMode: null == multiVisionDebugMode
          ? _self.multiVisionDebugMode
          : multiVisionDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      flowApp: null == flowApp
          ? _self.flowApp
          : flowApp // ignore: cast_nullable_to_non_nullable
              as FlowApp,
      defaultFlowApp: null == defaultFlowApp
          ? _self.defaultFlowApp
          : defaultFlowApp // ignore: cast_nullable_to_non_nullable
              as FlowApp,
      flowAppSynced: null == flowAppSynced
          ? _self.flowAppSynced
          : flowAppSynced // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of DeviceConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceConfigurationCloudServiceCopyWith<$Res> get cloudService {
    return $DeviceConfigurationCloudServiceCopyWith<$Res>(_self.cloudService,
        (value) {
      return _then(_self.copyWith(cloudService: value));
    });
  }

  /// Create a copy of DeviceConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceConfigurationMultiVisionCopyWith<$Res> get multiVision {
    return $DeviceConfigurationMultiVisionCopyWith<$Res>(_self.multiVision,
        (value) {
      return _then(_self.copyWith(multiVision: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DeviceConfiguration].
extension DeviceConfigurationPatterns on DeviceConfiguration {
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
    TResult Function(_DeviceConfiguration value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceConfiguration() when $default != null:
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
    TResult Function(_DeviceConfiguration value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfiguration():
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
    TResult? Function(_DeviceConfiguration value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfiguration() when $default != null:
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
    TResult Function(
            bool notification,
            DeviceConfigurationCloudService cloudService,
            DeviceConfigurationMultiVision multiVision,
            bool autoUpdate,
            bool rebootDevice,
            bool soundDevice,
            int timezone,
            VideoPlayerLib videoPlayerLib,
            String group,
            bool multiVisionDebugMode,
            FlowApp flowApp,
            FlowApp defaultFlowApp,
            bool flowAppSynced)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceConfiguration() when $default != null:
        return $default(
            _that.notification,
            _that.cloudService,
            _that.multiVision,
            _that.autoUpdate,
            _that.rebootDevice,
            _that.soundDevice,
            _that.timezone,
            _that.videoPlayerLib,
            _that.group,
            _that.multiVisionDebugMode,
            _that.flowApp,
            _that.defaultFlowApp,
            _that.flowAppSynced);
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
    TResult Function(
            bool notification,
            DeviceConfigurationCloudService cloudService,
            DeviceConfigurationMultiVision multiVision,
            bool autoUpdate,
            bool rebootDevice,
            bool soundDevice,
            int timezone,
            VideoPlayerLib videoPlayerLib,
            String group,
            bool multiVisionDebugMode,
            FlowApp flowApp,
            FlowApp defaultFlowApp,
            bool flowAppSynced)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfiguration():
        return $default(
            _that.notification,
            _that.cloudService,
            _that.multiVision,
            _that.autoUpdate,
            _that.rebootDevice,
            _that.soundDevice,
            _that.timezone,
            _that.videoPlayerLib,
            _that.group,
            _that.multiVisionDebugMode,
            _that.flowApp,
            _that.defaultFlowApp,
            _that.flowAppSynced);
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
    TResult? Function(
            bool notification,
            DeviceConfigurationCloudService cloudService,
            DeviceConfigurationMultiVision multiVision,
            bool autoUpdate,
            bool rebootDevice,
            bool soundDevice,
            int timezone,
            VideoPlayerLib videoPlayerLib,
            String group,
            bool multiVisionDebugMode,
            FlowApp flowApp,
            FlowApp defaultFlowApp,
            bool flowAppSynced)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceConfiguration() when $default != null:
        return $default(
            _that.notification,
            _that.cloudService,
            _that.multiVision,
            _that.autoUpdate,
            _that.rebootDevice,
            _that.soundDevice,
            _that.timezone,
            _that.videoPlayerLib,
            _that.group,
            _that.multiVisionDebugMode,
            _that.flowApp,
            _that.defaultFlowApp,
            _that.flowAppSynced);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DeviceConfiguration extends DeviceConfiguration {
  const _DeviceConfiguration(
      {this.notification = false,
      this.cloudService = const DeviceConfigurationCloudService(),
      this.multiVision = const DeviceConfigurationMultiVision(),
      this.autoUpdate = false,
      this.rebootDevice = false,
      this.soundDevice = true,
      this.timezone = 9,
      this.videoPlayerLib = VideoPlayerLib.videoplayer,
      this.group = '',
      this.multiVisionDebugMode = false,
      this.flowApp = FlowApp.unknown,
      this.defaultFlowApp = FlowApp.unknown,
      this.flowAppSynced = false})
      : super._();

  @override
  @JsonKey()
  final bool notification;
  @override
  @JsonKey()
  final DeviceConfigurationCloudService cloudService;
  @override
  @JsonKey()
  final DeviceConfigurationMultiVision multiVision;
  @override
  @JsonKey()
  final bool autoUpdate;
  @override
  @JsonKey()
  final bool rebootDevice;
  @override
  @JsonKey()
  final bool soundDevice;

  /// UTC offset in hours.
  @override
  @JsonKey()
  final int timezone;
  @override
  @JsonKey()
  final VideoPlayerLib videoPlayerLib;
  @override
  @JsonKey()
  final String group;
  @override
  @JsonKey()
  final bool multiVisionDebugMode;

  /// The app the device runs: [FlowApp.unknown] until the device first
  /// reports one.
  @override
  @JsonKey()
  final FlowApp flowApp;

  /// The app to install when the device has none.
  @override
  @JsonKey()
  final FlowApp defaultFlowApp;

  /// `true` once the device confirmed [flowApp].
  @override
  @JsonKey()
  final bool flowAppSynced;

  /// Create a copy of DeviceConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeviceConfigurationCopyWith<_DeviceConfiguration> get copyWith =>
      __$DeviceConfigurationCopyWithImpl<_DeviceConfiguration>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeviceConfiguration &&
            (identical(other.notification, notification) ||
                other.notification == notification) &&
            (identical(other.cloudService, cloudService) ||
                other.cloudService == cloudService) &&
            (identical(other.multiVision, multiVision) ||
                other.multiVision == multiVision) &&
            (identical(other.autoUpdate, autoUpdate) ||
                other.autoUpdate == autoUpdate) &&
            (identical(other.rebootDevice, rebootDevice) ||
                other.rebootDevice == rebootDevice) &&
            (identical(other.soundDevice, soundDevice) ||
                other.soundDevice == soundDevice) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.videoPlayerLib, videoPlayerLib) ||
                other.videoPlayerLib == videoPlayerLib) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.multiVisionDebugMode, multiVisionDebugMode) ||
                other.multiVisionDebugMode == multiVisionDebugMode) &&
            (identical(other.flowApp, flowApp) || other.flowApp == flowApp) &&
            (identical(other.defaultFlowApp, defaultFlowApp) ||
                other.defaultFlowApp == defaultFlowApp) &&
            (identical(other.flowAppSynced, flowAppSynced) ||
                other.flowAppSynced == flowAppSynced));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      notification,
      cloudService,
      multiVision,
      autoUpdate,
      rebootDevice,
      soundDevice,
      timezone,
      videoPlayerLib,
      group,
      multiVisionDebugMode,
      flowApp,
      defaultFlowApp,
      flowAppSynced);

  @override
  String toString() {
    return 'DeviceConfiguration(notification: $notification, cloudService: $cloudService, multiVision: $multiVision, autoUpdate: $autoUpdate, rebootDevice: $rebootDevice, soundDevice: $soundDevice, timezone: $timezone, videoPlayerLib: $videoPlayerLib, group: $group, multiVisionDebugMode: $multiVisionDebugMode, flowApp: $flowApp, defaultFlowApp: $defaultFlowApp, flowAppSynced: $flowAppSynced)';
  }
}

/// @nodoc
abstract mixin class _$DeviceConfigurationCopyWith<$Res>
    implements $DeviceConfigurationCopyWith<$Res> {
  factory _$DeviceConfigurationCopyWith(_DeviceConfiguration value,
          $Res Function(_DeviceConfiguration) _then) =
      __$DeviceConfigurationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool notification,
      DeviceConfigurationCloudService cloudService,
      DeviceConfigurationMultiVision multiVision,
      bool autoUpdate,
      bool rebootDevice,
      bool soundDevice,
      int timezone,
      VideoPlayerLib videoPlayerLib,
      String group,
      bool multiVisionDebugMode,
      FlowApp flowApp,
      FlowApp defaultFlowApp,
      bool flowAppSynced});

  @override
  $DeviceConfigurationCloudServiceCopyWith<$Res> get cloudService;
  @override
  $DeviceConfigurationMultiVisionCopyWith<$Res> get multiVision;
}

/// @nodoc
class __$DeviceConfigurationCopyWithImpl<$Res>
    implements _$DeviceConfigurationCopyWith<$Res> {
  __$DeviceConfigurationCopyWithImpl(this._self, this._then);

  final _DeviceConfiguration _self;
  final $Res Function(_DeviceConfiguration) _then;

  /// Create a copy of DeviceConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? notification = null,
    Object? cloudService = null,
    Object? multiVision = null,
    Object? autoUpdate = null,
    Object? rebootDevice = null,
    Object? soundDevice = null,
    Object? timezone = null,
    Object? videoPlayerLib = null,
    Object? group = null,
    Object? multiVisionDebugMode = null,
    Object? flowApp = null,
    Object? defaultFlowApp = null,
    Object? flowAppSynced = null,
  }) {
    return _then(_DeviceConfiguration(
      notification: null == notification
          ? _self.notification
          : notification // ignore: cast_nullable_to_non_nullable
              as bool,
      cloudService: null == cloudService
          ? _self.cloudService
          : cloudService // ignore: cast_nullable_to_non_nullable
              as DeviceConfigurationCloudService,
      multiVision: null == multiVision
          ? _self.multiVision
          : multiVision // ignore: cast_nullable_to_non_nullable
              as DeviceConfigurationMultiVision,
      autoUpdate: null == autoUpdate
          ? _self.autoUpdate
          : autoUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      rebootDevice: null == rebootDevice
          ? _self.rebootDevice
          : rebootDevice // ignore: cast_nullable_to_non_nullable
              as bool,
      soundDevice: null == soundDevice
          ? _self.soundDevice
          : soundDevice // ignore: cast_nullable_to_non_nullable
              as bool,
      timezone: null == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as int,
      videoPlayerLib: null == videoPlayerLib
          ? _self.videoPlayerLib
          : videoPlayerLib // ignore: cast_nullable_to_non_nullable
              as VideoPlayerLib,
      group: null == group
          ? _self.group
          : group // ignore: cast_nullable_to_non_nullable
              as String,
      multiVisionDebugMode: null == multiVisionDebugMode
          ? _self.multiVisionDebugMode
          : multiVisionDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      flowApp: null == flowApp
          ? _self.flowApp
          : flowApp // ignore: cast_nullable_to_non_nullable
              as FlowApp,
      defaultFlowApp: null == defaultFlowApp
          ? _self.defaultFlowApp
          : defaultFlowApp // ignore: cast_nullable_to_non_nullable
              as FlowApp,
      flowAppSynced: null == flowAppSynced
          ? _self.flowAppSynced
          : flowAppSynced // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of DeviceConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceConfigurationCloudServiceCopyWith<$Res> get cloudService {
    return $DeviceConfigurationCloudServiceCopyWith<$Res>(_self.cloudService,
        (value) {
      return _then(_self.copyWith(cloudService: value));
    });
  }

  /// Create a copy of DeviceConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceConfigurationMultiVisionCopyWith<$Res> get multiVision {
    return $DeviceConfigurationMultiVisionCopyWith<$Res>(_self.multiVision,
        (value) {
      return _then(_self.copyWith(multiVision: value));
    });
  }
}

// dart format on
