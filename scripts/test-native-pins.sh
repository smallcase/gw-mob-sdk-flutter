#!/usr/bin/env bash
# Self-check for apply-native-pins.sh and pin-guard.sh. Restores the pin files on exit.
set -uo pipefail
cd "$(dirname "$0")/.."
files=(scgateway/android/build.gradle loans/android/build.gradle scgateway/ios/scgateway_flutter_plugin.podspec loans/ios/scloans.podspec)
backup=$(mktemp -d)
tar -cf "$backup/pins.tar" "${files[@]}"
trap 'tar -xf "$backup/pins.tar"; rm -rf "$backup"' EXIT

fail() { echo "FAIL: $*"; exit 1; }
run() { scripts/apply-native-pins.sh "$@" >/dev/null 2>&1; }

scripts/pin-guard.sh >/dev/null || fail 'guard rejects committed pins'
run android-scg=9.8.7 ios-loans=1.2.3 || fail 'valid pins'
grep -q "com.smallcase.gateway:sdk:9.8.7' // native-sdk: android-scg" scgateway/android/build.gradle || fail 'android-scg not written'
grep -q "'SCLoans', '1.2.3' # native-sdk: ios-loans" loans/ios/scloans.podspec || fail 'ios-loans not written'
mkdir "$backup/orig" && tar -xf "$backup/pins.tar" -C "$backup/orig"
changed=$(for f in "${files[@]}"; do diff "$backup/orig/$f" "$f"; done | grep -c '^>')
[ "$changed" = 2 ] || fail "expected 2 changed lines, got $changed"
scripts/pin-guard.sh >/dev/null || fail 'guard rejects release pins'
run ios-scg=7.3.1-rc.1645 || fail 'prerelease pin'
scripts/pin-guard.sh >/dev/null 2>&1 && fail 'guard accepts a prerelease pin'
run bogus=1.0.0 && fail 'unknown key accepted'
run android-loans='1.0.0;rm -rf /' && fail 'bad version accepted'
run android-loans=latest && fail 'non-semver accepted'
echo 'native pin checks passed'
