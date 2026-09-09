// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pickup_table_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PickupTableState {
  bool get isCalibrating;
  Offset? get latestRawForCalib;
  List<DetectedObject>
      get objects; // 고객이 QR을 스캔해서 강조 표시된 주문번호(bare, 복합 라벨 아님) 목록.
  Set<String>
      get highlightedOrders; // 픽업된(테이블에서 사라진) 컵이 ghostDuration(5초) 동안 자리에 남아 감사
// 메시지를 보여주는 상태 — key: '${orderNo}_${stableKey}'(컵 단위 구분).
  Map<String, Map<String, dynamic>> get pickupGhostCircles;
  bool get showRawData;
  List<TofObject> get lastFrameObjects;
  bool get isHandDetected;
  Map<String, ui.Image> get iconImages;
  int? get currentLatestFrameId;
  bool get isConsoleOpen;
  List<LogItem> get consoleLogs;
  Map<String, Offset>
      get guidePositions; // Bumped on every emit that should force a rebuild regardless of
// whether any individual field above happens to compare equal (e.g.
// the same List/Map instance mutated in place) — mirrors
// FlowBoardState.clockTick's own reasoning.
  int get frameRevision;

  /// Create a copy of PickupTableState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PickupTableStateCopyWith<PickupTableState> get copyWith =>
      _$PickupTableStateCopyWithImpl<PickupTableState>(
          this as PickupTableState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PickupTableState &&
            (identical(other.isCalibrating, isCalibrating) ||
                other.isCalibrating == isCalibrating) &&
            (identical(other.latestRawForCalib, latestRawForCalib) ||
                other.latestRawForCalib == latestRawForCalib) &&
            const DeepCollectionEquality().equals(other.objects, objects) &&
            const DeepCollectionEquality()
                .equals(other.highlightedOrders, highlightedOrders) &&
            const DeepCollectionEquality()
                .equals(other.pickupGhostCircles, pickupGhostCircles) &&
            (identical(other.showRawData, showRawData) ||
                other.showRawData == showRawData) &&
            const DeepCollectionEquality()
                .equals(other.lastFrameObjects, lastFrameObjects) &&
            (identical(other.isHandDetected, isHandDetected) ||
                other.isHandDetected == isHandDetected) &&
            const DeepCollectionEquality()
                .equals(other.iconImages, iconImages) &&
            (identical(other.currentLatestFrameId, currentLatestFrameId) ||
                other.currentLatestFrameId == currentLatestFrameId) &&
            (identical(other.isConsoleOpen, isConsoleOpen) ||
                other.isConsoleOpen == isConsoleOpen) &&
            const DeepCollectionEquality()
                .equals(other.consoleLogs, consoleLogs) &&
            const DeepCollectionEquality()
                .equals(other.guidePositions, guidePositions) &&
            (identical(other.frameRevision, frameRevision) ||
                other.frameRevision == frameRevision));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isCalibrating,
      latestRawForCalib,
      const DeepCollectionEquality().hash(objects),
      const DeepCollectionEquality().hash(highlightedOrders),
      const DeepCollectionEquality().hash(pickupGhostCircles),
      showRawData,
      const DeepCollectionEquality().hash(lastFrameObjects),
      isHandDetected,
      const DeepCollectionEquality().hash(iconImages),
      currentLatestFrameId,
      isConsoleOpen,
      const DeepCollectionEquality().hash(consoleLogs),
      const DeepCollectionEquality().hash(guidePositions),
      frameRevision);

  @override
  String toString() {
    return 'PickupTableState(isCalibrating: $isCalibrating, latestRawForCalib: $latestRawForCalib, objects: $objects, highlightedOrders: $highlightedOrders, pickupGhostCircles: $pickupGhostCircles, showRawData: $showRawData, lastFrameObjects: $lastFrameObjects, isHandDetected: $isHandDetected, iconImages: $iconImages, currentLatestFrameId: $currentLatestFrameId, isConsoleOpen: $isConsoleOpen, consoleLogs: $consoleLogs, guidePositions: $guidePositions, frameRevision: $frameRevision)';
  }
}

