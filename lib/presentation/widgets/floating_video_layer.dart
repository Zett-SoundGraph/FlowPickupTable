import 'dart:async';
import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// ==================== [Components: Layer 2 - Floating Video] ====================
// 컵을 피해다니는 비디오 플레이어
//
// NOTE: not currently rendered — its one call site in aio_pickuptable_main.dart
// (the Stack's build()) is commented out in favor of PickupBackgroundVideo.
// Kept (not deleted) in case it's needed again; moved here unchanged as part
// of the Clean Architecture folder reorg.
class FloatingVideoLayer extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final ValueNotifier<List<Offset>> obstacleNotifier;
  final Function(String)? onLog;

  const FloatingVideoLayer({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.obstacleNotifier,
    this.onLog,
  });

  @override
  State<FloatingVideoLayer> createState() => FloatingVideoLayerState();
}

class FloatingVideoLayerState extends State<FloatingVideoLayer> {
  late final Player _player;
  late final VideoController _controller;

  Offset _videoPos = Offset.zero;
  double _videoSize = 300.0;
  final Random _random = Random();

  final double minVideoSize = 150.0;
  final double maxVideoSize = 600.0;

  bool _isFollowingPickup = false;
  Timer? _returnTimer;
  bool _isVisible = true;

  static const Duration moveDuration = Duration(milliseconds: 2500);
  static const Duration sizeDuration = Duration(milliseconds: 1500);
  static const Curve animationCurve = Curves.easeInOutQuart;

  @override
  void initState() {
    super.initState();

    _player = Player();
    _controller = VideoController(
      _player,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // 1초 대기 (T982 보드에서 네이티브 Surface가 안정화되는 최소 시간)
      await Future.delayed(const Duration(milliseconds: 1000));

      final playerPlatform = _player.platform;
      if (playerPlatform is NativePlayer) {
        try {
          await playerPlatform.setProperty('hwdec', 'mediacodec');
          await playerPlatform.setProperty('video-sync', 'display-desync');
          await playerPlatform.setProperty('framedrop', 'vo');
          await playerPlatform.setProperty('demuxer-max-bytes', '1M');
          await playerPlatform.setProperty('cache', 'no');

          debugPrint("🚀 [IPS_DEBUG] T982 Video Buffer Optimized");
        } catch (e) {
          debugPrint("⚠️ [IPS_ERROR] Tuning failed: $e");
        }
      }

      // 비디오를 열 때 '재생'은 하지 않고 준비만 시킴
      await _player.open(Media('asset://assets/videos/delicious_square_cut_fhd.mp4'),
          play: false);
      await _player.setPlaylistMode(PlaylistMode.loop);
      await _player.setVolume(0);

      // 마지막으로 짧게 대기 후 재생 시작
      await Future.delayed(const Duration(milliseconds: 200));
      await _player.play();
      await _player.setRate(1.0);

      findNextSafePosition();
    });

