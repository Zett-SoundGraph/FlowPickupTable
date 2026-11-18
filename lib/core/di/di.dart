import 'package:injectable/injectable.dart';

import 'package:pickup_table/core/di/di.config.dart';
import 'package:pickup_table/core/di/service_locator.dart';
import 'package:pickup_table/core/env/env.dart';
import 'package:pickup_table/data/platform/flow_updater_service.dart';

export 'package:pickup_table/core/di/service_locator.dart';

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void setupLocator(Env env) {
  getIt.registerSingleton<Env>(env);
  // One FlowUpdater link for the whole app (see FlowUpdaterService). Registered
  // by hand, like FlowKioskApp, before the generated graph that depends on it.
  getIt.registerSingleton<FlowUpdaterService>(FlowUpdaterService());
  $initGetIt(getIt);
}
