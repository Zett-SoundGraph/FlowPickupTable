import 'local_subnet_resolver.dart';

class AppConstants {
  static const int serverPort = 8080;
  // Flow Hub는 항상 리더(.200) 한 대만 하드웨어/웹소켓을 담당 — 팔로워는
  // 자체 웹소켓 서버를 띄우긴 해도 아무도 연결하지 않으므로 여기서 알 필요 없음.
  // 매장(대역)이 바뀌어도 뒷자리(.200)는 고정 — 앞 3자리는 이 기기 자신의
  // IP에서 자동으로 읽어온다 (LocalSubnetResolver).
  static String get flowHubIp => "${LocalSubnetResolver.prefix}.200";
  static const bool isDebug = true;
  static const bool isCommercialMode = false;

  static const double sensorWidth = 640.0;
  static const double sensorHeight = 480.0;
  static const double sensorCenterX = 320.0;
  static const double sensorCenterY = 240.0;

  // [매장별 커스텀 설정 - 이 부분을 매장마다 수정]
  static double totalSensorHeight = 1000.0; // 천장에서 바닥까지 높이 (mm)

  static const double visualSizeScale = 3.17;

  static String get mqttBrokerHost => "${LocalSubnetResolver.prefix}.240";
  static const int mqttBrokerPort = 1883;
  static const String mqttUsername = "cafebeta";
  static const String mqttPassword = "soundgraph@2026";

  // Fixed identity — never change once registered with Message Hub. Stays a
  // lowercase/hyphenated slug (not "Flow Pickup Table") because this gets
  // embedded directly into MQTT topic paths
  // (beta/system/heartbeat/<mqttDeviceId>) — every other topic in the
  // protocol is all-lowercase/no-space, so a space or mixed case here would
  // be the odd one out.
  static const String mqttDeviceId = "flow-pickup-table";
  // Display label shown on the Message Hub dashboard — safe to change anytime.
  static const String mqttDeviceName = "Flow Pickup Table";

  // Pickup message language falls back to this only when an order's own
  // `lang` (set by the customer's kiosk session) is missing/empty.
  static const String fallbackLanguage = "en";

  // Customer-facing text (pickup message, nickname) needs the font that
  // actually covers that language's script — a single font can't do
  // Latin/Hangul/Kana/Hanzi all well. Falls back to the English cut for any
  // unrecognized/empty language code. See pubspec.yaml's `fonts:` section
  // for what each family name is registered to.
  static String fontFamilyForLanguage(String lang) => switch (lang.trim().toLowerCase()) {
    'ko' => 'LineSeedKR',
    'ja' => 'LineSeedJP',
    'zh' => 'MiSans',
    _ => 'LineSeedEN',
  };
}