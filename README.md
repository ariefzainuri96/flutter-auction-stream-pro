# Stadeo Flutter

This is the Flutter project for Stadeo, supporting multiple environments (staging and production).

## Environment Setup

Before running the project, make sure to follow the environment setup below:

1. **Environment Files**

    Place the following files in the project root (same level as `lib/`):
    - `.env.stage` (staging values)
    - `.env.prod` (production values)

    You can use the provided `.env.example` as a starting point — copy it and fill in real values.

2. **Running the Project**

```
sh fvm_run_script.sh [staging | prod] [debug | release]
sh fvm_build_script.sh [android | ios] [staging | prod] [apk | appbundle]
```

## Errors

a. if you find error related to JAVA_HOME that not match with your current installed jdk version like below:

ERROR: JAVA_HOME IS SET to an invalid directory: C:\Program Files\OpenLogic\jdk-17.0.8.7-hotspot
Please set the JAVA_HOME variable in your environment to match the location of your Java installation.

b. To change the current JDK, please run and adjust with your installed jdk path: `flutter config --jdk-dir="C:\Program Files\Java\jdk-21"`

3. **Build the Project**

## before build, please do below command

`dart fix --apply --code=unused_import`

Use the following command to run the project for the desired environment:

`sh fvm_build_script.sh [android | ios] [staging | prod] [apk | appbundle]`

-`staging` — Runs the app with `.env.stage` -`prod` — Runs the app with `.env.prod`

## Notes

-Ensure the `.env` files contain all required environment variables.
-The `run_script.sh` script is responsible for configuring the correct environment and launching the project.

## Localization

- This project uses Flutter's built-in localization (ARB + `flutter gen-l10n`).
- English (`en`) and Indonesian (`id`) ARB files are under `lib/l10n/`.
- The generated localization files are placed in `lib/generated/`.

To regenerate localization after editing ARB files run:

```bash
fvm flutter gen-l10n
```