/// @nodoc
abstract mixin class $PickupTableStateCopyWith<$Res> {
  factory $PickupTableStateCopyWith(
          PickupTableState value, $Res Function(PickupTableState) _then) =
      _$PickupTableStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isCalibrating,
      Offset? latestRawForCalib,
      List<DetectedObject> objects,
      Set<String> highlightedOrders,
      Map<String, Map<String, dynamic>> pickupGhostCircles,
      bool showRawData,
      List<TofObject> lastFrameObjects,
      bool isHandDetected,
      Map<String, ui.Image> iconImages,
      int? currentLatestFrameId,
      bool isConsoleOpen,
      List<LogItem> consoleLogs,
      Map<String, Offset> guidePositions,
      int frameRevision});
}

/// @nodoc
class _$PickupTableStateCopyWithImpl<$Res>
    implements $PickupTableStateCopyWith<$Res> {
  _$PickupTableStateCopyWithImpl(this._self, this._then);

  final PickupTableState _self;
  final $Res Function(PickupTableState) _then;

  /// Create a copy of PickupTableState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCalibrating = null,
    Object? latestRawForCalib = freezed,
    Object? objects = null,
    Object? highlightedOrders = null,
    Object? pickupGhostCircles = null,
    Object? showRawData = null,
    Object? lastFrameObjects = null,
    Object? isHandDetected = null,
    Object? iconImages = null,
    Object? currentLatestFrameId = freezed,
    Object? isConsoleOpen = null,
    Object? consoleLogs = null,
    Object? guidePositions = null,
    Object? frameRevision = null,
  }) {
    return _then(_self.copyWith(
      isCalibrating: null == isCalibrating
          ? _self.isCalibrating
          : isCalibrating // ignore: cast_nullable_to_non_nullable
              as bool,
      latestRawForCalib: freezed == latestRawForCalib
          ? _self.latestRawForCalib
          : latestRawForCalib // ignore: cast_nullable_to_non_nullable
              as Offset?,
      objects: null == objects
          ? _self.objects
          : objects // ignore: cast_nullable_to_non_nullable
              as List<DetectedObject>,
      highlightedOrders: null == highlightedOrders
          ? _self.highlightedOrders
          : highlightedOrders // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      pickupGhostCircles: null == pickupGhostCircles
          ? _self.pickupGhostCircles
          : pickupGhostCircles // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, dynamic>>,
      showRawData: null == showRawData
          ? _self.showRawData
          : showRawData // ignore: cast_nullable_to_non_nullable
              as bool,
      lastFrameObjects: null == lastFrameObjects
          ? _self.lastFrameObjects
          : lastFrameObjects // ignore: cast_nullable_to_non_nullable
              as List<TofObject>,
      isHandDetected: null == isHandDetected
          ? _self.isHandDetected
          : isHandDetected // ignore: cast_nullable_to_non_nullable
              as bool,
      iconImages: null == iconImages
          ? _self.iconImages
          : iconImages // ignore: cast_nullable_to_non_nullable
              as Map<String, ui.Image>,
      currentLatestFrameId: freezed == currentLatestFrameId
          ? _self.currentLatestFrameId
          : currentLatestFrameId // ignore: cast_nullable_to_non_nullable
              as int?,
      isConsoleOpen: null == isConsoleOpen
          ? _self.isConsoleOpen
          : isConsoleOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      consoleLogs: null == consoleLogs
          ? _self.consoleLogs
          : consoleLogs // ignore: cast_nullable_to_non_nullable
              as List<LogItem>,
      guidePositions: null == guidePositions
          ? _self.guidePositions
          : guidePositions // ignore: cast_nullable_to_non_nullable
              as Map<String, Offset>,
      frameRevision: null == frameRevision
          ? _self.frameRevision
          : frameRevision // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [PickupTableState].
extension PickupTableStatePatterns on PickupTableState {
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
    TResult Function(_PickupTableState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PickupTableState() when $default != null:
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
    TResult Function(_PickupTableState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PickupTableState():
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
    TResult? Function(_PickupTableState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PickupTableState() when $default != null:
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
            bool isCalibrating,
            Offset? latestRawForCalib,
            List<DetectedObject> objects,
            Set<String> highlightedOrders,
            Map<String, Map<String, dynamic>> pickupGhostCircles,
            bool showRawData,
            List<TofObject> lastFrameObjects,
            bool isHandDetected,
            Map<String, ui.Image> iconImages,
            int? currentLatestFrameId,
            bool isConsoleOpen,
            List<LogItem> consoleLogs,
            Map<String, Offset> guidePositions,
            int frameRevision)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PickupTableState() when $default != null:
        return $default(
            _that.isCalibrating,
            _that.latestRawForCalib,
            _that.objects,
            _that.highlightedOrders,
            _that.pickupGhostCircles,
            _that.showRawData,
            _that.lastFrameObjects,
            _that.isHandDetected,
            _that.iconImages,
            _that.currentLatestFrameId,
            _that.isConsoleOpen,
            _that.consoleLogs,
            _that.guidePositions,
            _that.frameRevision);
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
            bool isCalibrating,
            Offset? latestRawForCalib,
            List<DetectedObject> objects,
            Set<String> highlightedOrders,
            Map<String, Map<String, dynamic>> pickupGhostCircles,
            bool showRawData,
            List<TofObject> lastFrameObjects,
            bool isHandDetected,
            Map<String, ui.Image> iconImages,
            int? currentLatestFrameId,
            bool isConsoleOpen,
            List<LogItem> consoleLogs,
            Map<String, Offset> guidePositions,
            int frameRevision)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PickupTableState():
        return $default(
            _that.isCalibrating,
            _that.latestRawForCalib,
            _that.objects,
            _that.highlightedOrders,
            _that.pickupGhostCircles,
            _that.showRawData,
            _that.lastFrameObjects,
            _that.isHandDetected,
            _that.iconImages,
            _that.currentLatestFrameId,
            _that.isConsoleOpen,
            _that.consoleLogs,
            _that.guidePositions,
            _that.frameRevision);
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
            bool isCalibrating,
            Offset? latestRawForCalib,
            List<DetectedObject> objects,
            Set<String> highlightedOrders,
            Map<String, Map<String, dynamic>> pickupGhostCircles,
            bool showRawData,
            List<TofObject> lastFrameObjects,
            bool isHandDetected,
            Map<String, ui.Image> iconImages,
            int? currentLatestFrameId,
            bool isConsoleOpen,
            List<LogItem> consoleLogs,
            Map<String, Offset> guidePositions,
            int frameRevision)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PickupTableState() when $default != null:
        return $default(
            _that.isCalibrating,
            _that.latestRawForCalib,
            _that.objects,
            _that.highlightedOrders,
            _that.pickupGhostCircles,
            _that.showRawData,
            _that.lastFrameObjects,
            _that.isHandDetected,
            _that.iconImages,
            _that.currentLatestFrameId,
            _that.isConsoleOpen,
            _that.consoleLogs,
            _that.guidePositions,
            _that.frameRevision);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PickupTableState implements PickupTableState {
  const _PickupTableState(
      {this.isCalibrating = false,
      this.latestRawForCalib,
      final List<DetectedObject> objects = const <DetectedObject>[],
      final Set<String> highlightedOrders = const <String>{},
      final Map<String, Map<String, dynamic>> pickupGhostCircles =
          const <String, Map<String, dynamic>>{},
      this.showRawData = true,
      final List<TofObject> lastFrameObjects = const <TofObject>[],
      this.isHandDetected = false,
      final Map<String, ui.Image> iconImages = const <String, ui.Image>{},
      this.currentLatestFrameId,
      this.isConsoleOpen = false,
      final List<LogItem> consoleLogs = const <LogItem>[],
      final Map<String, Offset> guidePositions = const <String, Offset>{},
      this.frameRevision = 0})
      : _objects = objects,
        _highlightedOrders = highlightedOrders,
        _pickupGhostCircles = pickupGhostCircles,
        _lastFrameObjects = lastFrameObjects,
        _iconImages = iconImages,
        _consoleLogs = consoleLogs,
        _guidePositions = guidePositions;

  @override
  @JsonKey()
  final bool isCalibrating;
  @override
  final Offset? latestRawForCalib;
  final List<DetectedObject> _objects;
  @override
  @JsonKey()
  List<DetectedObject> get objects {
    if (_objects is EqualUnmodifiableListView) return _objects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_objects);
  }

// 고객이 QR을 스캔해서 강조 표시된 주문번호(bare, 복합 라벨 아님) 목록.
  final Set<String> _highlightedOrders;
// 고객이 QR을 스캔해서 강조 표시된 주문번호(bare, 복합 라벨 아님) 목록.
  @override
  @JsonKey()
  Set<String> get highlightedOrders {
    if (_highlightedOrders is EqualUnmodifiableSetView)
      return _highlightedOrders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_highlightedOrders);
  }

// 픽업된(테이블에서 사라진) 컵이 ghostDuration(5초) 동안 자리에 남아 감사
// 메시지를 보여주는 상태 — key: '${orderNo}_${stableKey}'(컵 단위 구분).
  final Map<String, Map<String, dynamic>> _pickupGhostCircles;
// 픽업된(테이블에서 사라진) 컵이 ghostDuration(5초) 동안 자리에 남아 감사
// 메시지를 보여주는 상태 — key: '${orderNo}_${stableKey}'(컵 단위 구분).
  @override
  @JsonKey()
  Map<String, Map<String, dynamic>> get pickupGhostCircles {
    if (_pickupGhostCircles is EqualUnmodifiableMapView)
      return _pickupGhostCircles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_pickupGhostCircles);
  }

  @override
  @JsonKey()
  final bool showRawData;
  final List<TofObject> _lastFrameObjects;
  @override
  @JsonKey()
  List<TofObject> get lastFrameObjects {
    if (_lastFrameObjects is EqualUnmodifiableListView)
      return _lastFrameObjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lastFrameObjects);
  }

  @override
  @JsonKey()
  final bool isHandDetected;
  final Map<String, ui.Image> _iconImages;
  @override
  @JsonKey()
  Map<String, ui.Image> get iconImages {
    if (_iconImages is EqualUnmodifiableMapView) return _iconImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_iconImages);
  }

  @override
  final int? currentLatestFrameId;
  @override
  @JsonKey()
  final bool isConsoleOpen;
  final List<LogItem> _consoleLogs;
  @override
  @JsonKey()
  List<LogItem> get consoleLogs {
    if (_consoleLogs is EqualUnmodifiableListView) return _consoleLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_consoleLogs);
  }

  final Map<String, Offset> _guidePositions;
  @override
  @JsonKey()
  Map<String, Offset> get guidePositions {
    if (_guidePositions is EqualUnmodifiableMapView) return _guidePositions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_guidePositions);
  }

