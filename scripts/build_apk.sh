#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/build_apk.sh <flavor> [--mode <debug|profile|release>] [--version <version>] [--output <dir>]

Examples:
  ./scripts/build_apk.sh dev
  ./scripts/build_apk.sh prod --mode release
  ./scripts/build_apk.sh dev --version 0.10.261027.26102701
  ./scripts/build_apk.sh prod --output ~/Documents/CafeBeta_PickupTable

Output filename format:
  CafeBeta_PickupTable_<flavor>_<version>.apk

Versioning (no --version given):
  build-name is MAJOR.MINOR (read from pubspec.yaml) + today's date
  (YYMMDD), build-number is YYMMDD followed by the same-day build count
  (NN, starting at 01) — both auto-computed, no manual editing of
  pubspec.yaml needed for a normal build. The same-day count is tracked in
  .build_number.local (gitignored, local to this machine) so repeated
  builds on the same day keep incrementing instead of colliding.
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

FLAVOR="$1"
shift

MODE="release"
VERSION_OVERRIDE=""
OUTPUT_DIR="${HOME}/Documents/CafeBeta_PickupTable"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --version)
      VERSION_OVERRIDE="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

case "$FLAVOR" in
  dev)
    TARGET="lib/main_dev.dart"
    ;;
  prod)
    TARGET="lib/main_prod.dart"
    ;;
  *)
    echo "Invalid flavor: $FLAVOR (allowed: dev|prod)"
    exit 1
    ;;
esac

case "$MODE" in
  debug|profile|release) ;;
  *)
    echo "Invalid mode: $MODE (allowed: debug|profile|release)"
    exit 1
    ;;
esac

if [[ ! -f pubspec.yaml ]]; then
  echo "pubspec.yaml not found. Run script at project root."
  exit 1
fi

BUILD_NAME=""
BUILD_NUMBER=""

if [[ -n "$VERSION_OVERRIDE" ]]; then
  APP_VERSION="$VERSION_OVERRIDE"
else
  VERSION_LINE="$(grep -E '^version:' pubspec.yaml | head -n1 | awk '{print $2}')"
  if [[ -z "$VERSION_LINE" ]]; then
    echo "Cannot read version from pubspec.yaml"
    exit 1
  fi
  MAJOR_MINOR="$(echo "${VERSION_LINE%%+*}" | cut -d'.' -f1-2)"

  TODAY="$(date +%y%m%d)"
  COUNTER_FILE=".build_number.local"
  LAST_DATE=""
  LAST_COUNT=0
  if [[ -f "$COUNTER_FILE" ]]; then
    IFS=':' read -r LAST_DATE LAST_COUNT < "$COUNTER_FILE" || true
  fi
  if [[ "$LAST_DATE" == "$TODAY" ]]; then
    BUILD_COUNT=$((LAST_COUNT + 1))
  else
    BUILD_COUNT=1
  fi
  printf '%s:%d' "$TODAY" "$BUILD_COUNT" > "$COUNTER_FILE"

  BUILD_NN="$(printf "%02d" "$BUILD_COUNT")"
  BUILD_NAME="${MAJOR_MINOR}.${TODAY}"
  BUILD_NUMBER="${TODAY}${BUILD_NN}"
  APP_VERSION="${BUILD_NAME}.${BUILD_NUMBER}"

  echo "Auto version: build-name=$BUILD_NAME build-number=$BUILD_NUMBER (build #$BUILD_COUNT today)"
fi

if [[ -d ".fvm" ]] && command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
else
  FLUTTER_CMD=(flutter)
fi

echo "Building flavor=$FLAVOR mode=$MODE target=$TARGET"
if [[ -n "$BUILD_NAME" && -n "$BUILD_NUMBER" ]]; then
  "${FLUTTER_CMD[@]}" build apk -t "$TARGET" --flavor "$FLAVOR" "--$MODE" \
    --build-name="$BUILD_NAME" --build-number="$BUILD_NUMBER"
else
  "${FLUTTER_CMD[@]}" build apk -t "$TARGET" --flavor "$FLAVOR" "--$MODE"
fi

SOURCE_APK="build/app/outputs/flutter-apk/app-${FLAVOR}-${MODE}.apk"
if [[ ! -f "$SOURCE_APK" ]]; then
  SOURCE_APK="$(ls -1 build/app/outputs/flutter-apk/app-*"${FLAVOR}"-"${MODE}".apk 2>/dev/null | head -n1 || true)"
fi

if [[ -z "$SOURCE_APK" || ! -f "$SOURCE_APK" ]]; then
  echo "Cannot find built APK for flavor=$FLAVOR mode=$MODE"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="${OUTPUT_DIR}/CafeBeta_PickupTable_${FLAVOR}_${APP_VERSION}.apk"
cp -f "$SOURCE_APK" "$OUTPUT_FILE"

echo "APK exported: $OUTPUT_FILE"
