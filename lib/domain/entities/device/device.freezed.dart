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
  String get brandId;
  String get brandName;
  String get projectId;
  String get projectName;
  String get storeId;
  String get storeName;
  String get storeCode;
  String get resolution;
  String get ratio;
  int get deviceType;
  String get deviceTypeName;
  double get resolutionWidth;
  double get resolutionHeight;
  double get activeAreaWidth;
  double get activeAreaHeight;
  double get outDimensionWidth;
  double get outDimensionHeight;
  double get outDimensionDepth;
  int get timezone;
  int get orderX;
  int get orderY;
  List<DeviceStoreTag> get storeTags;
  DeviceMultiVision get multiVision;
  DeviceConfiguration get configuration;
  bool get allowEnvSwitch;

  /// Whether FlowManager holds this device. `false` means it is not
  /// registered yet: the record carries defaults, not the cloud's values.
  bool get isRegistered;
  DeviceSettings get settings;
  DeviceExternalStorageConfig get storage;

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
            (identical(other.brandId, brandId) || other.brandId == brandId) &&
            (identical(other.brandName, brandName) ||
                other.brandName == brandName) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.projectName, projectName) ||
                other.projectName == projectName) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.storeCode, storeCode) ||
                other.storeCode == storeCode) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.ratio, ratio) || other.ratio == ratio) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceTypeName, deviceTypeName) ||
                other.deviceTypeName == deviceTypeName) &&
            (identical(other.resolutionWidth, resolutionWidth) ||
                other.resolutionWidth == resolutionWidth) &&
            (identical(other.resolutionHeight, resolutionHeight) ||
                other.resolutionHeight == resolutionHeight) &&
            (identical(other.activeAreaWidth, activeAreaWidth) ||
                other.activeAreaWidth == activeAreaWidth) &&
            (identical(other.activeAreaHeight, activeAreaHeight) ||
                other.activeAreaHeight == activeAreaHeight) &&
            (identical(other.outDimensionWidth, outDimensionWidth) ||
                other.outDimensionWidth == outDimensionWidth) &&
            (identical(other.outDimensionHeight, outDimensionHeight) ||
                other.outDimensionHeight == outDimensionHeight) &&
            (identical(other.outDimensionDepth, outDimensionDepth) ||
                other.outDimensionDepth == outDimensionDepth) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.orderX, orderX) || other.orderX == orderX) &&
            (identical(other.orderY, orderY) || other.orderY == orderY) &&
            const DeepCollectionEquality().equals(other.storeTags, storeTags) &&
            (identical(other.multiVision, multiVision) ||
                other.multiVision == multiVision) &&
            (identical(other.configuration, configuration) ||
                other.configuration == configuration) &&
            (identical(other.allowEnvSwitch, allowEnvSwitch) ||
                other.allowEnvSwitch == allowEnvSwitch) &&
            (identical(other.isRegistered, isRegistered) ||
                other.isRegistered == isRegistered) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.storage, storage) || other.storage == storage));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        deviceId,
        deviceName,
        brandId,
        brandName,
        projectId,
        projectName,
        storeId,
        storeName,
        storeCode,
        resolution,
        ratio,
        deviceType,
        deviceTypeName,
        resolutionWidth,
        resolutionHeight,
        activeAreaWidth,
        activeAreaHeight,
        outDimensionWidth,
        outDimensionHeight,
        outDimensionDepth,
        timezone,
        orderX,
        orderY,
        const DeepCollectionEquality().hash(storeTags),
        multiVision,
        configuration,
        allowEnvSwitch,
        isRegistered,
        settings,
        storage
      ]);

  @override
  String toString() {
    return 'Device(deviceId: $deviceId, deviceName: $deviceName, brandId: $brandId, brandName: $brandName, projectId: $projectId, projectName: $projectName, storeId: $storeId, storeName: $storeName, storeCode: $storeCode, resolution: $resolution, ratio: $ratio, deviceType: $deviceType, deviceTypeName: $deviceTypeName, resolutionWidth: $resolutionWidth, resolutionHeight: $resolutionHeight, activeAreaWidth: $activeAreaWidth, activeAreaHeight: $activeAreaHeight, outDimensionWidth: $outDimensionWidth, outDimensionHeight: $outDimensionHeight, outDimensionDepth: $outDimensionDepth, timezone: $timezone, orderX: $orderX, orderY: $orderY, storeTags: $storeTags, multiVision: $multiVision, configuration: $configuration, allowEnvSwitch: $allowEnvSwitch, isRegistered: $isRegistered, settings: $settings, storage: $storage)';
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
      String brandId,
      String brandName,
      String projectId,
      String projectName,
      String storeId,
      String storeName,
      String storeCode,
      String resolution,
      String ratio,
      int deviceType,
      String deviceTypeName,
      double resolutionWidth,
      double resolutionHeight,
      double activeAreaWidth,
      double activeAreaHeight,
      double outDimensionWidth,
      double outDimensionHeight,
      double outDimensionDepth,
      int timezone,
      int orderX,
      int orderY,
      List<DeviceStoreTag> storeTags,
      DeviceMultiVision multiVision,
      DeviceConfiguration configuration,
      bool allowEnvSwitch,
      bool isRegistered,
      DeviceSettings settings,
      DeviceExternalStorageConfig storage});

  $DeviceMultiVisionCopyWith<$Res> get multiVision;
  $DeviceConfigurationCopyWith<$Res> get configuration;
  $DeviceSettingsCopyWith<$Res> get settings;
  $DeviceExternalStorageConfigCopyWith<$Res> get storage;
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
    Object? brandId = null,
    Object? brandName = null,
    Object? projectId = null,
    Object? projectName = null,
    Object? storeId = null,
    Object? storeName = null,
    Object? storeCode = null,
    Object? resolution = null,
    Object? ratio = null,
    Object? deviceType = null,
    Object? deviceTypeName = null,
    Object? resolutionWidth = null,
    Object? resolutionHeight = null,
    Object? activeAreaWidth = null,
    Object? activeAreaHeight = null,
    Object? outDimensionWidth = null,
    Object? outDimensionHeight = null,
    Object? outDimensionDepth = null,
    Object? timezone = null,
    Object? orderX = null,
    Object? orderY = null,
    Object? storeTags = null,
    Object? multiVision = null,
    Object? configuration = null,
    Object? allowEnvSwitch = null,
    Object? isRegistered = null,
    Object? settings = null,
    Object? storage = null,
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
      brandId: null == brandId
          ? _self.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: null == brandName
          ? _self.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _self.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      projectName: null == projectName
          ? _self.projectName
          : projectName // ignore: cast_nullable_to_non_nullable
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
      resolution: null == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String,
      ratio: null == ratio
          ? _self.ratio
          : ratio // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as int,
      deviceTypeName: null == deviceTypeName
          ? _self.deviceTypeName
          : deviceTypeName // ignore: cast_nullable_to_non_nullable
              as String,
      resolutionWidth: null == resolutionWidth
          ? _self.resolutionWidth
          : resolutionWidth // ignore: cast_nullable_to_non_nullable
              as double,
      resolutionHeight: null == resolutionHeight
          ? _self.resolutionHeight
          : resolutionHeight // ignore: cast_nullable_to_non_nullable
              as double,
      activeAreaWidth: null == activeAreaWidth
          ? _self.activeAreaWidth
          : activeAreaWidth // ignore: cast_nullable_to_non_nullable
              as double,
      activeAreaHeight: null == activeAreaHeight
          ? _self.activeAreaHeight
          : activeAreaHeight // ignore: cast_nullable_to_non_nullable
              as double,
      outDimensionWidth: null == outDimensionWidth
          ? _self.outDimensionWidth
          : outDimensionWidth // ignore: cast_nullable_to_non_nullable
              as double,
      outDimensionHeight: null == outDimensionHeight
          ? _self.outDimensionHeight
          : outDimensionHeight // ignore: cast_nullable_to_non_nullable
              as double,
      outDimensionDepth: null == outDimensionDepth
          ? _self.outDimensionDepth
          : outDimensionDepth // ignore: cast_nullable_to_non_nullable
              as double,
      timezone: null == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as int,
      orderX: null == orderX
          ? _self.orderX
          : orderX // ignore: cast_nullable_to_non_nullable
              as int,
      orderY: null == orderY
          ? _self.orderY
          : orderY // ignore: cast_nullable_to_non_nullable
              as int,
      storeTags: null == storeTags
          ? _self.storeTags
          : storeTags // ignore: cast_nullable_to_non_nullable
              as List<DeviceStoreTag>,
      multiVision: null == multiVision
          ? _self.multiVision
          : multiVision // ignore: cast_nullable_to_non_nullable
              as DeviceMultiVision,
      configuration: null == configuration
          ? _self.configuration
          : configuration // ignore: cast_nullable_to_non_nullable
              as DeviceConfiguration,
      allowEnvSwitch: null == allowEnvSwitch
          ? _self.allowEnvSwitch
          : allowEnvSwitch // ignore: cast_nullable_to_non_nullable
              as bool,
      isRegistered: null == isRegistered
          ? _self.isRegistered
          : isRegistered // ignore: cast_nullable_to_non_nullable
              as bool,
      settings: null == settings
          ? _self.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as DeviceSettings,
      storage: null == storage
          ? _self.storage
          : storage // ignore: cast_nullable_to_non_nullable
              as DeviceExternalStorageConfig,
    ));
  }

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceMultiVisionCopyWith<$Res> get multiVision {
    return $DeviceMultiVisionCopyWith<$Res>(_self.multiVision, (value) {
      return _then(_self.copyWith(multiVision: value));
    });
  }

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceConfigurationCopyWith<$Res> get configuration {
    return $DeviceConfigurationCopyWith<$Res>(_self.configuration, (value) {
      return _then(_self.copyWith(configuration: value));
    });
  }

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceSettingsCopyWith<$Res> get settings {
    return $DeviceSettingsCopyWith<$Res>(_self.settings, (value) {
      return _then(_self.copyWith(settings: value));
    });
  }

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceExternalStorageConfigCopyWith<$Res> get storage {
    return $DeviceExternalStorageConfigCopyWith<$Res>(_self.storage, (value) {
      return _then(_self.copyWith(storage: value));
    });
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
    TResult Function(
            String deviceId,
            String deviceName,
            String brandId,
            String brandName,
            String projectId,
            String projectName,
            String storeId,
            String storeName,
            String storeCode,
            String resolution,
            String ratio,
            int deviceType,
            String deviceTypeName,
            double resolutionWidth,
            double resolutionHeight,
            double activeAreaWidth,
            double activeAreaHeight,
            double outDimensionWidth,
            double outDimensionHeight,
            double outDimensionDepth,
            int timezone,
            int orderX,
            int orderY,
            List<DeviceStoreTag> storeTags,
            DeviceMultiVision multiVision,
            DeviceConfiguration configuration,
            bool allowEnvSwitch,
            bool isRegistered,
            DeviceSettings settings,
            DeviceExternalStorageConfig storage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Device() when $default != null:
        return $default(
            _that.deviceId,
            _that.deviceName,
            _that.brandId,
            _that.brandName,
            _that.projectId,
            _that.projectName,
            _that.storeId,
            _that.storeName,
            _that.storeCode,
            _that.resolution,
            _that.ratio,
            _that.deviceType,
            _that.deviceTypeName,
            _that.resolutionWidth,
            _that.resolutionHeight,
            _that.activeAreaWidth,
            _that.activeAreaHeight,
            _that.outDimensionWidth,
            _that.outDimensionHeight,
            _that.outDimensionDepth,
            _that.timezone,
            _that.orderX,
            _that.orderY,
            _that.storeTags,
            _that.multiVision,
            _that.configuration,
            _that.allowEnvSwitch,
            _that.isRegistered,
            _that.settings,
            _that.storage);
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
            String deviceId,
            String deviceName,
            String brandId,
            String brandName,
            String projectId,
            String projectName,
            String storeId,
            String storeName,
            String storeCode,
            String resolution,
            String ratio,
            int deviceType,
            String deviceTypeName,
            double resolutionWidth,
            double resolutionHeight,
            double activeAreaWidth,
            double activeAreaHeight,
            double outDimensionWidth,
            double outDimensionHeight,
            double outDimensionDepth,
            int timezone,
            int orderX,
            int orderY,
            List<DeviceStoreTag> storeTags,
            DeviceMultiVision multiVision,
            DeviceConfiguration configuration,
            bool allowEnvSwitch,
            bool isRegistered,
            DeviceSettings settings,
            DeviceExternalStorageConfig storage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Device():
        return $default(
            _that.deviceId,
            _that.deviceName,
            _that.brandId,
            _that.brandName,
            _that.projectId,
            _that.projectName,
            _that.storeId,
            _that.storeName,
            _that.storeCode,
            _that.resolution,
            _that.ratio,
            _that.deviceType,
            _that.deviceTypeName,
            _that.resolutionWidth,
            _that.resolutionHeight,
            _that.activeAreaWidth,
            _that.activeAreaHeight,
            _that.outDimensionWidth,
            _that.outDimensionHeight,
            _that.outDimensionDepth,
            _that.timezone,
            _that.orderX,
            _that.orderY,
            _that.storeTags,
            _that.multiVision,
            _that.configuration,
            _that.allowEnvSwitch,
            _that.isRegistered,
            _that.settings,
            _that.storage);
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
            String deviceId,
            String deviceName,
            String brandId,
            String brandName,
            String projectId,
            String projectName,
            String storeId,
            String storeName,
            String storeCode,
            String resolution,
            String ratio,
            int deviceType,
            String deviceTypeName,
            double resolutionWidth,
            double resolutionHeight,
            double activeAreaWidth,
            double activeAreaHeight,
            double outDimensionWidth,
            double outDimensionHeight,
            double outDimensionDepth,
            int timezone,
            int orderX,
            int orderY,
            List<DeviceStoreTag> storeTags,
            DeviceMultiVision multiVision,
            DeviceConfiguration configuration,
            bool allowEnvSwitch,
            bool isRegistered,
            DeviceSettings settings,
            DeviceExternalStorageConfig storage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Device() when $default != null:
        return $default(
            _that.deviceId,
            _that.deviceName,
            _that.brandId,
            _that.brandName,
            _that.projectId,
            _that.projectName,
            _that.storeId,
            _that.storeName,
            _that.storeCode,
            _that.resolution,
            _that.ratio,
            _that.deviceType,
            _that.deviceTypeName,
            _that.resolutionWidth,
            _that.resolutionHeight,
            _that.activeAreaWidth,
            _that.activeAreaHeight,
            _that.outDimensionWidth,
            _that.outDimensionHeight,
            _that.outDimensionDepth,
            _that.timezone,
            _that.orderX,
            _that.orderY,
            _that.storeTags,
            _that.multiVision,
            _that.configuration,
            _that.allowEnvSwitch,
            _that.isRegistered,
            _that.settings,
            _that.storage);
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
      this.brandId = '',
      this.brandName = '',
      this.projectId = '',
      this.projectName = '',
      this.storeId = '',
      this.storeName = '',
      this.storeCode = '',
      this.resolution = '',
      this.ratio = '',
      this.deviceType = -1,
      this.deviceTypeName = '',
      this.resolutionWidth = 0,
      this.resolutionHeight = 0,
      this.activeAreaWidth = 0,
      this.activeAreaHeight = 0,
      this.outDimensionWidth = 0,
      this.outDimensionHeight = 0,
      this.outDimensionDepth = 0,
      this.timezone = 0,
      this.orderX = 0,
      this.orderY = 0,
      final List<DeviceStoreTag> storeTags = const <DeviceStoreTag>[],
      this.multiVision = const DeviceMultiVision(),
      this.configuration = const DeviceConfiguration(),
      this.allowEnvSwitch = false,
      this.isRegistered = false,
      this.settings = const DeviceSettings(),
      this.storage = const DeviceExternalStorageConfig()})
      : _storeTags = storeTags;

  @override
  @JsonKey()
  final String deviceId;
  @override
  @JsonKey()
  final String deviceName;
  @override
  @JsonKey()
  final String brandId;
  @override
  @JsonKey()
  final String brandName;
  @override
  @JsonKey()
  final String projectId;
  @override
  @JsonKey()
  final String projectName;
  @override
  @JsonKey()
  final String storeId;
  @override
  @JsonKey()
  final String storeName;
  @override
  @JsonKey()
  final String storeCode;
  @override
  @JsonKey()
  final String resolution;
  @override
  @JsonKey()
  final String ratio;
  @override
  @JsonKey()
  final int deviceType;
  @override
  @JsonKey()
  final String deviceTypeName;
  @override
  @JsonKey()
  final double resolutionWidth;
  @override
  @JsonKey()
  final double resolutionHeight;
  @override
  @JsonKey()
  final double activeAreaWidth;
  @override
  @JsonKey()
  final double activeAreaHeight;
  @override
  @JsonKey()
  final double outDimensionWidth;
  @override
  @JsonKey()
  final double outDimensionHeight;
  @override
  @JsonKey()
  final double outDimensionDepth;
  @override
  @JsonKey()
  final int timezone;
  @override
  @JsonKey()
  final int orderX;
  @override
  @JsonKey()
  final int orderY;
  final List<DeviceStoreTag> _storeTags;
  @override
  @JsonKey()
  List<DeviceStoreTag> get storeTags {
    if (_storeTags is EqualUnmodifiableListView) return _storeTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_storeTags);
  }

  @override
  @JsonKey()
  final DeviceMultiVision multiVision;
  @override
  @JsonKey()
  final DeviceConfiguration configuration;
  @override
  @JsonKey()
  final bool allowEnvSwitch;

  /// Whether FlowManager holds this device. `false` means it is not
  /// registered yet: the record carries defaults, not the cloud's values.
  @override
  @JsonKey()
  final bool isRegistered;
  @override
  @JsonKey()
  final DeviceSettings settings;
  @override
  @JsonKey()
  final DeviceExternalStorageConfig storage;

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
            (identical(other.brandId, brandId) || other.brandId == brandId) &&
            (identical(other.brandName, brandName) ||
                other.brandName == brandName) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.projectName, projectName) ||
                other.projectName == projectName) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.storeCode, storeCode) ||
                other.storeCode == storeCode) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.ratio, ratio) || other.ratio == ratio) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceTypeName, deviceTypeName) ||
                other.deviceTypeName == deviceTypeName) &&
            (identical(other.resolutionWidth, resolutionWidth) ||
                other.resolutionWidth == resolutionWidth) &&
            (identical(other.resolutionHeight, resolutionHeight) ||
                other.resolutionHeight == resolutionHeight) &&
            (identical(other.activeAreaWidth, activeAreaWidth) ||
                other.activeAreaWidth == activeAreaWidth) &&
            (identical(other.activeAreaHeight, activeAreaHeight) ||
                other.activeAreaHeight == activeAreaHeight) &&
            (identical(other.outDimensionWidth, outDimensionWidth) ||
                other.outDimensionWidth == outDimensionWidth) &&
            (identical(other.outDimensionHeight, outDimensionHeight) ||
                other.outDimensionHeight == outDimensionHeight) &&
            (identical(other.outDimensionDepth, outDimensionDepth) ||
                other.outDimensionDepth == outDimensionDepth) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.orderX, orderX) || other.orderX == orderX) &&
            (identical(other.orderY, orderY) || other.orderY == orderY) &&
            const DeepCollectionEquality()
                .equals(other._storeTags, _storeTags) &&
            (identical(other.multiVision, multiVision) ||
                other.multiVision == multiVision) &&
            (identical(other.configuration, configuration) ||
                other.configuration == configuration) &&
            (identical(other.allowEnvSwitch, allowEnvSwitch) ||
                other.allowEnvSwitch == allowEnvSwitch) &&
            (identical(other.isRegistered, isRegistered) ||
                other.isRegistered == isRegistered) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.storage, storage) || other.storage == storage));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        deviceId,
        deviceName,
        brandId,
        brandName,
        projectId,
        projectName,
        storeId,
        storeName,
        storeCode,
        resolution,
        ratio,
        deviceType,
        deviceTypeName,
        resolutionWidth,
        resolutionHeight,
        activeAreaWidth,
        activeAreaHeight,
        outDimensionWidth,
        outDimensionHeight,
        outDimensionDepth,
        timezone,
        orderX,
        orderY,
        const DeepCollectionEquality().hash(_storeTags),
        multiVision,
        configuration,
        allowEnvSwitch,
        isRegistered,
        settings,
        storage
      ]);

  @override
  String toString() {
    return 'Device(deviceId: $deviceId, deviceName: $deviceName, brandId: $brandId, brandName: $brandName, projectId: $projectId, projectName: $projectName, storeId: $storeId, storeName: $storeName, storeCode: $storeCode, resolution: $resolution, ratio: $ratio, deviceType: $deviceType, deviceTypeName: $deviceTypeName, resolutionWidth: $resolutionWidth, resolutionHeight: $resolutionHeight, activeAreaWidth: $activeAreaWidth, activeAreaHeight: $activeAreaHeight, outDimensionWidth: $outDimensionWidth, outDimensionHeight: $outDimensionHeight, outDimensionDepth: $outDimensionDepth, timezone: $timezone, orderX: $orderX, orderY: $orderY, storeTags: $storeTags, multiVision: $multiVision, configuration: $configuration, allowEnvSwitch: $allowEnvSwitch, isRegistered: $isRegistered, settings: $settings, storage: $storage)';
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
      String brandId,
      String brandName,
      String projectId,
      String projectName,
      String storeId,
      String storeName,
      String storeCode,
      String resolution,
      String ratio,
      int deviceType,
      String deviceTypeName,
      double resolutionWidth,
      double resolutionHeight,
      double activeAreaWidth,
      double activeAreaHeight,
      double outDimensionWidth,
      double outDimensionHeight,
      double outDimensionDepth,
      int timezone,
      int orderX,
      int orderY,
      List<DeviceStoreTag> storeTags,
      DeviceMultiVision multiVision,
      DeviceConfiguration configuration,
      bool allowEnvSwitch,
      bool isRegistered,
      DeviceSettings settings,
      DeviceExternalStorageConfig storage});

  @override
  $DeviceMultiVisionCopyWith<$Res> get multiVision;
  @override
  $DeviceConfigurationCopyWith<$Res> get configuration;
  @override
  $DeviceSettingsCopyWith<$Res> get settings;
  @override
  $DeviceExternalStorageConfigCopyWith<$Res> get storage;
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
    Object? brandId = null,
    Object? brandName = null,
    Object? projectId = null,
    Object? projectName = null,
    Object? storeId = null,
    Object? storeName = null,
    Object? storeCode = null,
    Object? resolution = null,
    Object? ratio = null,
    Object? deviceType = null,
    Object? deviceTypeName = null,
    Object? resolutionWidth = null,
    Object? resolutionHeight = null,
    Object? activeAreaWidth = null,
    Object? activeAreaHeight = null,
    Object? outDimensionWidth = null,
    Object? outDimensionHeight = null,
    Object? outDimensionDepth = null,
    Object? timezone = null,
    Object? orderX = null,
    Object? orderY = null,
    Object? storeTags = null,
    Object? multiVision = null,
    Object? configuration = null,
    Object? allowEnvSwitch = null,
    Object? isRegistered = null,
    Object? settings = null,
    Object? storage = null,
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
      brandId: null == brandId
          ? _self.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: null == brandName
          ? _self.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _self.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      projectName: null == projectName
          ? _self.projectName
          : projectName // ignore: cast_nullable_to_non_nullable
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
      resolution: null == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String,
      ratio: null == ratio
          ? _self.ratio
          : ratio // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as int,
      deviceTypeName: null == deviceTypeName
          ? _self.deviceTypeName
          : deviceTypeName // ignore: cast_nullable_to_non_nullable
              as String,
      resolutionWidth: null == resolutionWidth
          ? _self.resolutionWidth
          : resolutionWidth // ignore: cast_nullable_to_non_nullable
              as double,
      resolutionHeight: null == resolutionHeight
          ? _self.resolutionHeight
          : resolutionHeight // ignore: cast_nullable_to_non_nullable
              as double,
      activeAreaWidth: null == activeAreaWidth
          ? _self.activeAreaWidth
          : activeAreaWidth // ignore: cast_nullable_to_non_nullable
              as double,
      activeAreaHeight: null == activeAreaHeight
          ? _self.activeAreaHeight
          : activeAreaHeight // ignore: cast_nullable_to_non_nullable
              as double,
      outDimensionWidth: null == outDimensionWidth
          ? _self.outDimensionWidth
          : outDimensionWidth // ignore: cast_nullable_to_non_nullable
              as double,
      outDimensionHeight: null == outDimensionHeight
          ? _self.outDimensionHeight
          : outDimensionHeight // ignore: cast_nullable_to_non_nullable
              as double,
      outDimensionDepth: null == outDimensionDepth
          ? _self.outDimensionDepth
          : outDimensionDepth // ignore: cast_nullable_to_non_nullable
              as double,
      timezone: null == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as int,
      orderX: null == orderX
          ? _self.orderX
          : orderX // ignore: cast_nullable_to_non_nullable
              as int,
      orderY: null == orderY
          ? _self.orderY
          : orderY // ignore: cast_nullable_to_non_nullable
              as int,
      storeTags: null == storeTags
          ? _self._storeTags
          : storeTags // ignore: cast_nullable_to_non_nullable
              as List<DeviceStoreTag>,
      multiVision: null == multiVision
          ? _self.multiVision
          : multiVision // ignore: cast_nullable_to_non_nullable
              as DeviceMultiVision,
      configuration: null == configuration
          ? _self.configuration
          : configuration // ignore: cast_nullable_to_non_nullable
              as DeviceConfiguration,
      allowEnvSwitch: null == allowEnvSwitch
          ? _self.allowEnvSwitch
          : allowEnvSwitch // ignore: cast_nullable_to_non_nullable
              as bool,
      isRegistered: null == isRegistered
          ? _self.isRegistered
          : isRegistered // ignore: cast_nullable_to_non_nullable
              as bool,
      settings: null == settings
          ? _self.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as DeviceSettings,
      storage: null == storage
          ? _self.storage
          : storage // ignore: cast_nullable_to_non_nullable
              as DeviceExternalStorageConfig,
    ));
  }

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceMultiVisionCopyWith<$Res> get multiVision {
    return $DeviceMultiVisionCopyWith<$Res>(_self.multiVision, (value) {
      return _then(_self.copyWith(multiVision: value));
    });
  }

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceConfigurationCopyWith<$Res> get configuration {
    return $DeviceConfigurationCopyWith<$Res>(_self.configuration, (value) {
      return _then(_self.copyWith(configuration: value));
    });
  }

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceSettingsCopyWith<$Res> get settings {
    return $DeviceSettingsCopyWith<$Res>(_self.settings, (value) {
      return _then(_self.copyWith(settings: value));
    });
  }

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceExternalStorageConfigCopyWith<$Res> get storage {
    return $DeviceExternalStorageConfigCopyWith<$Res>(_self.storage, (value) {
      return _then(_self.copyWith(storage: value));
    });
  }
}

// dart format on
