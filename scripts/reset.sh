#!/usr/bin/env bash

set -euo pipefail

# Resolve repo root (scripts/..)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Repo root: ${REPO_ROOT}"

clean_flutter_pkg() {
  local pkg_dir="$1"
  if [[ ! -d "${pkg_dir}" ]]; then
    return 0
  fi

  echo "\n==> Cleaning ${pkg_dir}"

  # Generic Flutter/Dart
  rm -rf "${pkg_dir}/build" \
         "${pkg_dir}/.dart_tool" \
         "${pkg_dir}/pubspec.lock" || true

  # Android bits (delete only)
  if [[ -d "${pkg_dir}/android" ]]; then
    rm -rf "${pkg_dir}/android/build" \
           "${pkg_dir}/android/.gradle" \
           "${pkg_dir}/android/.cxx" || true
  fi

  # iOS bits (delete only)
  if [[ -d "${pkg_dir}/ios" ]]; then
    rm -rf "${pkg_dir}/ios/Pods" \
           "${pkg_dir}/ios/Podfile.lock" \
           "${pkg_dir}/ios/.symlinks" \
           "${pkg_dir}/ios/Flutter/Flutter.podspec" \
           "${pkg_dir}/ios/Flutter/ephemeral" || true
  fi

  # macOS bits (delete only)
  if [[ -d "${pkg_dir}/macos" ]]; then
    rm -rf "${pkg_dir}/macos/Pods" \
           "${pkg_dir}/macos/Podfile.lock" || true
  fi
}

flutter_pub_get() {
  local pkg_dir="$1"
  if [[ -d "${pkg_dir}" ]]; then
    echo "\n==> Getting dependencies in ${pkg_dir}"
    (cd "${pkg_dir}" && flutter pub get)
  fi
}

#!/usr/bin/env bash

# Packages in this monorepo
SCGATEWAY_DIR="${REPO_ROOT}/scgateway"
LOANS_DIR="${REPO_ROOT}/loans"
SMART_INVESTING_DIR="${REPO_ROOT}/smart_investing"

echo "\n=== Cleaning packages ==="
clean_flutter_pkg "${SCGATEWAY_DIR}"
clean_flutter_pkg "${LOANS_DIR}"
clean_flutter_pkg "${SMART_INVESTING_DIR}"

echo "\nDone. Next steps (run manually as needed):"
echo "  - cd scgateway && flutter pub get"
echo "  - cd loans && flutter pub get"
echo "  - cd smart_investing && flutter pub get && flutter run"


