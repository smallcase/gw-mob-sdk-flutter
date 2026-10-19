#!/usr/bin/env bash
# Fails if a release pin is a prerelease (internal) native build. Runs on PRs into main and before every pub.dev publish.
set -euo pipefail
cd "$(dirname "$0")/.."

if grep -nE 'native-sdk:' scgateway/android/build.gradle loans/android/build.gradle \
  scgateway/ios/scgateway_flutter_plugin.podspec loans/ios/scloans.podspec | grep -E -- "[0-9]+\.[0-9]+\.[0-9]+-"; then
  echo '::error::Release pins above are internal native builds. Pin production native versions before a pub.dev release.'
  exit 1
fi
echo 'All native pins are production versions.'
