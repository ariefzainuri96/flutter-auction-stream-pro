#!/bin/sh

# Check arguments
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 [android|ios] [staging|prod] [apk|appbundle]"
  exit 128
fi

PLATFORM=$1
ENV=$2
BUILD_TYPE=$3

# Validate environment
case "$ENV" in
  "staging") echo "Environment: staging" ;;
  "prod") echo "Environment: prod" ;;
  *)
    echo "Invalid environment. Use [staging|prod]"
    exit 1
  ;;
esac

# Validate platform
case "$PLATFORM" in
  "android") echo "Platform: android" ;;
  "ios") echo "Platform: ios" ;;
  *)
    echo "Invalid platform. Use [android|ios]"
    exit 1
  ;;
esac

# Validate build type
case "$BUILD_TYPE" in
  "apk") echo "Build type: APK" ;;
  "appbundle") echo "Build type: App Bundle" ;;
  *)
    echo "Invalid build type. Use [apk|appbundle]"
    exit 1
  ;;
esac

# Common build steps
fvm flutter clean
fvm flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Platform-specific build
if [ "$PLATFORM" = "android" ]; then
  if [ "$BUILD_TYPE" = "apk" ]; then
    fvm flutter build apk --release --flavor "$ENV" --dart-define ENV="$ENV"
  elif [ "$BUILD_TYPE" = "appbundle" ]; then
    fvm flutter build appbundle --release --flavor "$ENV" --dart-define ENV="$ENV"
  fi
elif [ "$PLATFORM" = "ios" ]; then
  cd ios
  pod install
  cd ..
  fvm flutter build ipa --release --flavor "$ENV" --dart-define ENV="$ENV"
fi
