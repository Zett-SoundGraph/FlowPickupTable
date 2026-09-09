class LogItem {
  final String timestamp; // 시간
  final String type; // RX, TX, SYS, MOVE 등
  final String message; // 로그 내용
  final int? frameId; // 프레임 ID (색상 구분용, null이면 시스템 로그)
  final int? objectId;

  LogItem({
    required this.timestamp,
    required this.type,
    required this.message,
    this.frameId,
    this.objectId,
  });
}
