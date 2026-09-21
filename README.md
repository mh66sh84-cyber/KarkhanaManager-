# Karakhana — GitHub APK / AAB build package

## Current status
This is source plus a build workflow, NOT a compiled APK or AAB. No GitHub build has run.
The uploaded source implements email sign-up, sign-in, password reset and sign-out only.
Business profiles, workers, ledger entries, settlements and PDF exports are not implemented.
Firebase configuration and an upload signing key were not included in the uploaded ZIP.
Building an AAB does not complete these features or establish Play Store readiness.

## Mobile / GitHub steps
1. Use your Karakhana repository. Extract this ZIP and place its CONTENTS at the repository
   root, including `.github/workflows/android.yml`. Uploading this ZIP alone does not run it.
2. Open Settings > Secrets and variables > Actions. Add the required secrets below.
3. Open Actions > Karakhana APK and AAB > Run workflow.
4. Enter your app ID prefix. The full generated ID is PREFIX.karakhana_ledger.
   For an existing application, preserve the exact existing ID and signing identity.
   If its ID has a different suffix, the project generator must be adapted first.
5. Choose debug for a test APK or release for a signed APK and AAB. Enter a version code
   higher than every previous upload for this app. Start at 1 only for a new application.
6. After the run succeeds, download the APK/AAB from the run's Artifacts section.

The workflow is manual. It does not publish to Google Play or create a public GitHub release.
No keystore or passwords are included in artifacts. Do not commit signing files or passwords.

## Firebase
Download google-services.json for the matching Android app from your Firebase project.
Store its complete JSON text as the GOOGLE_SERVICES_JSON repository Actions secret.
Enable Email/Password in Firebase Authentication.
The build script creates Dart FirebaseOptions from that JSON. This package uses explicit
Firebase initialization and does not need a Google Services Gradle plugin for email login.
Do not supply a service-account private key; that is a different file.
Without Firebase, debug mode builds only a setup-required screen. Release mode stops.
Existing Firestore rules remain restrictive; the workflow does not deploy database rules.

## Release signing secrets
| Secret | Value |
| --- | --- |
| GOOGLE_SERVICES_JSON | Full Firebase Android configuration JSON |
| ANDROID_KEYSTORE_BASE64 | Base64 of your upload keystore |
| ANDROID_KEYSTORE_PASSWORD | Keystore password |
| ANDROID_KEY_ALIAS | Signing key alias |
| ANDROID_KEY_PASSWORD | Key password |

If updating an existing app, use its existing upload key or the key registered with Play.
For a NEW app only, create an upload key on your own trusted computer with Java installed:

```sh
keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

The command asks for passwords and certificate details interactively. Keep a private backup
of the keystore and passwords for future updates. Encode the keystore using Python:

```sh
python3 -c "import base64,pathlib; pathlib.Path('upload-keystore.base64').write_text(base64.b64encode(pathlib.Path('upload-keystore.jks').read_bytes()).decode())"
```

Paste the base64 file contents into ANDROID_KEYSTORE_BASE64. Never upload either key file
into the repository or share passwords in chat.

## Build behavior and verification limits
GitHub installs Java 17 and Flutter stable, generates the official Android project,
installs the source dependencies, adds release INTERNET permission and sets minimum SDK
at least 23 without lowering Flutter's default. Release mode replaces debug signing with
the supplied upload key and refuses to continue without Firebase and signing secrets.
It runs flutter analyze, then flutter build apk and flutter build appbundle for release.
Only the requested outputs and dependency lock are uploaded as build artifacts.
The source scripts and configuration paths were checked locally with synthetic fixtures;
Flutter/Android compilation, real Firebase login and device behavior remain unverified.
Flutter and Firebase versions are resolved at build time. Retain the generated lock artifact
and pin tool/dependency versions after the first successful build if repeatability is needed.
The upload source's original documentation is preserved in ORIGINAL_README.md; its phone
and iOS instructions do not describe the current Android/email build workflow.

## اگلا قدم
اپنی Karakhana GitHub repository کا لنک دیں اور اس repository کا access منسلک کریں۔
یہ ZIP ابھی APK یا AAB نہیں ہے۔ اصل بلڈ GitHub Actions پر چلنے کے بعد ملے گا۔
Firebase کی اصل configuration کے بغیر لاگ اِن کام نہیں کرے گا۔

## References
- Flutter Android build and signing: https://docs.flutter.dev/deployment/android
- Flutter GitHub action: https://github.com/subosito/flutter-action