    widget.obstacleNotifier.addListener(_handleObstacles);
  }

  void _handleObstacles() {
    if (!mounted) return;

    // 고정 모드일 때는 장애물을 만나도 위치를 옮기지 않고 '크기만' 조절합니다.
    if (_isFollowingPickup) {
      _adjustSizeOnly(widget.obstacleNotifier.value);
    } else {
      _adjustSizeToSurroundings(widget.obstacleNotifier.value);
    }
  }

  void _adjustSizeOnly(List<Offset> obstacles) {
    Offset currentCenter = _videoPos + Offset(_videoSize / 2, _videoSize / 2);
    double rawSize = _calculateMaxAvailableSize(currentCenter, obstacles);

    // 만약 주변 컵 때문에 영상이 너무 작아지면(minVideoSize 미만) 강제로 고정 해제하고 도망
    if (rawSize < minVideoSize) {
      _isFollowingPickup = false;
      findNextSafePosition();
      return;
    }

    double newSize = rawSize.clamp(minVideoSize, maxVideoSize);
    if ((newSize - _videoSize).abs() < 5.0) return;

    setState(() {
      _videoSize = newSize;
      _videoPos = currentCenter - Offset(newSize / 2, newSize / 2);
    });
  }

  // 영상 길이
  Duration getVideoDuration() {
    Duration duration = _player.state.duration;
    return (duration == Duration.zero) ? const Duration(seconds: 15) : duration;
  }

  Offset _getStrictSafeCenter(Offset targetCenter, double targetSize) {
    final double radius = targetSize / 2;
    const double margin = 10.0; // 최소 10px의 물리적 여유

    double minX = radius + margin;
    double maxX = widget.screenWidth - radius - margin;
    double minY = radius + margin;
    double maxY = widget.screenHeight - radius - margin;

    return Offset(
      targetCenter.dx.clamp(minX, maxX),
      targetCenter.dy.clamp(minY, maxY),
    );
  }

  // 컵이 사라진 위치로 이동
  Future<void> moveVideoToPosition(
      Offset pickupPos, List<Offset> obstacles) async {
    if (!mounted || _isFollowingPickup) return;

    _isFollowingPickup = true; // 고정 모드 활성화
    _returnTimer?.cancel();

    Offset optimizedPickupPos = pickupPos;
    double bestPickupSize = _calculateMaxAvailableSize(pickupPos, obstacles);

    for (int i = 0; i < 5; i++) {
      double angle = i * (2 * math.pi / 5);
      Offset offsetCandidate = pickupPos +
          Offset(math.cos(angle) * 80, math.sin(angle) * 80); // 80px 반경 조사
      double candidateSize =
          _calculateMaxAvailableSize(offsetCandidate, obstacles);

      if (candidateSize > bestPickupSize) {
        bestPickupSize = candidateSize;
        optimizedPickupPos = offsetCandidate;
      }
    }

    double rawTargetSize = bestPickupSize.clamp(minVideoSize, maxVideoSize);
    Offset finalTargetCenter =
        _getStrictSafeCenter(optimizedPickupPos, rawTargetSize);
    double finalTargetSize =
        _calculateMaxAvailableSize(finalTargetCenter, obstacles)
            .clamp(minVideoSize, maxVideoSize);
    Offset finalLeftTopPos =
        finalTargetCenter - Offset(finalTargetSize / 2, finalTargetSize / 2);

    setState(() {
      _videoPos = finalLeftTopPos;
      _videoSize = finalTargetSize;
    });

    _returnTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _isFollowingPickup = false;
        findNextSafePosition();
      }
    });
  }

  // 현재 위치 유지하면서 크기만 조절
  void _adjustSizeToSurroundings(List<Offset> obstacles) {
    if (!mounted) return;
    Offset currentCenter = _videoPos + Offset(_videoSize / 2, _videoSize / 2);
    double rawSize = _calculateMaxAvailableSize(currentCenter, obstacles);

    if (rawSize < minVideoSize) {
      findNextSafePosition();
      return;
    }

    double newSize = rawSize.clamp(minVideoSize, maxVideoSize);
    if ((newSize - _videoSize).abs() < 5.0) return;

    setState(() {
      _videoSize = newSize;
      _videoPos = currentCenter - Offset(newSize / 2, newSize / 2);
    });
  }

  // 특정 위치에서 가능한 최대 크기 계산
  double _calculateMaxAvailableSize(Offset center, List<Offset> obstacles) {
    // 1. 벽까지의 거리
    double distToLeft = center.dx;
    double distToRight = widget.screenWidth - center.dx;
    double distToTop = center.dy;
    double distToBottom = widget.screenHeight - center.dy;
    double minToWall =
        [distToLeft, distToRight, distToTop, distToBottom].reduce(min);

    // 2. 장애물까지의 거리
    double minToObstacle = double.infinity;
    const double obstacleRadius = 70.0;

    if (obstacles.isNotEmpty) {
      for (var obstacle in obstacles) {
        double dist = (obstacle - center).distance - obstacleRadius;
        if (dist < minToObstacle) minToObstacle = dist;
      }
    }

    // 3. 75% 적용
    double maxRadius = min(minToWall, minToObstacle);
    double calculatedSize = (maxRadius * 2) * 0.9;

    return calculatedSize;
  }

  // 빈 공간 찾기 (초기 실행 or 영상 종료 후)
  void findNextSafePosition() {
    if (!mounted) return;
    final List<Offset> obstacles = widget.obstacleNotifier.value;
    // 테이블 위에 아무것도 없으면? -> 정중앙
    if (obstacles.isEmpty) {
      _updateVisibility(true);
      Offset centerScreen = Offset(widget.screenWidth / 2, widget.screenHeight / 2);
      double finalSize = _calculateMaxAvailableSize(centerScreen, []).clamp(minVideoSize, maxVideoSize);
      setState(() {
        _videoPos = centerScreen - Offset(finalSize / 2, finalSize / 2);
        _videoSize = finalSize;
      });
      return;
    }

    Offset bestCenter = Offset.zero;
    double bestSize = 0;
    const int samplingCount = 50; // 20군데를 찔러보고 가장 좋은 곳 선택

    for (int i = 0; i < samplingCount; i++) {
      // 랜덤 후보지 생성
      double randX = _random.nextDouble() * (widget.screenWidth - 400) + 200;
      double randY = _random.nextDouble() * (widget.screenHeight - 400) + 200;
      Offset candidateCenter = Offset(randX, randY);

      // 해당 위치에서 가능한 최대 크기 계산
      double currentSize =
          _calculateMaxAvailableSize(candidateCenter, obstacles);

      // 기존에 찾은 곳보다 더 큰 공간이면 업데이트
      if (currentSize > bestSize) {
        bestSize = currentSize;
        bestCenter = candidateCenter;
      }
    }

    // 최종 선택된 최적지로 이동
    if (bestSize < minVideoSize) {
      _updateVisibility(false); // 공간 없으면 숨김
    } else {
      _updateVisibility(true);  // 공간 있으면 표시
      double finalSize = bestSize.clamp(minVideoSize, maxVideoSize);
      setState(() {
        _videoSize = finalSize;
        _videoPos = _getStrictSafeCenter(bestCenter, finalSize) - Offset(finalSize / 2, finalSize / 2);
      });
    }
  }

  void _updateVisibility(bool visible) {
    if (_isVisible == visible) return;
    setState(() {
      _isVisible = visible;
    });
    // 리소스 절약을 위해 숨겨질 때 정지, 보일 때 재생
    if (visible) {
      _player.play();
    } else {
      _player.pause();
    }
  }

  @override
  void dispose() {
    widget.obstacleNotifier.removeListener(_handleObstacles);
    _player.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FloatingVideoLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obstacleNotifier != oldWidget.obstacleNotifier) {
      oldWidget.obstacleNotifier.removeListener(_handleObstacles);
      widget.obstacleNotifier.addListener(_handleObstacles);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: moveDuration,
      curve: animationCurve,
      left: _videoPos.dx,
      top: _videoPos.dy,
      child: AnimatedOpacity( // 투명도 애니메이션 추가
        duration: const Duration(milliseconds: 500),
        opacity: _isVisible ? 1.0 : 0.0,
        child: RepaintBoundary( // 독립적 렌더링 레이어 보장
          child: AnimatedContainer(
            duration: sizeDuration,
            curve: animationCurve,
            width: _videoSize,
            height: _videoSize,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
            clipBehavior: Clip.hardEdge,
            child: Video(controller: _controller, fit: BoxFit.cover, controls: NoVideoControls),
          ),
        ),
      ),
    );
  }
}
