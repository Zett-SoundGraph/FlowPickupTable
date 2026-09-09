import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Detects this device's own LAN subnet (its IPv4 address's first three
/// octets) so the Flow Hub leader/MQTT broker addresses can be built as
/// "prefix.200"/"prefix.240" instead of a full IP hardcoded per exhibition
/// site. Every Cafe Beta device on one site shares a subnet by design (the
/// site's router is pre-configured before install, so DHCP hands this
/// device its own address out of that same range) — reading it off this
/// device's own interface means a new site (a different third octet) needs
/// zero code changes or reinstalls, just a router pre-configured for that
/// range with the leader/broker reserved at their usual last octet.
class LocalSubnetResolver {
  const LocalSubnetResolver._();

  static const _retryInterval = Duration(seconds: 5);

  // Falls back to the currently-deployed site's subnet until real detection
  // succeeds — only relevant to a caller that reads [prefix] directly
  // without awaiting [ready] first (none currently do; kept as a safe
  // default regardless).
  static String prefix = '192.168.81';

  static bool _started = false;
  static final Completer<String> _readyCompleter = Completer<String>();

  /// Completes once, the first time a real subnet is detected. Every
  /// connect() (MQTT, the Flow Hub WebSocket) awaits this before dialing
  /// out — awaiting first means a NEW site (whose subnet doesn't match
  /// [prefix]'s currently-deployed-site fallback) never wastes a doomed
  /// first attempt against the wrong address; it only ever dials the real
  /// one.
  static Future<String> get ready => _readyCompleter.future;

  /// Starts background detection — safe to call more than once (a call
  /// after the first is a no-op). Retries every [_retryInterval] until a
  /// real local IPv4 address is found (the network interface may not be up
  /// yet at boot — the same race that can make an auto-launched app's first
  /// connect attempt fail), then applies it and stops.
  static void resolve() {
    if (_started) return;
    _started = true;
    unawaited(_loop());
  }

  static Future<void> _loop() async {
    while (true) {
      final detected = await _detectOwnIp();
      if (detected != null) {
        final parts = detected.split('.');
        if (parts.length == 4) {
          final resolved = parts.sublist(0, 3).join('.');
          if (resolved != prefix) {
            debugPrint('📡 [LocalSubnetResolver] Detected local subnet: $resolved (own IP: $detected)');
          }
          prefix = resolved;
          if (!_readyCompleter.isCompleted) _readyCompleter.complete(resolved);
          return;
        }
      }
      await Future.delayed(_retryInterval);
    }
  }

  static Future<String?> _detectOwnIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          return addr.address;
        }
      }
    } catch (e) {
      debugPrint('📡 [LocalSubnetResolver] Failed to enumerate network interfaces: $e');
    }
    return null;
  }
}
