---
summary: Reproduce the public Proton Pass Simulator checks and understand their release-coverage limits.
read_when:
  - Running or changing the skills showcase workflow
  - Interpreting the evidence for Proton Pass 1.23.0
---

# Proton Pass skills example

This is an independent testing example using Proton's GPL-licensed source. It is
not an official Proton build or endorsement. The original license and attribution
remain in the repository.

The app source is tag `1.23.0` (`bd22de62d53815d04feeee2da91c9478e71530a0`).
Release context compares tag `1.22.1`
(`6aa48ae7f18cb912ee87bc4f4a5581cc76318c07`) to that source. The checked-in
scenario is deterministic and needs no LLM API key. Live Claude planning has not
been tested for this example.

## Run locally

Use Xcode 27.1 and a dedicated iOS 27.0 Simulator. Set `DEVELOPER_DIR` to your
Xcode installation, `AI_UI_SIMULATOR_UDID` to that Simulator, and optionally
`AI_UI_DERIVED_DATA_PATH` to a directory with enough space for the dependencies
and app build. The first build downloads several large public binary packages.

```bash
bash scripts/skills-build-for-testing.sh
bash scripts/run-ai-ui-scenario.sh .github/ai-ui/verify-primary-flow.json
```

The scenario uses the app's existing `RunningInUITests` argument, which invokes
its logout/reset hook and disables animations. Use an isolated, signed-out test
Simulator; the hook can log out an existing account. It
asserts the welcome controls, opens the real native sign-in form, and closes it
to verify the return path. It never enters credentials or submits a login.

The build helper downloads the upstream checksum-pinned Rust package using
macOS's `curl`. The app's resolved Swift package graph is committed. It uses
command-scoped authorization for the reviewed ProtonCore lint plugin and
localized-string macro, disables automatic source formatting for this check,
and preserves App Group entitlements through Simulator ad hoc signing. Disabling
code signing entirely builds successfully but crashes at startup because the
app cannot access its App Group container. The Simulator application identifier
prefix also matches Proton's checked-in keychain group prefix; no signing
certificate or Apple account is used.

`SkillsLocalBuild` builds the real app and extensions plus `SkillsPublicUITests`.
It excludes upstream scheme actions affecting other Simulators and the private
upstream UI-test target. No AXe or external UI inspector is required.

## Verified local results

On November 5, 2026, Xcode 27.1 on an iPhone 18 Pro Simulator running iOS 27.0
produced a passing app test build, one passing UI scenario, and five passing PRF
model tests (zero failures or skips). The UI action scripts captured three
screenshots, video, the exact tag comparison and an XCTest result bundle.
GitHub-hosted execution is a separate check.

## Read the results

The scenario provides baseline navigation coverage. Its success alone does not
verify the 1.23.0 changelog. Keep these coverage boundaries explicit:

| Change | Public verification path | Coverage limit |
| --- | --- | --- |
| Welcome and sign-in navigation | Checked-in XCTest scenario | Signed-out baseline; no authenticated session |
| Passkey PRF support | Existing `PasskeyAssertionPrfInputTests` and `DataHmacSecretSaltTests` | Model logic; no physical passkey ceremony |
| Credential Exchange Protocol | Existing CXP package tests and authenticated system import/export | Not yet run by this example |
| Ignoring password issues | Feature-flagged authenticated vault flow | Not yet run by this example |
| Exact-subdomain manual autofill | Existing matching tests plus OS autofill flow | Not yet run by this example |
| Alias counter and attachment previews | Authenticated vault/attachment flows | Not yet run by this example |
| Rust synchronization migration | Client synchronization tests and authenticated sync | Not yet run by this example |

Retain the logs, scenario, source comparison, screenshots, video and `.xcresult`
from each run. Initial setup failures and corrected runs are separate evidence.
A green check covers only the selected tests that actually executed.

The reusable action also supports optional provider, model and effort settings;
see its [planner configuration](https://github.com/Kofiloski/ios-ai-ui-check/blob/v0.6.0/docs/planner-configuration.md).
