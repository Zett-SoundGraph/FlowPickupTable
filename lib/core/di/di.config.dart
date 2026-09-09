// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/repositories/coordinate_repository_impl.dart' as _i1039;
import '../../data/repositories/language_repository_impl.dart' as _i76;
import '../../data/repositories/order_repository_impl.dart' as _i717;
import '../../data/repositories/pickup_mqtt_repository_impl.dart' as _i790;
import '../../domain/repositories/coordinate_repository.dart' as _i252;
import '../../domain/repositories/index.dart' as _i445;
import '../../domain/repositories/language_repository.dart' as _i690;
import '../../domain/repositories/order_repository.dart' as _i507;
import '../../domain/repositories/pickup_mqtt_repository.dart' as _i754;
import '../../presentation/cubit/pickup_table_cubit.dart' as _i712;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.singleton<_i690.LanguageRepository>(() => _i76.LanguageRepositoryImpl());
  gh.singleton<_i754.PickupMqttRepository>(
      () => _i790.PickupMqttRepositoryImpl());
  gh.singleton<_i507.OrderRepository>(() => _i717.OrderRepositoryImpl());
  gh.singleton<_i252.CoordinateRepository>(
      () => _i1039.CoordinateRepositoryImpl());
  gh.factory<_i712.PickupTableCubit>(() => _i712.PickupTableCubit(
        gh<_i445.PickupMqttRepository>(),
        gh<_i445.LanguageRepository>(),
        gh<_i445.OrderRepository>(),
        gh<_i445.CoordinateRepository>(),
      ));
  return getIt;
}
