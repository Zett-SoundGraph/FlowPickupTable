# Flow Pickup Table - README

Flow Pickup Table is a Flutter application built with Clean Architecture
and Cubit for state management. It runs on the physical pickup-table unit
and renders cup-pickup guidance (grid/themed rendering, order matching,
background video) based on detection data it receives over MQTT from the
separate `tof_camera` device — this app does **not** do any camera/ToF
capture itself.

## 1. Project Goals

- Render live order-matching guidance on the pickup table screen (circle
  and themed-grid rendering modes).
- Consume `TofFrame`/`TofObject` detection data pushed over MQTT by
  `tof_camera`.
- Drive the calibration flow (`START_CALIBRATION`/`VALIDATION_MODE`).
- Play a background video while idle.

## 2. Environment and Requirements

### 2.1 SDK

- Flutter: 3.32.8 (locked in `.fvmrc`)
- Dart SDK: `>=3.0.0 <4.0.0` (from pubspec)

### 2.2 Required Toolchain Versions

- FVM: recommended (for team-wide Flutter version consistency)
- Java (JDK): 17+ (JDK 17 LTS recommended)
- Gradle Wrapper: 8.12 (`android/gradle/wrapper/gradle-wrapper.properties`)
- Android Gradle Plugin (AGP): 8.9.1 (`android/settings.gradle.kts`)
- Kotlin Android Plugin: 2.1.0 (`android/settings.gradle.kts`)
- compileSdk / minSdk / targetSdk: 36 / 23 / **33** (org-wide fleet standard
  is minSdk 23 / targetSdk 35, but this project pins targetSdk to 33 —
  raising it to 35 caused stability issues on the deployed T982 hardware.
  Do not bump this without re-testing on that device.)

### 2.3 Verify Local Environment

```bash
fvm use 3.32.8
fvm flutter --version
fvm dart --version
java -version
```

Optional Android check:

```bash
cd android
./gradlew -version
```

### 2.4 Core Packages

- flutter_bloc
- get_it + injectable
- freezed
- mqtt_client
- media_kit / media_kit_video / media_kit_libs_android_video (background
  video)
- path_provider, shared_preferences

`path_provider_android`, `shared_preferences_android`, and
`video_player_android` are pinned via `dependency_overrides` in
`pubspec.yaml` — newer releases of those three raised their own minSdk
floor to 24, which conflicts with this fleet's minSdk 23. See the comment
above `dependency_overrides` before bumping any of them.

## 3. Quick Setup

```bash
fvm use
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter analyze --no-fatal-infos
```

## 4. Testing

```bash
fvm flutter test
```

No real test suite exists yet — only the default `test/widget_test.dart`
scaffold.

## 5. Running by Environment

The project has two real entrypoints:

- Dev: `lib/main_dev.dart`
- Prod: `lib/main_prod.dart`

`lib/main.dart` is the plain Flutter-template default and does **not**
initialize DI — always run via one of the two entrypoints above.

```bash
# Run
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart

# Build APK
flutter build apk --flavor dev -t lib/main_dev.dart --debug
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

Both entrypoints: `WidgetsFlutterBinding.ensureInitialized()` →
`MediaKit.ensureInitialized()` → `LocalSubnetResolver.resolve()`
(unawaited) → `DiagLogger.init()` → `setupLocator(Env.dev()/Env.prod())` →
`runApp(MyApp)` (dark theme, home = `AioPickupTableMain`).

Output APK filename: `CafeBeta_PickupTable_<version>.<buildNumber>-<flavor>.apk`
(see `android/app/build.gradle`'s `applicationVariants.all` block).

### 5.1 Auto-start on boot

`android/app/src/main/kotlin/com/soundgraph/flow/pickuptable/BootReceiver.kt`
listens for `ACTION_BOOT_COMPLETED` and launches `MainActivity`
automatically (`RECEIVE_BOOT_COMPLETED` permission, declared in
`AndroidManifest.xml`) — the deployed unit is expected to self-launch after
a power cycle with no manual intervention.

### 5.2 Diagnostic log

`lib/core/utils/diag_logger.dart` writes a daily
`diag_log_YYYY-MM-DD.txt` to external app storage (pairs with
`tof_camera`'s own native-side `diag_log.cpp`, so both sides' logs can be
compared by timestamp). Pull it with:

```bash
adb pull /storage/emulated/0/Android/data/<applicationId>/files/diag_log_YYYY-MM-DD.txt
```

## 6. Folder Structure

```text
lib/
  core/
    constants/         # app constants, network topics
    di/                # get_it + injectable config
    env/               # environment model
    theme/              # pickup table theme registry, grid layout
    utils/               # DiagLogger
  data/
    repositories/       # repository implementations
    sources/
      local/             # order manager (local state)
      remote/            # MQTT service
  domain/
    entities/            # order, theme selection, calibration request, etc.
    repositories/         # repository contracts
    usecases/             # business use cases
  presentation/
    cubit/                # PickupTableCubit + state
    screens/              # AioPickupTableMain, calibration screen
    widgets/              # themed slot widgets, background video/loop
```

## 7. Project Rules

### 7.1 Clean Architecture

- Presentation calls use cases, not data sources directly.
- Cubit does not access data layer classes directly.
- Domain does not depend on Flutter widgets.

### 7.2 Generated Files

Do not edit directly — edit the source and re-run build_runner:

- `*.freezed.dart`
- `di.config.dart`

### 7.3 index.dart Barrel Export Rule

Each feature/layer folder exposes its public files through `index.dart`.
Add new public files to the matching `index.dart` in the same change.

### 7.4 Version Naming Rule

`pubspec.yaml` version format: `MAJOR.MINOR.DATE+BUILD`

```yaml
version: 0.10.1012+01
```

- `MAJOR`: breaking release line
- `MINOR`: feature milestone line
- `DATE`: release date (`MMDD`)
- `BUILD`: same-day build count — bump by hand before every same-day rebuild

## 8. Signing

Release builds are signed via `key.properties` (not committed — create it
at the `android/` root) loaded by `android/app/build.gradle`:

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=...
```

Without this file, `signingConfigs.release` fields resolve to `null` and
the release build will fail to sign.

## 9. Common Troubleshooting

### 9.1 App starts but DI is missing

Running `lib/main.dart` does not initialize DI. Use an environment
entrypoint instead:

```bash
flutter run -t lib/main_dev.dart
```

### 9.2 Duplicate injectable registrations

Make sure no two classes are registered as the same abstract type under the
same scope.

### 9.3 Build fails with a minSdk manifest-merger error

A plugin was likely upgraded past the minSdk-23 floor (confirmed to have
happened before with `path_provider_android`/`shared_preferences_android`/
`video_player_android` — see §2.4). Pin it back via `dependency_overrides`
to the newest version whose own `android/build.gradle` still declares
`minSdkVersion` ≤ 23, rather than raising this project's minSdk.

## 10. References

- Flutter docs: https://docs.flutter.dev/
- Bloc library: https://bloclibrary.dev/
- Freezed: https://pub.dev/packages/freezed
- Injectable: https://pub.dev/packages/injectable
- GetIt: https://pub.dev/packages/get_it
- mqtt_client: https://pub.dev/packages/mqtt_client
- media_kit: https://pub.dev/packages/media_kit
