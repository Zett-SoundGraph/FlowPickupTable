/// Thin interface over the pickup-message translation sheet — the actual
/// fetch/cache logic lives unchanged in
/// data/sources/remote/language_sheet_service.dart's LanguageSheetService.
abstract interface class LanguageRepository {
  Future<void> load();

  /// Picks one of whatever PT.PM.* "thank you" messages are currently
  /// loaded at random and translates it to [lang].
  String pickupMessageFor(String lang);

  void dispose();
}
