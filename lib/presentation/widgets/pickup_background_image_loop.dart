import 'dart:async';

import 'package:flutter/material.dart';

/// Cycles through [assetPaths] on a timer, crossfading (old fades out while
/// new fades in, via [AnimatedSwitcher]'s default fade transition) instead
/// of cutting instantly — used for
/// [PickupTableThemeBackgroundImage.loopMenuImages] (see that enum's own
/// doc comment for the asset list itself).
class PickupBackgroundImageLoop extends StatefulWidget {
  final List<String> assetPaths;
  final Duration holdDuration;
  final Duration fadeDuration;

  const PickupBackgroundImageLoop({
    super.key,
    required this.assetPaths,
    this.holdDuration = const Duration(seconds: 5),
    this.fadeDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<PickupBackgroundImageLoop> createState() => _PickupBackgroundImageLoopState();
}

class _PickupBackgroundImageLoopState extends State<PickupBackgroundImageLoop> {
  int _index = 0;
  Timer? _timer;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAll();
  }

  @override
  void didUpdateWidget(covariant PickupBackgroundImageLoop oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The asset list itself changed (not just which frame we're on) —
    // restart from the first image rather than risk an out-of-range index
    // against the new (possibly shorter) list.
    if (oldWidget.assetPaths != widget.assetPaths) {
      _index = 0;
      _precached = false;
      _precacheAll();
      _startTimer();
    }
  }

  // These are full-size photos (multi-MB), decoded on the device's own
  // modest SoC. Without this, the FIRST time each image comes up in the
  // rotation, AnimatedSwitcher starts the fade before the bitmap has
  // finished decoding — so instead of a crossfade it reads as an abrupt
  // cut partway in, once decoding catches up. Precaching every image in
  // the rotation up front (there are only ever a handful) means the
  // decoded bitmap is already sitting in the image cache before its
  // transition ever starts, so every fade is actually smooth.
  void _precacheAll() {
    if (_precached) return;
    _precached = true;
    for (final path in widget.assetPaths) {
      precacheImage(AssetImage(path), context);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.assetPaths.length <= 1) return; // Nothing to rotate to.
    _timer = Timer.periodic(widget.holdDuration, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.assetPaths.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.assetPaths[_index.clamp(0, widget.assetPaths.length - 1)];
    return AnimatedSwitcher(
      duration: widget.fadeDuration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: Image.asset(
        path,
        key: ValueKey(path),
        fit: BoxFit.cover,
      ),
    );
  }
}
