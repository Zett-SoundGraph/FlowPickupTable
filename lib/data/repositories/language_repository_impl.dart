import 'package:injectable/injectable.dart';

import 'package:pickup_table/data/sources/remote/language_sheet_service.dart';
import 'package:pickup_table/domain/repositories/language_repository.dart';

@Singleton(as: LanguageRepository)
class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageSheetService _service = LanguageSheetService();

  @override
  Future<void> load() => _service.load();

  @override
  String pickupMessageFor(String lang) => _service.pickupMessageFor(lang);

  @override
  void dispose() => _service.dispose();
}
