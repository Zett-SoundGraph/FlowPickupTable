import 'package:freezed_annotation/freezed_annotation.dart';

part 'env.freezed.dart';

@freezed
abstract class Env with _$Env {
  const factory Env({@Default("") String apiUrl}) = _Env;

  factory Env.dev({@Default("") String apiUrl}) = _EnvDev;

  factory Env.prod({@Default("") String apiUrl}) = _EnvProd;

  factory Env.staging({@Default("") String apiUrl}) = _EnvStaging;

  const Env._();

  bool get isDev => this is _EnvDev;
}