// Bumped on every emit that should force a rebuild regardless of
// whether any individual field above happens to compare equal (e.g.
// the same List/Map instance mutated in place) — mirrors
// FlowBoardState.clockTick's own reasoning.
  @override
  @JsonKey()
  final int frameRevision;

  /// Create a copy of PickupTableState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PickupTableStateCopyWith<_PickupTableState> get copyWith =>
      __$PickupTableStateCopyWithImpl<_PickupTableState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PickupTableState &&
            (identical(other.isCalibrating, isCalibrating) ||
                other.isCalibrating == isCalibrating) &&
            (identical(other.latestRawForCalib, latestRawForCalib) ||
                other.latestRawForCalib == latestRawForCalib) &&
            const DeepCollectionEquality().equals(other._objects, _objects) &&
            const DeepCollectionEquality()
                .equals(other._highlightedOrders, _highlightedOrders) &&
            const DeepCollectionEquality()
                .equals(other._pickupGhostCircles, _pickupGhostCircles) &&
            (identical(other.showRawData, showRawData) ||
                other.showRawData == showRawData) &&
            const DeepCollectionEquality()
                .equals(other._lastFrameObjects, _lastFrameObjects) &&
            (identical(other.isHandDetected, isHandDetected) ||
                other.isHandDetected == isHandDetected) &&
            const DeepCollectionEquality()
                .equals(other._iconImages, _iconImages) &&
            (identical(other.currentLatestFrameId, currentLatestFrameId) ||
                other.currentLatestFrameId == currentLatestFrameId) &&
            (identical(other.isConsoleOpen, isConsoleOpen) ||
                other.isConsoleOpen == isConsoleOpen) &&
            const DeepCollectionEquality()
                .equals(other._consoleLogs, _consoleLogs) &&
            const DeepCollectionEquality()
                .equals(other._guidePositions, _guidePositions) &&
            (identical(other.frameRevision, frameRevision) ||
                other.frameRevision == frameRevision));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isCalibrating,
      latestRawForCalib,
      const DeepCollectionEquality().hash(_objects),
      const DeepCollectionEquality().hash(_highlightedOrders),
      const DeepCollectionEquality().hash(_pickupGhostCircles),
      showRawData,
      const DeepCollectionEquality().hash(_lastFrameObjects),
      isHandDetected,
      const DeepCollectionEquality().hash(_iconImages),
      currentLatestFrameId,
      isConsoleOpen,
      const DeepCollectionEquality().hash(_consoleLogs),
      const DeepCollectionEquality().hash(_guidePositions),
      frameRevision);

  @override
  String toString() {
    return 'PickupTableState(isCalibrating: $isCalibrating, latestRawForCalib: $latestRawForCalib, objects: $objects, highlightedOrders: $highlightedOrders, pickupGhostCircles: $pickupGhostCircles, showRawData: $showRawData, lastFrameObjects: $lastFrameObjects, isHandDetected: $isHandDetected, iconImages: $iconImages, currentLatestFrameId: $currentLatestFrameId, isConsoleOpen: $isConsoleOpen, consoleLogs: $consoleLogs, guidePositions: $guidePositions, frameRevision: $frameRevision)';
  }
}

