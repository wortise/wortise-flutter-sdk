# Wortise Flutter plugin

pub.dev package `wortise`. Wraps the Android SDK (`android/build.gradle` pin) and the iOS SDK (`ios/wortise.podspec` **and** `ios/wortise/Package.swift` pins, which must always be equal). Sample app: `../wortise-flutter-sample`.

The `wortise-sdk` agent plugin (repo `wortise/wortise-sdk-agent`) holds the full context: how this repo relates to the other SDKs and plugins, versioning, branches, and the release procedure (`wortise-release` skill). Read it before releasing or making cross-platform changes.

## Commands

```bash
flutter analyze
flutter pub publish --dry-run
```

## Rules

- Remote `origin` (GitHub) only; never push to `gitlab`.
- Method channel names and methods must stay identical on Android and iOS.
- Version: `pubspec.yaml` (keep `android/build.gradle` and the podspec `s.version` equal to it); every release adds a `CHANGELOG.md` entry and a git tag.
- Branch flow: `support/*` or `feature/*` -> PR into `test` -> pre-releases (git tags) from `test` -> `master` for finals (pub.dev).
- Never publish or push without the maintainer's OK.
