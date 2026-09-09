import 'dart:async';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';

/// Fetches the same Google Sheet KDS/pickup_board read, via its "Version
/// Info" tab indirection (a changed publish-gid on a real data tab doesn't
/// break this) — just the "Language List" tab (UI text translations, keyed
/// by Language ID, e.g. "PT.PM.0001"). Column layout and refresh strategy
/// mirror pickup_board's MenuSheetDataSource exactly (same spreadsheet).
class LanguageSheetService {
  static const _versionInfoCsvUrl =
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vRjetA91xB8_tsu6wDnq8hRIi-0Par49dRi1fAy4LUliGtH0L9lADbfRAZrOqouUPjZmIQLcVNpvNY1/pub?gid=844462145&single=true&output=csv';

  static const _languageListSheetName = 'Language List';

  // Column NAMES — looked up by header rather than fixed position (see
  // _headerIndex/_cell) so a column inserted/reordered in the sheet can
  // never silently misalign this reader (mirrors pickup_board's own fix).
  static const _colLanguageId = 'Language ID';
  static const _colLanguageEN = 'Language.EN';
  static const _colLanguageJA = 'Language.JA';
  static const _colLanguageKO = 'Language.KO';
  static const _colLanguageZH = 'Language.ZH';

  static const _refreshInterval = Duration(minutes: 2);

  // Pickup-table "thank you" messages — any Language List row whose ID
  // starts with this prefix is a candidate, discovered fresh from whatever
  // is currently loaded (not a fixed count), so adding/removing a variant
  // row in the sheet (e.g. a new PT.PM.0011) takes effect on the next
  // refresh with no code change.
  static const _pickupMessagePrefix = 'PT.PM.';
  static const _fallbackMessage = 'Thank you for your order!';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      followRedirects: true,
      maxRedirects: 5,
    ),
  );

  final Map<String, Map<String, String>> _translations = {};
  final Random _random = Random();
  String? _lastUpdated;
  Timer? _refreshTimer;
  final Function(String message)? onLog;

  LanguageSheetService({this.onLog});

  String? translate(String languageId, String lang) {
    final row = _translations[languageId];
    if (row == null) return null;
    final text = row[lang.trim().toLowerCase()] ?? row['en'];
    return text?.replaceAll('<br>', '\n');
  }

  /// Picks one of whatever PT.PM.* messages are currently loaded at random
  /// and translates it to [lang] — called once per pickup (not re-rolled on
  /// every rebuild).
  String pickupMessageFor(String lang) {
    final ids = _translations.keys.where((id) => id.startsWith(_pickupMessagePrefix)).toList();
    if (ids.isEmpty) {
      // onLog?.call('⚠️ 픽업 메시지: Language List 시트에 PT.PM.* 행이 없거나 아직 로드되지 않음 — 기본 영어 문구 사용');
      return _fallbackMessage;
    }
    if (lang.isEmpty) {
      // onLog?.call('⚠️ 픽업 메시지: 이 주문에 lang 값이 비어있음 (kiosk에서 안 실려옴) — 영어로 표시');
    }
    final id = ids[_random.nextInt(ids.length)];
    return translate(id, lang) ?? _fallbackMessage;
  }

  Future<void> load() async {
    await _checkAndReload(force: true);
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => unawaited(_checkAndReload()));
  }

  Future<void> _checkAndReload({bool force = false}) async {
    try {
      final meta = await _fetchSheetMeta();
      final entry = meta[_languageListSheetName];
      if (entry == null) {
        // onLog?.call('⚠️ Language List: Version Info 시트에서 탭을 찾지 못함');
        return;
      }
      if (!force && _lastUpdated == entry.lastUpdated) return;

      final rows = await _fetchCsv(entry.csvUrl);
      final headers = _headerIndex(rows);
      final translations = <String, Map<String, String>>{};
      for (final row in rows.skip(1)) {
        final languageId = _cell(row, headers, _colLanguageId);
        if (languageId.isEmpty) continue;
        translations[languageId] = {
          'en': _cell(row, headers, _colLanguageEN),
          'ja': _cell(row, headers, _colLanguageJA),
          'ko': _cell(row, headers, _colLanguageKO),
          'zh': _cell(row, headers, _colLanguageZH),
        };
      }
      _translations
        ..clear()
        ..addAll(translations);
      _lastUpdated = entry.lastUpdated;
      // onLog?.call('✅ Language List 로드 완료 (${_translations.length}개 문구)');
    } catch (e) {
      // Sheet unreachable — cached translations (if any) just stay as-is
      // until the next periodic check succeeds.
      // onLog?.call('⚠️ Language List 로드 실패: $e');
    }
  }

  Future<Map<String, ({String lastUpdated, String csvUrl})>> _fetchSheetMeta() async {
    final rows = await _fetchCsv(_versionInfoCsvUrl);
    final headers = _headerIndex(rows);
    final result = <String, ({String lastUpdated, String csvUrl})>{};
    for (final row in rows.skip(1)) {
      final name = _cell(row, headers, 'Sheets');
      if (name.isEmpty) continue;
      result[name] = (
        lastUpdated: _cell(row, headers, 'Last Updated (Sheet)'),
        csvUrl: _cell(row, headers, 'CSV File URL'),
      );
    }
    return result;
  }

  /// Maps each header cell (row 0) to its column position, so every parser
  /// above looks values up by name instead of a fixed index — a column
  /// inserted/reordered in the sheet just shifts positions in this map,
  /// never silently misaligns a hardcoded number again.
  Map<String, int> _headerIndex(List<List<dynamic>> rows) {
    if (rows.isEmpty) return const {};
    final header = rows.first;
    final map = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      final name = header[i].toString().trim();
      if (name.isNotEmpty) map[name] = i;
    }
    return map;
  }

  /// [row]'s value under column [name], or '' if that column doesn't exist
  /// in this sheet (unknown header) or this particular row is short one.
  String _cell(List<dynamic> row, Map<String, int> headers, String name) {
    final idx = headers[name];
    if (idx == null || idx >= row.length) return '';
    return row[idx].toString().trim();
  }

  Future<List<List<dynamic>>> _fetchCsv(String url) async {
    final response = await _dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
    );
    final body = (response.data ?? '').replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    return const CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(body);
  }

  void dispose() {
    _refreshTimer?.cancel();
  }
}
