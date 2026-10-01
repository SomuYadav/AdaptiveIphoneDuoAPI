# AdaptiveDuoLab

SwiftUI and SwiftData demo with native **Workspace**, **Review**, and **Settings** tabs. The same app now contains interactive API examples for layout, native toolbars, tabs, presentations, UIKit and camera accessories.

## Open the project

Extract the ZIP, open the included workspace, and choose the `AdaptiveDuoLab` scheme:

```bash
cd /path/to/AdaptiveDuoLab
open AdaptiveDuoLab.xcworkspace
```

The included Xcode project references the new files. Tuist regeneration also includes them through `Sources/**`. **Use Xcode 26 or later with the iOS 26 SDK** for the baseline build because the existing panels use `glassEffect`. The deployment target remains iOS 17; material and tab-item fallbacks support older systems. The opt-in native Duo examples require **Xcode 27.1 with the iOS 27.1 SDK** and run on iOS 27.1 or later.

## Integrated changes

- `RootView` owns native tabs plus selected tab, category, content mode and preview pose. The iOS 18+ branch uses `Tab`; the iOS 17 fallback uses `tabItem` and stable tags.
- Workspace keeps `NavigationSplitView` and the dashboard. Review uses the same local audit content as the modal sheet. Settings changes the actual shared category, mode and pose.
- `AdaptiveDuoLabApp` retains one SwiftData container above all destinations. No per-tab database or reseeding was introduced.
- Layout Review still opens a modal with Done. Tabs select destinations; the review action opens the sheet.
- The header stacks title/actions and controls when needed. A native Layout menu replaces three mode buttons when their width cannot fit.
- Short content heights below 520 points and XXX Large text or larger use compact native toolbar controls instead of the tall header, leaving the record collection room to scroll.
- The simulated book requires at least 280 points of card width in each region. Narrower local detail areas use one collection containing all filtered records. This is a sample content-fit rule, not an Apple breakpoint.
- Generated project deployment settings now match the manifest at iOS 17. The uploaded generated app target had required iOS 27.
- Settings opens **API Lab**, with **8 interactive routes and 25 catalog entries** showing versions, source locations, implementation status and behavior on other iPhones.
- Reflow and corner examples contain editable state, an `AnyLayout` transition, a `ConcentricRectangle` comparison and a UIKit view with independent safe-area edges, `UICornerConfiguration` and split navigation.
- Toolbar sessions exercise overflow, priority, axis preferences, minimization, compression, preferred-edge reads and vertical-bar preferences. Review, Pin, Add and Reverse order change local session state rather than being decorative controls.
- Tab and presentation examples preserve their drafts while destinations or presentation geometry change. The tab example can prefer a sidebar; sheet, popover, alert and menu controls perform concrete local actions.
- The camera example starts a real rear-camera preview only after **Start camera**. Its optional `CameraCaptureAccessory` shares an interactive speaker prompt when the system reports availability. No photo, audio, recording or save output is configured.
- The system-layout example uses the selected category's real records. Native arrangement, reserved-region and hinge behavior is separate from Workspace's explicitly simulated pose previews.
- At accessibility text sizes the workspace uses one column and one continuous region. Short tabletop windows fall back to the regular collection. Cards expose full title/summary text and metadata can stack.

Preview poses affect content composition. Native containers let the system choose supported tab-bar placement. A pose menu does not force vertical bars or establish a physical posture.

## Run and test on your Mac

The scripts build the included project by default. Set `DEVICE_ID` for an exact Simulator, or `DEVICE_NAME` for a name match. Set `REGENERATE_PROJECT=1` to regenerate with Tuist on your PATH.

```bash
./Automation/run-demo.sh -demo-tab Review -demo-presentation Grid
./Automation/run-tests.sh
```

Enable the native examples using the matching SDK and an installed Simulator:

```bash
DEVICE_ID="your-simulator-udid" ./Automation/run-api-demos.sh
```

This shortcut enables `DUO_SDK` and opens Settings; the shared launcher checks the SDK. The equivalent explicit command and native tests are:

```bash
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-demo.sh -demo-tab Settings
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-tests.sh
```

Set `DEVELOPER_DIR` if more than one Xcode is installed. The scripts check SDK versions before building and append `DUO_SDK` to `SWIFT_ACTIVE_COMPILATION_CONDITIONS` for the opt-in build. To run directly in Xcode, add `DUO_SDK` to **Active Compilation Conditions** for the intended configuration, preserving existing values. Remove it to build with an older SDK. The native branch also checks the running OS version; enabling the flag alone does not create hardware capabilities.

Launch arguments:

```text
-demo-tab Workspace|Review|Settings
-demo-pose "Current Window"|"Outer Portrait"|"Outer Landscape"|"Inner Open"|"Book Fold"|Tabletop
-demo-presentation Automatic|List|Grid
-show-audit
-ui-testing
-reset-data
```

