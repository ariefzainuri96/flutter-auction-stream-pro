#!/bin/sh

# --- ARGUMENT VALIDATION ---

# Script name for usage message
SCRIPT_NAME=$(basename "$0")

# Missing environment argument ($1)
if [ -z "$1" ]; then
  echo "Missing arguments: [staging|prod] [debug|release]"
  echo "Usage: $SCRIPT_NAME [staging|prod] [debug|release]"
  exit 128
fi

# Missing mode argument ($2)
if [ -z "$2" ]; then
  echo "Missing mode argument: [debug|release]"
  echo "Usage: $SCRIPT_NAME [staging|prod] [debug|release]"
  exit 128
fi

# Validate environment argument ($1)
ENV=$1
case "$ENV" in
"staging"|"prod")
  # Environment is valid, continue
  ;;
*)
  echo "Invalid environment argument: $ENV"
  echo "Must be one of [staging|prod]"
  exit 1
  ;;
esac

# Validate mode argument ($2)
MODE=$2
case "$MODE" in
"debug"|"release")
  # Mode is valid, continue
  ;;
*)
  echo "Invalid mode argument: $MODE"
  echo "Must be one of [debug|release]"
  exit 1
  ;;
esac

# --- COMMAND EXECUTION ---

echo "Starting Flutter in $MODE mode for $ENV environment..."

# Determine the Flutter command flags
FLUTTER_MODE_FLAG=""
if [ "$MODE" = "release" ]; then
  # For release mode, we add the --release flag
  FLUTTER_MODE_FLAG="--release"
fi
# Note: For 'debug' mode, we leave the flag empty as 'fvm flutter run' defaults to debug.

# Build the final command
# We combine the run, flavor, dart-define, and the calculated mode flag
BASE_COMMAND="fvm flutter run --flavor $ENV --dart-define ENV=$ENV $FLUTTER_MODE_FLAG"

# Execute the command, filtering out the common verbose Android logs
eval "$BASE_COMMAND | grep -v -e \"E/FrameEvents\" -e \"E/Camera-JNI\""

# === end of code ===