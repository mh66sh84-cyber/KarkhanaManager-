"""Generate official Android/iOS shells, then install the Step 1 source.
Usage: python create_project.py --org com.yourcompany
Requires Flutter on PATH. Does not overwrite an existing project.
"""
import argparse
from pathlib import Path
import re
import shutil
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--org', required=True, help='Your reverse-domain identifier')
args = parser.parse_args()
if not re.fullmatch(r'[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)+', args.org):
    parser.error('Use a reverse-domain identifier, for example com.yourcompany')
flutter = shutil.which('flutter')
if not flutter:
    raise SystemExit('Install Flutter and add it to PATH first. See README.md.')
source = Path(__file__).resolve().parent
target = source / 'karakhana_ledger'
if target.exists():
    raise SystemExit('karakhana_ledger already exists. Use a fresh extracted folder; existing code was not changed.')

def run(command):
    subprocess.run(command, cwd=source, check=True)

run([flutter, 'create', '--platforms=android', '--org', args.org,
     '--project-name', 'karakhana_ledger', str(target)])
# Remove only the generated counter-app test, which no longer describes this app.
(target / 'test' / 'widget_test.dart').unlink(missing_ok=True)
shutil.copytree(source / 'lib', target / 'lib', dirs_exist_ok=True)
for name in ['firebase.json', 'firestore.rules', 'firestore.indexes.json', 'ARCHITECTURE.md']:
    shutil.copy2(source / name, target / name)
subprocess.run([flutter, 'pub', 'add', 'firebase_core', 'firebase_auth',
                'cloud_firestore'], cwd=target, check=True)
print('Created:', target)
print('Next: follow README.md to run flutterfire configure and deploy rules.')
