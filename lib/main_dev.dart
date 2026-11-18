import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickup_table/core/constants/index.dart';
import 'package:pickup_table/core/di/index.dart';
import 'package:pickup_table/core/env/env.dart';
import 'package:pickup_table/core/utils/diag_logger.dart';
import 'package:pickup_table/data/platform/flow_updater_service.dart';
import 'package:pickup_table/presentation/cubit/pickup_table_cubit.dart';
import 'package:pickup_table/presentation/screens/index.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // await 하지 않음 — flowHubIp/mqttBrokerHost는 해결 전까지 현재 배포된
  // 매장의 대역으로 폴백되므로 여기서 막을 필요 없음(아래 소켓/MQTT 연결이
  // 이미 각자 재시도 로직을 갖고 있어 해결되는 대로 자동 반영됨).
  LocalSubnetResolver.resolve();
  DiagLogger.init();
  setupLocator(Env.dev());
  // Don't await it before runApp: if FlowUpdater is missing, startup must not
  // wait. The SDK keeps reconnecting in the background either way.
  final FlowUpdaterService updater = getIt<FlowUpdaterService>();
  unawaited(updater.connect());
  runApp(const MyApp());
  // UI is up: report ready for FlowUpdater's IPC_READY health check once the
  // first frame is drawn (same timing as FlowKioskApp).
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(updater.markReady()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIO Pickup Table',

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueGrey,
      ),

      home: BlocProvider(
        create: (_) => getIt<PickupTableCubit>(),
        child: const AioPickupTableMain(),
      ),
    );
  }
}