/// @nodoc
abstract mixin class _$PickupTableStateCopyWith<$Res>
    implements $PickupTableStateCopyWith<$Res> {
  factory _$PickupTableStateCopyWith(
          _PickupTableState value, $Res Function(_PickupTableState) _then) =
      __$PickupTableStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isCalibrating,
      Offset? latestRawForCalib,
      List<DetectedObject> objects,
      Set<String> highlightedOrders,
      Map<String, Map<String, dynamic>> pickupGhostCircles,
      bool showRawData,
      List<TofObject> lastFrameObjects,
      bool isHandDetected,
      Map<String, ui.Image> iconImages,
      int? currentLatestFrameId,
      bool isConsoleOpen,
      List<LogItem> consoleLogs,
      Map<String, Offset> guidePositions,
      int frameRevision});
}

/// @nodoc
class __$PickupTableStateCopyWithImpl<$Res>
    implements _$PickupTableStateCopyWith<$Res> {
  __$PickupTableStateCopyWithImpl(this._self, this._then);

  final _PickupTableState _self;
  final $Res Function(_PickupTableState) _then;

  /// Create a copy of PickupTableState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isCalibrating = null,
    Object? latestRawForCalib = freezed,
    Object? objects = null,
    Object? highlightedOrders = null,
    Object? pickupGhostCircles = null,
    Object? showRawData = null,
    Object? lastFrameObjects = null,
    Object? isHandDetected = null,
    Object? iconImages = null,
    Object? currentLatestFrameId = freezed,
    Object? isConsoleOpen = null,
    Object? consoleLogs = null,
    Object? guidePositions = null,
    Object? frameRevision = null,
  }) {
    return _then(_PickupTableState(
      isCalibrating: null == isCalibrating
          ? _self.isCalibrating
          : isCalibrating // ignore: cast_nullable_to_non_nullable
              as bool,
      latestRawForCalib: freezed == latestRawForCalib
          ? _self.latestRawForCalib
          : latestRawForCalib // ignore: cast_nullable_to_non_nullable
              as Offset?,
      objects: null == objects
          ? _self._objects
          : objects // ignore: cast_nullable_to_non_nullable
              as List<DetectedObject>,
      highlightedOrders: null == highlightedOrders
          ? _self._highlightedOrders
          : highlightedOrders // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      pickupGhostCircles: null == pickupGhostCircles
          ? _self._pickupGhostCircles
          : pickupGhostCircles // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, dynamic>>,
      showRawData: null == showRawData
          ? _self.showRawData
          : showRawData // ignore: cast_nullable_to_non_nullable
              as bool,
      lastFrameObjects: null == lastFrameObjects
          ? _self._lastFrameObjects
          : lastFrameObjects // ignore: cast_nullable_to_non_nullable
              as List<TofObject>,
      isHandDetected: null == isHandDetected
          ? _self.isHandDetected
          : isHandDetected // ignore: cast_nullable_to_non_nullable
              as bool,
      iconImages: null == iconImages
          ? _self._iconImages
          : iconImages // ignore: cast_nullable_to_non_nullable
              as Map<String, ui.Image>,
      currentLatestFrameId: freezed == currentLatestFrameId
          ? _self.currentLatestFrameId
          : currentLatestFrameId // ignore: cast_nullable_to_non_nullable
              as int?,
      isConsoleOpen: null == isConsoleOpen
          ? _self.isConsoleOpen
          : isConsoleOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      consoleLogs: null == consoleLogs
          ? _self._consoleLogs
          : consoleLogs // ignore: cast_nullable_to_non_nullable
              as List<LogItem>,
      guidePositions: null == guidePositions
          ? _self._guidePositions
          : guidePositions // ignore: cast_nullable_to_non_nullable
              as Map<String, Offset>,
      frameRevision: null == frameRevision
          ? _self.frameRevision
          : frameRevision // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
