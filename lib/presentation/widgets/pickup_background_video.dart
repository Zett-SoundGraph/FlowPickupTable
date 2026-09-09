import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// Centered background video — replaces the old debug grid/watermark
// background. [videoAssetPath] is a constructor param (not hardcoded in
// build()) so this can later take a downloaded file path instead of a
// bundled asset once the video is sheet-driven, without touching this
// widget's internals.
class PickupBackgroundVideo extends StatefulWidget {
  static const String defaultAssetPath =
      'assets/videos/PickupTable-backgroundVideo.mp4';

  final String videoAssetPath;
  /// Whether the video should be playing — false pauses it (still visible,
  /// frozen on its last frame). The dim/glow look previously drawn here at
  /// runtime now comes entirely from whichever static background image the
  /// parent screen shows behind this widget.
  final bool isPlaying;
  /// Whether to draw the flat dim overlay on top of just the video box —
  /// only the video should darken while an object sits on the table, not
  /// the background image around it.
  final bool isDimmed;

  const PickupBackgroundVideo({
    super.key,
    this.videoAssetPath = defaultAssetPath,
    this.isPlaying = true,
    this.isDimmed = false,
  });

  @override
  State<PickupBackgroundVideo> createState() => _PickupBackgroundVideoState();
}

class _PickupBackgroundVideoState extends State<PickupBackgroundVideo> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // T982 보드에서 네이티브 Surface가 안정화되는 최소 시간 — FloatingVideoLayer와 동일
      await Future.delayed(const Duration(milliseconds: 1000));

      final playerPlatform = _player.platform;
      if (playerPlatform is NativePlayer) {
        try {
          await playerPlatform.setProperty('hwdec', 'mediacodec');
          await playerPlatform.setProperty('video-sync', 'display-desync');
          await playerPlatform.setProperty('framedrop', 'vo');
          await playerPlatform.setProperty('demuxer-max-bytes', '1M');
          await playerPlatform.setProperty('cache', 'no');
        } catch (e) {
          debugPrint("⚠️ [IPS_ERROR] PickupBackgroundVideo tuning failed: $e");
        }
      }

      await _player.open(Media('asset://${widget.videoAssetPath}'), play: false);
      await _player.setPlaylistMode(PlaylistMode.loop);
      await _player.setVolume(0);

      await Future.delayed(const Duration(milliseconds: 200));
      if (widget.isPlaying) {
        await _player.play();
      }
      await _player.setRate(1.0);
    });
  }

  @override
  void didUpdateWidget(covariant PickupBackgroundVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _player.play();
      } else {
        _player.pause();
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 1800,
        height: 960,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(48),
          // 일시정지 시에도 화면에는 그대로 남아 마지막 프레임이 보여야 함
          // (재생/정지는 _player.play()/pause()만으로 제어) — Opacity로
          // 숨기면 화면에서 아예 사라져 보이므로 여기선 항상 보이게 둠.
          child: Stack(
            fit: StackFit.expand,
            children: [
              Video(controller: _controller, fit: BoxFit.cover, controls: NoVideoControls),
              IgnorePointer(
                child: Opacity(
                  opacity: widget.isDimmed ? 1.0 : 0.0,
                  child: Container(color: const Color(0x941A1C1E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
