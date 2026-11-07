---
summary: Reproduce the public Proton Pass Simulator checks and understand their release-coverage limits.
read_when:
  - Running or changing the skills showcase workflow
  - Comparing upstream releases and reviewing generated UI test reports
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
The [GitHub-hosted run](https://github.com/Kofiloski/ios-pass/actions/runs/42133167432)
also passed: one UI test and five PRF model tests, with zero failures/skips.
Downloaded result bundles verify both counts and the exact source comparison.

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

## Release-diff regressions

The separate `skills-release-regression.yml` workflow resolves stable upstream iOS
tags, compares the exact previous/new commits, builds and inspects the compared
head, then generates new JSON scenarios tied to changed files. Each generated
case runs through native XCTest; empty/skipped test selections cannot pass.
Uncovered or unreachable changes remain explicit in the report. The baseline
workflow above still replays a fixed scenario and is separate evidence.

Set a repository secret `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, or the explicit
provider-neutral `AI_UI_PLANNER_API_KEY`. Configure provider/model/effort with the
manual inputs or `AI_UI_PLANNER_*` repository variables. A compatible endpoint
uses `AI_UI_PLANNER_BASE_URL` and its own neutral key. Keys are never borrowed
from another provider. No model keys are currently configured in this fork.

Run the workflow manually first. Missing credentials or incomplete planning,
builds or native execution produce a blocked/failing report; there is no fixed
baseline fallback. This frozen reference has no scheduled trigger and keeps
`ENABLE_RELEASE_CHECKS=false`. Resuming recurring checks requires a reviewed
schedule change as well as the variable and a verified live planner run. First discovery
starts at the latest pair instead of backfilling the entire catalog. Subsequent
new tags, including hotfixes, enter a persisted queue. Manual `head_tag` and
`base_tag` inputs replay historical pairs; older toolchains or harness conflicts
are reported as blocked. Use `force` or an explicit tag to retry repaired runs.

Reports and full diagnostic evidence are immutable attempt assets under this
fork's `ui-check-*` GitHub releases, independent of Actions artifact retention.
`ui-check-state` stores discovery state. These are test reports, not upstream
app releases. Build/inspect/test jobs have read-only repository permissions and
no model key; model planning occurs in a separate Ubuntu job that never runs app
code. Only the history job can publish reports. The workflow does not post to
upstream issues or PRs.

The app profile in `.github/ai-ui/release-profile.json` owns stable tag filters,
the source seed for the harness overlay, reviewed launch presets, and build/test
configuration. A changed upstream project may require a reviewed profile update.
No live provider generation or full release-flow execution has been verified yet.

The [credential-gate run on November 6, 2026](https://github.com/Kofiloski/ios-pass/actions/runs/42296867037)
resolved 1.22.1 → 1.23.0, skipped the macOS/planning/execution jobs, and
[archived a blocked report and evidence](https://github.com/Kofiloski/ios-pass/releases/tag/ui-check-94f7317ae4b18a6ae622).
The final coverage gate failed deliberately. This verifies missing-key handling
and historical publication; it does not establish generated UI coverage.

## Maintenance status

This fork became a frozen integration reference on November 7, 2026. Its source
snapshot and historical native evidence remain available, and manual checks can
still be run. The scheduled release trigger is removed and
`ENABLE_RELEASE_CHECKS=false`; current upstream releases are not followed
automatically. DuckDuckGo is the active behavioral flagship. This does not
reclassify the existing baseline as generated release coverage.

## Permanent native evidence

The [verified baseline bundle](https://github.com/Kofiloski/ios-pass/releases/tag/skills-baseline-42133167432) preserves the
original native result bundles, scenario, logs and recording, with source, harness
and action revisions. Asset hashes and the native result counts were verified
before publication. These fixed baseline records remain separate from live
model-generated release tests.
