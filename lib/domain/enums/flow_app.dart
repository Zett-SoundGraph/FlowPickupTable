/// A Flow App, as FlowManager-BE's device `FlowApp` enum spells it. A device's
/// configuration names two: `flowApp`, the app it runs, and `defaultFlowApp`,
/// the one it installs when it has none. Mirrors FlowUpdater's `FlowApp`.
enum FlowApp {
  flowHub('FLOW_HUB', 'Flow Hub'),
  flowKiosk('FLOW_KIOSK', 'Flow Kiosk'),
  flowPickupTable('FLOW_PICKUP_TABLE', 'Pickup Table'),
  flowPickupBoard('FLOW_PICKUP_BOARD', 'Pickup Board'),
  flowPop('FLOW_POP', 'POP'),
  flowScanner('FLOW_SCANNER', 'Flow Scanner'),
  flowTofCamera('FLOW_TOF_CAMERA', 'Flow ToF Camera'),
  flowPromotionBoard('FLOW_PROMOTION_BOARD', 'Flow Promotion Board'),
  flowMqtt('FLOW_MQTT', 'Flow MessageHub'),
  flowMenuBoard('FLOW_MENU_BOARD', 'Flow Menu Board'),
  flowBoard('FLOW_BOARD', 'Flow Board'),

  /// Never assigned, or a value this build cannot parse (added on the backend
  /// later). Not a backend value.
  unknown('UNKNOWN', 'N/A');

  const FlowApp(this.value, this.label);

  /// The backend's spelling (`FLOW_BOARD`).
  final String value;

  /// Display name.
  final String label;

  /// Parses the backend's spelling; anything unparsable is [unknown].
  static FlowApp fromValue(String? value) {
    for (final FlowApp app in values) {
      if (app != unknown && app.value == value) {
        return app;
      }
    }
    return unknown;
  }
}
