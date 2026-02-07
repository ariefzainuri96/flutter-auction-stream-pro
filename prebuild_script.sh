#!/bin/sh

# Missing arguments
if [ -z "$1" ]; then
  echo "Missing arguments: [staging|prod]"
  exit 128
fi

# Invalid arguments
case "$1" in
"staging") echo "Running staging"
;;
"prod") echo "Running prod"
;;
*)
  echo "Invalid arguments [staging|prod]"
  exit 1
;;
esac

eval "flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs && ./run_script.sh $1"