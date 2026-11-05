#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
: "${AI_UI_SIMULATOR_UDID:?Select a dedicated test Simulator first}"
DERIVED_DATA_PATH="${AI_UI_DERIVED_DATA_PATH:-$ROOT_DIR/.derivedData/ai-ui}"

# Keep the upstream version/checksum checks, without installing a downloader.
bash scripts/public/download_rust_package.sh

# The pinned ProtonCore lint plugin and localized-string macro were reviewed.
# Ad hoc signing retains App Group entitlements required at app startup.
export SKIP_SWIFTFORMAT=1
xcodebuild build-for-testing \
  -project ProtonPass.xcodeproj -scheme SkillsLocalBuild -configuration Debug-QA \
  -destination "platform=iOS Simulator,id=$AI_UI_SIMULATOR_UDID,arch=$(uname -m)" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile \
  -packageAuthorizationProvider netrc \
  -skipPackagePluginValidation -skipMacroValidation \
  -jobs 2 -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM=2SB5Z68H26 AppIdentifierPrefix=2SB5Z68H26. \
  PROVISIONING_PROFILE_SPECIFIER= COMPILER_INDEX_STORE_ENABLE=NO
