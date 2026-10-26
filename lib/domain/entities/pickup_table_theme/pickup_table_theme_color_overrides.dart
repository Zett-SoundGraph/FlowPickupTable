import 'package:flutter/material.dart';

/// Raw per-slot colors an operator picked via FlowHub's color-palette
/// editor for the Pickup Table Theme feature — carried over the wire as hex
/// strings instead of [PickupTableThemeColors] itself, since that class
/// holds real [Gradient] objects with no natural JSON form. See
/// PickupTableThemeRegistry.resolveSelection for how this gets turned
/// into actual [PickupTableThemeColors] (gradients built from the
/// fill1/fill2 pairs below via the same `_diagonalGradient`/`_solidGradient`
/// helpers every built-in named theme already uses).
///
/// Names mirror FlowHub's screen labels: guideFill/guideStroke = "Brew",
/// matchedFill1/2 = "Call", timeoutFill1/2 = "Call-Expired",
/// receiptFill1/2 = "QR-Highlight".
class PickupTableThemeColorOverrides {
  final Color background;
  final Color guideFill;
  final Color guideStroke;
  final Color matchedFill1;
  final Color matchedFill2;
  final Color timeoutFill1;
  final Color timeoutFill2;
  final Color receiptFill1;
  final Color receiptFill2;
  final Color thankYouColor;

  const PickupTableThemeColorOverrides({
    required this.background,
    required this.guideFill,
    required this.guideStroke,
    required this.matchedFill1,
    required this.matchedFill2,
    required this.timeoutFill1,
    required this.timeoutFill2,
    required this.receiptFill1,
    required this.receiptFill2,
    required this.thankYouColor,
  });

  factory PickupTableThemeColorOverrides.fromJson(Map<String, dynamic> json) {
    Color hex(String key, Color fallback) {
      final raw = json[key]?.toString();
      final parsed = raw == null ? null : int.tryParse(raw, radix: 16);
      return parsed == null ? fallback : Color(parsed);
    }

    return PickupTableThemeColorOverrides(
      background: hex('background', const Color(0xFF000000)),
      guideFill: hex('guideFill', const Color(0x1AFFFFFF)),
      guideStroke: hex('guideStroke', const Color(0xFFFFFFFF)),
      matchedFill1: hex('matchedFill1', const Color(0xFFFFFFFF)),
      matchedFill2: hex('matchedFill2', const Color(0xFFFFFFFF)),
      timeoutFill1: hex('timeoutFill1', const Color(0xFFFF6B6B)),
      timeoutFill2: hex('timeoutFill2', const Color(0xFFFFABAB)),
      receiptFill1: hex('receiptFill1', const Color(0xFFFFFFFF)),
      receiptFill2: hex('receiptFill2', const Color(0xFFFFFFFF)),
      thankYouColor: hex('thankYouColor', const Color(0xFFFFFFFF)),
    );
  }
}

extension PickupTableThemeColorOverridesJson on PickupTableThemeColorOverrides {
  Map<String, dynamic> toJson() {
    String hex(Color c) => c.value.toRadixString(16).padLeft(8, '0');
    return {
      'background': hex(background),
      'guideFill': hex(guideFill),
      'guideStroke': hex(guideStroke),
      'matchedFill1': hex(matchedFill1),
      'matchedFill2': hex(matchedFill2),
      'timeoutFill1': hex(timeoutFill1),
      'timeoutFill2': hex(timeoutFill2),
      'receiptFill1': hex(receiptFill1),
      'receiptFill2': hex(receiptFill2),
      'thankYouColor': hex(thankYouColor),
    };
  }
}
