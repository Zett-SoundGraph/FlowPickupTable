import 'package:injectable/injectable.dart';

import 'package:pickup_table/core/di/di.config.dart';
import 'package:pickup_table/core/di/service_locator.dart';
import 'package:pickup_table/core/env/env.dart';

export 'package:pickup_table/core/di/service_locator.dart';

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void setupLocator(Env env) {
  getIt.registerSingleton<Env>(env);
  $initGetIt(getIt);
}