Quote values containing spaces. `-ui-testing` uses an in-memory store; `-reset-data` resets the demo records.

## Tab walkthrough

1. In Workspace, choose Grid. Open the Layout menu if direct mode buttons do not fit.
2. Open Review and inspect the current category, mode, pose and record count.
3. In Settings, select Research, List and Book Fold. Research has two seeded records.
4. Return to Review and Workspace. Confirm the same values remain selected.
5. Resize the detail area. Book Fold uses one collection until two readable regions fit.
6. Open and dismiss Layout Review, then switch tabs again.
7. Run this flow on an ordinary iPhone and the target Duo runtime, including accessibility text, VoiceOver and right-to-left layout.

## API Lab walkthrough

1. Open **Settings → Open API Lab**. Read the distinction between native container adaptation, app layout decisions and Xcode skills.
2. Open **Reflow and concentric corners**. Edit the task, change completion and switch to a vertical layout. Resize or increase text size. On iOS 26+, vary the inset and compare concentric with fixed corners.
3. Open **UIKit layout and navigation**. Compare **None**, **Left +44** and **Right +44** safe-area test insets. Change the corner inset, then **Open UIKit tabs and split navigation** and edit a Topics draft while resizing. The added insets are explicitly controlled test values.
4. Open **SwiftUI toolbar actions**, choose preferences and launch a session. Review, Pin, reverse order or add a record; inspect the resulting state. Native settings require `DUO_SDK` and iOS 27.1. The baseline preview uses ordinary system toolbar items and does not simulate new APIs. Also open **UIKit toolbar actions** to compare native UIKit actions, overflow, axis/priority/compression settings and the preferred-edge readout.
5. In **Tabs and sidebar**, choose the preference and **Open tab example**. Edit the note, switch to Summary and resize. Reopen a session after changing its placement preference. The system chooses supported placement; no side rail is fabricated.
6. Open **Sheets and presentations**. Edit a sheet draft, show a popover, show an alert and use Actions. Verify the parent view retains its local draft and action result.
7. In **Camera accessory**, tap **Start camera** on a physical device and grant access. Try **Next prompt**. If the native system reports accessory availability, enable **Show speaker prompt on accessory display**. The main preview and controls remain usable without an accessory. Missing hardware or denied permission produces an explanatory status; camera output is never simulated.
8. Open **System layout and regions**. With the native build, use **System layout details → Overlay arrangement** to change the completed-only filter, or **Move a custom control** to place Review clear of active regions. The region frame already includes interactive margins; they are not added twice. If no safe position fits, use Review in the toolbar. The baseline path shows a continuous list. Empty region results and absent hinge information are valid on ordinary iPhones.
9. Select API inventory rows for the exact source, availability and fallback. These examples live inside this project; they are not a migration of every Workspace screen.

See [API adoption guide](Docs/API_Adoption_Guide.md) for the full implementation map and [Apple App Resizability workflow](Docs/Apple_App_Resizability_Workflow.md) for the project-wide agent prompt.

## Validation status

The project contains **17 unit tests** (10 layout-policy tests and 7 reserved-region placement tests) and **7 UI tests**. New cases cover region geometry, editable layout state during rotation, toolbar state across reopening and camera capture initially off. Existing journeys cover shared app state and API Lab navigation; they do not validate every native API or camera capability. **No Xcode build or Simulator tests ran in this Linux environment.** Run baseline and native-enabled builds/tests on your Mac before presenting. Earlier reported passes do not apply to this revision.

The review uses local rules. There is no live AIHubServices client. API Lab now contains executable examples, including toolbar and camera APIs that were previously catalog-only. Source implementation does not establish that a new API compiled or ran successfully. Workspace book/tabletop regions remain simulated, and its dashboard is not replaced by the lab examples. Shared app state remains in memory while the root exists; demo session drafts have their own in-memory owners. App-relaunch restoration is outside this demo. Apple App Resizability has not been run here.

## Presentation and sources

`Docs/AdaptiveDuoLab_iPhone_Duo_Demo.pptx` contains the 17-slide talk presented by Somendra, with API code, UI examples and an introduction/Thank you ending. Source links stay in notes and guides; there are no reference slides. Existing project images are earlier captures, not fresh evidence of the new examples. Capture the updated app after building and running it on your Mac.

- [TabView](https://developer.apple.com/documentation/swiftui/tabview)
- [Tab](https://developer.apple.com/documentation/swiftui/tab)
- [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)
- [Raise the bar with iPhone Duo, 03:30](https://developer.apple.com/videos/play/tech-talks/111462/?time=210)

Updated 26 September 2026.
