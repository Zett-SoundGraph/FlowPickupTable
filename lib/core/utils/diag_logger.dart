import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// tof_camera(C++) 쪽 diag_log.txt와 짝을 이루는 최소 진단 로거.
///
/// 몇 시간에 한 번 정도 재발하는, 의도적으로 재현할 수 없는 "테이블 위 표시가
/// 갑자기 사라짐" 문제를 나중에 로그 파일만 보고 분석하기 위한 것 — 픽업테이블이
/// 화면에 몇 개를 그리고 있었는지(이 파일)와 tof 카메라가 몇 개를 인식하고
/// 있었는지(diag_log_*.txt)를 같은 타임스탬프 기준으로 나란히 비교해서, 문제가
/// tof 카메라 인식 쪽인지 MQTT 전달 쪽인지 픽업테이블 쪽 렌더링 로직인지를
/// 구분할 수 있게 한다.
///
/// 하루 단위 파일(diag_log_YYYY-MM-DD.txt)로 나눠서, 기기를 매일 최소 한 번은
/// 들여다보는 운영 방식에 맞춰 7일보다 오래된 파일은 자동으로 지운다 - 무한정
/// 쌓여서 저장공간 문제가 되는 일이 없게.
///
/// getExternalStorageDirectory()를 쓰는 이유: 내부 저장소(getApplicationDocumentsDirectory)는
/// adb pull에 root/run-as가 필요하지만, 앱 전용 외부 저장소는
/// `adb pull /storage/emulated/0/Android/data/<applicationId>/files/diag_log_YYYY-MM-DD.txt`로
/// root 없이 바로 꺼낼 수 있다.
class DiagLogger {
  static Directory? _dir;
  static String? _lastDate;
  static const int _retentionDays = 7;
  static final RegExp _logFilePattern = RegExp(r'^diag_log_(\d{4})-(\d{2})-(\d{2})\.txt$');

  static Future<void> init() async {
    try {
      _dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      await _cleanupOldLogs();
    } catch (_) {
      _dir = null;
    }
  }

  static String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<void> _cleanupOldLogs() async {
    final dir = _dir;
    if (dir == null) return;
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: _retentionDays));
      for (final entry in dir.listSync()) {
        if (entry is! File) continue;
        final name = entry.uri.pathSegments.last;
        final match = _logFilePattern.firstMatch(name);
        if (match == null) continue;
        final fileDate = DateTime(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
        );
        if (fileDate.isBefore(cutoff)) {
          await entry.delete();
        }
      }
    } catch (_) {
      // 정리 실패는 무시 - 다음 날짜가 바뀔 때 다시 시도됨
    }
  }

  // 같은 파일에 동시에 여러 writeAsString(mode: append) 호출이 겹치면 쓰기가
  // 서로 끼어들어서 바이트가 섞이거나 유실될 수 있다 — 실제로 diag_log 파일에서
  // 한 로그 줄의 앞부분이 다른 줄과 뒤섞인 채로 발견됨(merge 버그 분석 중
  // CUP_REMOVE/GRID_PHANTOM_CELL 줄 일부가 통째로 사라져 있었음). 모든 쓰기를
  // 이 체인 하나로 직렬화해서 항상 한 번에 하나씩만 실제 파일 쓰기가 일어나게
  // 한다.
  static Future<void> _writeChain = Future<void>.value();

  static Future<void> log(String tag, String message) {
    final Future<void> next = _writeChain.then((_) => _write(tag, message));
    _writeChain = next;
    return next;
  }

  static Future<void> _write(String tag, String message) async {
    final dir = _dir;
    if (dir == null) return;
    try {
      final today = _dateStr(DateTime.now());
      if (_lastDate != today) {
        _lastDate = today;
        await _cleanupOldLogs(); // 하루에 한 번(날짜 바뀔 때)만 실행됨
      }
      final file = File('${dir.path}/diag_log_$today.txt');
      final ts = DateTime.now().toIso8601String();
      await file.writeAsString('[$ts] [$tag] $message\n', mode: FileMode.append, flush: true);
    } catch (_) {
      // 진단 로깅 실패가 본 기능에 영향을 주면 안 되므로 조용히 무시
    }
  }
}
