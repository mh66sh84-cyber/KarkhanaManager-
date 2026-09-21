"""Configure a freshly generated Flutter Android project without exposing secrets."""
import base64
import json
import os
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / 'karakhana_ledger'
SIGNING = ['ANDROID_KEYSTORE_BASE64', 'ANDROID_KEYSTORE_PASSWORD',
           'ANDROID_KEY_ALIAS', 'ANDROID_KEY_PASSWORD']


def validate():
    org = os.environ.get('APP_ORG', '')
    if not re.fullmatch(r'[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)+', org):
        raise ValueError('Supply a valid app ID prefix, such as com.yourbusiness.')
    mode = os.environ.get('BUILD_MODE', '')
    if mode not in ('debug', 'release'):
        raise ValueError('Build mode must be debug or release.')
    number = os.environ.get('BUILD_NUMBER', '')
    if not number.isascii() or not number.isdigit() or not 0 < int(number) <= 2100000000:
        raise ValueError('Build number must be an integer from 1 to 2100000000.')
    if mode == 'release':
        if org == 'com.example' or org.startswith('com.example.'):
            raise ValueError('Choose your permanent application ID before release.')
        missing = [key for key in ['GOOGLE_SERVICES_JSON', *SIGNING]
                   if not os.environ.get(key)]
        if missing:
            raise ValueError('Add repository Actions secrets: ' + ', '.join(missing))
    raw = os.environ.get('GOOGLE_SERVICES_JSON', '')
    options = None
    if raw:
        try:
            data = json.loads(raw)
            package = org + '.karakhana_ledger'
            client = next(c for c in data['client'] if
                          c['client_info']['android_client_info']['package_name'] == package)
            info = data['project_info']
            options = dict(apiKey=client['api_key'][0]['current_key'],
                           appId=client['client_info']['mobilesdk_app_id'],
                           messagingSenderId=info['project_number'],
                           projectId=info['project_id'])
            if info.get('storage_bucket'):
                options['storageBucket'] = info['storage_bucket']
            if not all(isinstance(v, str) and v.strip() for v in options.values()):
                raise ValueError()
        except (ValueError, KeyError, StopIteration, IndexError, TypeError):
            raise ValueError('GOOGLE_SERVICES_JSON is invalid or does not match the app ID.') from None
    elif mode == 'debug':
        print('::warning::Firebase is missing. This test APK will only show the setup-required screen.')
    return mode, options


def dart_string(value):
    return json.dumps(value, ensure_ascii=True).replace('$', r'\$')


def configure(mode, options):
    manifest = PROJECT / 'android/app/src/main/AndroidManifest.xml'
    xml = manifest.read_text()
    if 'android.permission.INTERNET' not in xml:
        xml = xml.replace('</manifest>', '    <uses-permission android:name="android.permission.INTERNET"/>\n</manifest>')
    xml = re.sub(r'android:label="[^"]*"', 'android:label="Karakhana Ledger"', xml, count=1)
    manifest.write_text(xml)
    gradle = PROJECT / 'android/app/build.gradle.kts'
    text = gradle.read_text()
    text, count = re.subn(r'minSdk\s*=\s*flutter\.minSdkVersion',
                         'minSdk = maxOf(23, flutter.minSdkVersion)', text)
    if count != 1:
        raise ValueError('Unexpected Flutter Gradle template: review minSdk before building.')
    if mode == 'release':
        encoded = ''.join(os.environ['ANDROID_KEYSTORE_BASE64'].split())
        try:
            key = base64.b64decode(encoded, validate=True)
            if not key:
                raise ValueError()
        except ValueError:
            raise ValueError('ANDROID_KEYSTORE_BASE64 is not a valid encoded keystore.') from None
        path = PROJECT / 'android/app/upload-keystore.jks'
        path.write_bytes(key)
        path.chmod(0o600)
        signing = '''signingConfigs {
        create("release") {
            storeFile = file("upload-keystore.jks")
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
        }
    }

    buildTypes {'''
        if text.count('buildTypes {') != 1:
            raise ValueError('Unexpected Flutter Gradle template: review buildTypes.')
        text = text.replace('buildTypes {', signing, 1)
        text, count = re.subn(r'signingConfig\s*=\s*signingConfigs.getByName\("debug"\)',
                             'signingConfig = signingConfigs.getByName("release")', text)
        if count != 1:
            raise ValueError('Refusing release: could not replace default debug signing.')
    gradle.write_text(text)
    if options:
        fields = '\n'.join(f'    {k}: {dart_string(v)},' for k, v in options.items())
        (PROJECT / 'lib/firebase_options.dart').write_text(
            "import 'package:firebase_core/firebase_core.dart';\n\n"
            'class DefaultFirebaseOptions {\n'
            '  static const currentPlatform = FirebaseOptions(\n' + fields + '\n  );\n}\n')
    print('Android configuration complete. Secrets have not been printed.')


if __name__ == '__main__':
    try:
        mode, options = validate()
        if '--check' not in sys.argv:
            configure(mode, options)
    except (ValueError, OSError) as error:
        print(f'::error::{error}')
        sys.exit(1)
