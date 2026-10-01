# AdaptiveDuoLab: Apple API adoption guide

Updated 26 September 2026. The iOS 27.1 references are beta. Read the headers and availability in the exact SDK used for your build.

## What changed in this revision

The existing app's **Settings → Open API Lab** now contains **8 interactive routes and 25 catalog entries** for the adaptive APIs previously missing from source. Reflow, corners, toolbar policies, tabs/sidebar, UIKit, presentations, camera accessories and native arrangements all stay inside the same project. The catalog identifies source locations and availability, with **Try this API** links where a lab route exists. API Lab retains its own navigation stack, and the system-layout route uses the existing filtered SwiftData records without creating another store or replacing the three app tabs.

The native arrangement demonstration is deliberately outside Workspace's `NavigationSplitView`. Its split example keeps every filtered record in primary and a real category summary in secondary, with both axes allowed and a 0.35 secondary ratio preference. Summary also has a separate route. Its overlay example changes a real completed-record filter and adapts controls using `overlayArrangementZIndex`. Neither reads `DemoPose` to force hardware behavior.

The reserved-region inspector remains available, and a new custom-control example applies active division/occlusion frames to position a measured Review button. If the button cannot fit, a native toolbar action opens the same summary and records. Inactive and empty results remain valid. A query alone is not avoidance: `ReservedRegionPlacement` supplies the app's placement policy. Hinge events remain read-only diagnostics and do not drive the layout.

**Mac compilation and Simulator/device validation are pending.** Implementation below means executable source is present, not that the native SDK build has been verified. The 17-slide deck uses earlier project captures alongside API explanations; those images do not validate these new examples. Detailed references remain in notes and guides, with no References or Appendix slides. Workspace still uses its established dashboard policy and simulated preview poses; API Lab examples are not a blanket migration of the application.

## API, effect, project location and fallback

| API | Introduced | What it changes | Exact project location/status | Other supported iPhones / fallback |
| --- | --- | --- | --- | --- |
| `GeometryReader` | iOS 13 | Local content-space measurements | `DashboardView.body`; `NativeArrangementContent`; `NativeRegionInspector` | The app supplies fit rules; geometry does not imply a particular device. |
| `NavigationSplitView` | iOS 16 | Adaptive sidebar/detail navigation | `RootView.workspace`; implemented | Native collapse in compact space. Sidebar presentation is system-managed; the unused app policy flag was removed. |
| `ViewThatFits` | iOS 16 | First developer-provided alternative that fits | `DashboardHeader`; `WorkItemCard` metadata; implemented | Horizontal/stacked/menu alternatives work across ordinary iPhones. It cannot invent a missing alternative. |
| `Tab`, `TabView` | Tab iOS 18; TabView iOS 13 | Native destination containers and system bar presentation | `RootView.tabs`; implemented | iOS 17 uses `.tabItem` and stable tags. Vertical bar behavior depends on the linked SDK and current system environment. |
| `glassEffect` | iOS 26 | System glass appearance | `WorkItemCard.adaptivePanel`; implemented | Earlier OS versions use regular material. SDK 26+ is still required to compile this symbol. |
| `AnyLayout`, `HStackLayout`, `VStackLayout` | iOS 16 | Reflow related views while retaining their identity | `LayoutAPIDemo.body`; editable task and completion summary | Uses local width and accessibility text size; a vertical preference is available. |
| `ConcentricRectangle` | iOS 26 | Inner corners follow a container shape | `ConcentricCornerDemo` in `LayoutAPIDemo.swift`; toggle plus inset slider | iOS 26 works without special hardware; older OS shows availability guidance while reflow remains usable. |
| `UICornerConfiguration`, `.containerConcentric()` | iOS 26 | Equivalent native UIKit corner geometry | `UIKitLayoutController.changeCorners` | Earlier OS uses fixed rounded corners; inset controls continue to work. |
| `safeAreaLayoutGuide`, `safeAreaInsets`, `view.bounds` | Existing UIKit APIs | Independent local edge layout and readout | `UIKitLayoutController`; controlled left/right test insets | No global screen lookup or assumption that opposite edges match. |
| `UISplitViewController` | Existing UIKit container | Native column collapse and expansion | `UIKitSplitDemoController`; Topics destination of the full-screen UIKit session | Local topic drafts survive window changes within the session. |
| `UITabBarController`, `UITab`, `.tabSidebar`, `sidebar.preferredPlacement` | UITab/sidebar mode iOS 18; preference iOS 27 | Native UIKit destinations and sidebar preference | `UIKitNavigationDemoController` in `UIKitAPIDemo.swift` | iOS 17 uses ordinary tab view controllers; new placement is gated by the native build and iOS 27.1 in this sample. |
| `.sidebarAdaptable`, `defaultAdaptableTabBarPlacement`, `defaultTabBarPlacement` | Style/adaptable preference iOS 18; newer preference iOS 27 | Prefer a native tab bar or sidebar | `TabDemoSession.modernPresentation` in `TabAPIDemo.swift` | iOS 17 uses tab items; supported iOS 18 contexts use adaptable placement; the system chooses the actual presentation. |
| `ToolbarOverflowMenu` | iOS 27 | Explicit secondary actions in system overflow | `NativeToolbarRecords` in `ToolbarAPIDemo.swift`; Add, Summary and Review actions | Baseline session uses an ordinary menu; native presentation follows available space. |
| `visibilityPriority` | iOS 27 | Relative resistance to toolbar overflow | `NativeToolbarRecords`; Review priority toggle and lower-priority actions | High priority does not guarantee visibility. Actions remain reachable elsewhere. |
| `ArrangementView`, `.split.axes`, `splitArrangementLayoutRatio`, `splitArrangementAxis` | iOS 27.1 beta | Related record/summary composition with an axis readout | `NativeArrangementContent`, `SplitArrangementReadout` | Both axes allowed; 0.35 is a preference, not fixed pixels. Baseline builds show a continuous list. |
| `.overlay.axes`, `overlayArrangementEdge`, `overlayArrangementZIndex` | iOS 27.1 beta | Layered or separated foreground controls | `NativeOverlayArrangementDemo`, `OverlayReviewControls` | Completed-only changes the actual filtered count; Review records remains a separate route. |
| `ReservedRegion`, `GeometryProxy.reservedRegions` | iOS 27.1 beta | Local division/occlusion geometry and custom-control avoidance | `NativeRegionInspector`, `NativeRegionAvoidanceDemo`; `ReservedRegionPlacement` | No invented hinge gap. Only active frames affect placement; a native Review fallback remains if no candidate fits. |
| `ToolbarContent.axisBehavior` | iOS 27.1 beta | Axis participation for the custom Review control | `NativeToolbarRecords`; Automatic / Horizontal only / Prefer vertical | A list action and Actions tab preserve access if the control is excluded from an axis. |
| `toolbarMinimizationBehavior` | iOS 27 | Navigation-bar minimization | `NativeToolbarRecords`; automatic, never and scroll-direction choices | Scroll the record list to compare the preference. Baseline preview does not imitate it. |
| `toolbarVerticalCompressionBehavior` | iOS 27.1 beta | Prefer tabs or actions during vertical compression | `NativeToolbarRecords`; next-session picker | Prefer toolbar actions compresses tabs first; only relevant when the system provides a shared vertical bar. |
| `EnvironmentValues.toolbarVerticalEdge` | iOS 27.1 beta | Preferred edge in a vertical-capable context | `NativeToolbarRecords`, `NativeReviewControl` | May be populated while hidden; `nil` means the context does not use vertical bars. No custom side rail is drawn. |
| `toolbarVerticalBehavior` | iOS 27.1 beta | System default or horizontal bars | `NativeToolbarSession`; selected before presentation | Stable for the session; a preference does not create hardware capability. |
| `topBarPinnedTrailing` | iOS 27 | Prominent trailing Pin/Unpin action | `NativeToolbarRecords`; changes the local pin state | Placement is system-owned; priority and pinning remain separate concepts. |
| UIKit `toolbarItems`, `setToolbarHidden`, `leadingItemGroups`, `trailingItemGroups`, `pinnedTrailingGroup` | Managed toolbar existing API; navigation groups iOS 16 | Managed Add/Summary toolbar plus semantic Close, Review/Sort and pinned Pin groups | `UIKitToolbarRecordsController`; each item belongs to one group | Supported in the iOS 17 baseline. The navigation controller owns the bar, not a custom `UIToolbar`. |
| UIKit `visibilityPriority`, `axisBehavior`, `verticalBarCompressionBehavior`, `verticalBarEdge`, `additionalOverflowItems` | Overflow property iOS 16; priority iOS 27; vertical APIs iOS 27.1 | UIKit equivalents with Records/Actions tabs | `UIKitToolbarRecordsController` in `UIKitToolbarAPIDemo.swift` | Ordinary system actions and overflow work on the baseline path; native properties are gated by `DUO_SDK` and iOS 27.1. |
| `onHingeChange`, `DeviceHingeContext` | iOS 27.1 beta | Hinge events and optional physical hinge details | `NativeArrangementContent`; read-only diagnostic source | `context.hinge` is optional. Until an event arrives the screen says so; nil is not treated as a layout failure. |
| `.sheet`, `presentationDetents`, `.popover`, `.alert`, `Menu` | Existing SwiftUI APIs | System presentations with shared local state | `PresentationAPIDemo`; edit draft, mark reviewed or pin | The system adapts each presentation. A popover may adapt to compact space; it is not forced into a custom panel. |
| `CameraCaptureAccessory`, `sceneAccessory`, `onAvailabilityChange` | Camera accessory iOS 27.1 beta | Optional interactive prompt on an eligible camera display | `NativeCameraDemo` in `CameraAPIDemo.swift`; real AVFoundation rear preview | User starts capture. Ordinary phones retain preview/prompt; unavailable accessory is a normal state. No capture output is simulated. |

Catalog text and `APIDemoRoute` live in `Sources/Models/APICatalog.swift`; destination routing lives in `Sources/Views/APILabView.swift`. Demo files are in `Sources/Views/`. `Sources/Layout/ReservedRegionPlacement.swift` contains the pure geometry helper.

## Runnable example map

Start at **Settings → Open API Lab → Interactive examples**. Examples other than the system-layout route use separate local demo state and do not modify the persistent WorkItem store.

| Exact route | Source | Trigger and visible state change | Other-phone / older-OS behavior |
| --- | --- | --- | --- |
| System layout and regions | `SystemArrangementDemo.swift` | Native split shows real records and summary; details menu opens Overlay arrangement, Inspect reserved regions and Move a custom control. Completed only filters the overlay; Review opens actual records. | Baseline continuous list; native empty regions are valid. No synthetic fold gap. Hinge readout remains diagnostic. |
| SwiftUI toolbar actions | `ToolbarAPIDemo.swift` | Choose policies, then Open native toolbar session. Review increments a count, Pin toggles, Reverse order reorders, overflow Add changes record count, Summary shows live values. | Baseline ordinary toolbar/menu preview. Native edge may be `nil`; records and Actions keep controls reachable. |
| Tabs and sidebar | `TabAPIDemo.swift` | Prefer sidebar where supported → Open tab example. Edit Note, switch to Summary and resize. | iOS 17 tab items; iOS 18 adaptable style; iOS 27 preference in native builds. Placement remains system-selected. |
| Reflow and concentric corners | `LayoutAPIDemo.swift` | Edit title/completion; toggle Prefer a vertical layout. Change the corner inset from 8–32 points and compare the concentric toggle. | Reflow uses actual width and accessibility size; corners require iOS 26, with availability guidance on older OS. |
| UIKit layout and navigation | `UIKitAPIDemo.swift` | Change left/right test insets, corners and inset slider. Open UIKit tabs and split navigation, select Topics and edit per-topic drafts. | Local bounds/insets/display scale; fixed corners before iOS 26; native tabs/split collapse in supported contexts. |
| UIKit toolbar actions | `UIKitToolbarAPIDemo.swift` | Choose tab-compression/Review-axis preferences, then Open UIKit toolbar session. Review, pinned Pin, Sort and Add change shared state. Add/Summary also occupy the navigation-managed bottom toolbar; Close uses its leading group. | Baseline UIKit groups, actions and overflow remain; new priority/axis/compression properties require the native path. |
| Sheets and presentations | `PresentationAPIDemo.swift` | Edit in a sheet, Show popover, Show alert and Actions. The parent draft and last-action value update. | Native presentations adapt normally; no custom pose or popover geometry is forced. |
| Camera accessory | `CameraAPIDemo.swift` | Start camera requests permission; Next prompt updates shared text. Enable the accessory toggle only after capture is running and the system reports availability. | Live rear preview remains without an accessory. Denied permission and no camera show status; leaving/backgrounding stops capture. No photos/audio/recording are saved. |

The reserved-region example measures the button before showing it. It avoids all active local frames together, ignores inactive/nonintersecting regions and uses a native Review action if no position fits. `ReservedRegion.frame` already includes its interactive margins; do not expand it again. The 0.35 split ratio and 640-point reflow threshold are sample preferences, not hardware constants.

Session lifetime is explicit: SwiftUI/UIKit toolbar action state remains in its launcher while reopening its session. Tab notes belong to a presented tab session and reset on a fresh presentation. Presentation drafts remain in their route's parent. No example promises persistence across app termination.

## Automatic adaptation versus application work

| System does | Application supplies | Agent skill can help with |
| --- | --- | --- |
| Adapt native navigation and supported system bars | Meaningful destinations, stable selection and complete labels | Find custom bars and propose native container replacements |
| Choose among `ViewThatFits` alternatives | Actual alternatives and a readable minimum layout | Locate fixed sizes, clipping and absent fallbacks |
| Arrange the two children of `ArrangementView` | Correct primary/secondary relationship and access to secondary functions | Refactor one suitable composition, preserve state, add availability guards |
| Report reserved geometry and hinge events | Correct coordinate handling, active-state filtering and capability fallbacks | Identify where custom content truly needs geometry handling |
| Scale Dynamic Type text | Scrollability, sensible column count and readable controls | Audit every view and add targeted regression coverage |

There is no project-wide SwiftUI switch that repairs every custom layout. Apple **App Resizability** is an Xcode 27.1 development skill; it can assist an agent making source changes. It does not run inside this app. See [Apple App Resizability workflow](Apple_App_Resizability_Workflow.md) for verified names, export command, prompts and review gates. The article's SwiftUI Agent Skill is a separate third-party project.

## Build-time and runtime gates

The baseline deployment target remains iOS 17. Build with Xcode 26/iOS 26 SDK or later because the app already uses `glassEffect`. The native source requires Xcode 27.1/iOS 27.1 SDK.

```swift
#if DUO_SDK
if #available(iOS 27.1, *) {
    NativeArrangementContent(items: items, category: category)
} else {
    fallback("Run iOS 27.1 or later.")
}
#else
fallback("Build the native example using the 27.1 SDK.")
#endif
```

`#if DUO_SDK` prevents an older SDK compiler from seeing unknown 27.1 declarations. `@available` annotations on the native view declarations and `#available` at the call site separately protect older running OS versions. An availability check alone does not solve the SDK-symbol problem. Hardware capabilities must still be checked or handled as optional.

From the extracted project directory on a Mac:

```bash
# Native API examples: enables DUO_SDK and opens Settings
DEVICE_ID="your-simulator-udid" ./Automation/run-api-demos.sh
```

The shortcut uses the shared SDK validation. Baseline and explicit native commands remain available:

```bash
# Existing baseline build and test path
./Automation/run-demo.sh -demo-tab Settings
./Automation/run-tests.sh

# Native demo: use an installed Simulator UDID and selected Xcode 27.1 SDK
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-demo.sh -demo-tab Settings
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-tests.sh
```

Use `DEVELOPER_DIR` to select a specific Xcode installation. Scripts check the selected Simulator SDK and append `DUO_SDK` to inherited Active Compilation Conditions only for the opt-in build. For direct Xcode Run, add `DUO_SDK` to that build setting for your intended configuration while preserving existing values. Both the included generated project and Tuist's `Sources/**` include the new files.

## Concrete changes across existing screens

- **Workspace header:** local geometry selects compact native toolbar controls for short windows or large text; `ViewThatFits` supplies stacked and menu alternatives.
- **Records:** titles and summaries are fully readable, metadata can stack, and symbol containers scale. The collection remains scrollable.
- **Layout policy:** accessibility text uses a single column and a single continuous region; a short tabletop area below 520 local points falls back to the regular collection. The selected content mode and simulated pose are preserved.
- **Book preview:** requires space for two readable card regions; otherwise all filtered records remain in the continuous collection. This preview still uses a simulated divider.
- **Review:** remains an honest configuration-based local-rule example. It is not an AI code auditor or runtime Apple skill.
- **Settings:** opens the API Lab while retaining the existing shared category, mode, pose and tab selection.
- **API Lab:** provides baseline and native opt-in demonstrations with actual interactions, availability checks and explicit source locations.

The layout thresholds are this sample's content rules, not Apple hardware breakpoints. The normal sidebar remains system-managed. Camera accessory integration now has a real user-started preview workflow. App-relaunch state restoration remains outside this demo; example state survives within its owning session, not indefinitely after dismissal or relaunch.

## Validation matrix to execute on a Mac

| Build/runtime | Required checks |
| --- | --- |
| Baseline, iOS 17 | Native tabs fallback, API inventory, normal-list availability screen, shared data, full card content |
| Baseline, iOS 26+ | `Tab`, glass appearance, narrow/short window controls, accessibility text |
| Native SDK flag enabled, older runtime | Runtime fallback; no attempt to instantiate new APIs |
| Native SDK flag enabled, ordinary iPhone on 27.1 | All records reachable; no artificial hinge gap; empty/inactive regions and absent hinge handled |
| Native SDK flag enabled, Duo runtime/device | System arrangement during resizing and pose changes; summary route; division/occlusion diagnostic changes |
| Both builds | RTL, VoiceOver order, accessibility Dynamic Type, keyboard/sheet presentation, state before/after resizing and tab switching |

The source has **17 unit tests**: 10 layout-policy tests and 7 `ReservedRegionPlacementTests` cases. It has **7 UI tests**, adding editable reflow state through rotation, toolbar state across closing/reopening and camera capture initially off to the existing shared-state and API Lab journeys. Native physical behavior and every new route are not covered by these checks. Xcode test execution, fresh screenshots and hardware evidence remain pending.

## Apple references

- [Prepare your app for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111461/)
- [Raise the bar with iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111462/)
- [Strike a pose with adaptive layouts on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111463/)
- [Leverage multiple displays and scenes on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111464/)
- [What is new in SwiftUI — WWDC26](https://developer.apple.com/videos/play/wwdc2026/269/)
- [ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview)
- [GeometryProxy.reservedRegions](https://developer.apple.com/documentation/swiftui/geometryproxy/reservedregions(kind:options:layoutdirectionbehavior:))
- [onHingeChange](https://developer.apple.com/documentation/swiftui/view/onhingechange(isenabled:_:))

## Complete new-API reference inventory

The following inventory extends the implementation map with supplementary Apple references. The source map above is authoritative about what this app executes. Product-specific features such as document editing, remote image loading and external-display playback are background material, not required parts of this records/camera learning workflow. All declarations require the corresponding SDK even if they can deploy to an older OS.

## Versioned inventory: iOS/iPadOS 27.0

These also work on supported ordinary iPhones running the required OS. The hardware decides which capabilities and presentations are available.

| Exact current API | Purpose and integration point | Important limit | Official documentation |
|---|---|---|---|
| `ToolbarContent.visibilityPriority(_:)` | Give frequently used actions a higher chance of remaining visible as bars overflow. Apply to a toolbar group first, then individual items if needed. | A priority is not the same as pinning. | https://developer.apple.com/documentation/swiftui/toolbarcontent/visibilitypriority(_:) |
| `ToolbarOverflowMenu` | Put less frequent actions into the system overflow menu instead of building a second ellipsis menu. | Keep distinct domain menus with their own meaningful symbol. | https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu |
| `ToolbarItemPlacement.topBarPinnedTrailing` | Keep a prominent action in the pinned trailing location. | Use selectively for genuinely important actions. | https://developer.apple.com/documentation/swiftui/toolbaritemplacement/topbarpinnedtrailing |
| `TabRole.prominent` | Distinguish a special destination, such as a cart, from peer browsing tabs. | Does not turn a button action into a navigation destination; not necessary for every app. | https://developer.apple.com/documentation/swiftui/tabrole/prominent |
| `View.toolbarMinimizationBehavior(_:for:)` | Allow a navigation bar to minimize in response to scroll, e.g. `.onScrollDown`. | Currently documented supported placement is `.navigationBar`; an integrated top tab bar also minimizes. | https://developer.apple.com/documentation/swiftui/view/toolbarminimizationbehavior(_:for:) |
| `View.toolbarMinimizationRestoration(_:for:)` | Set when a minimized bar returns; `.atScrollEdge` delays restoration until the content edge. | Custom restoration currently applies only to `.navigationBar` with `.onScrollDown`. | https://developer.apple.com/documentation/swiftui/view/toolbarminimizationrestoration(_:for:) |
| `View.toolbarMinimizationSafeAreaAdjustment(_:for:)` | Choose whether content reflows into the space released by a minimizing navigation bar. | `.disabled` can suit full-bleed content; it should not be applied indiscriminately to forms and controls. | https://developer.apple.com/documentation/swiftui/view/toolbarminimizationsafeareaadjustment(_:for:) |
| `View.presentationPlacement(_:)` | Prefer a sheet on `.leading` or `.trailing`, preserving useful backing content. | Only sheets respect this modifier. `.automatic` is the default. | https://developer.apple.com/documentation/swiftui/view/presentationplacement(_:) |
| `View.sceneAccessory(content:)` | Associate additional scene content with a visible view. | Accessory availability is controlled dynamically by the system. | https://developer.apple.com/documentation/swiftui/view/sceneaccessory(content:) |
| `ExternalNonInteractiveAccessory` | Show a noninteractive companion presentation on a connected external display or AirPlay display. | This is not the same capability as showing arbitrary app UI on the Duo outer display. | https://developer.apple.com/documentation/swiftui/externalnoninteractiveaccessory |
| `SceneAccessoryContent.onAvailabilityChange(perform:)` | React when an accessory becomes available/unavailable and enable the relevant UI accordingly. | Use availability, not only a hardware-name check. | https://developer.apple.com/documentation/swiftui/sceneaccessorycontent/onavailabilitychange(perform:) |

## Versioned inventory: iOS/iPadOS 27.1 beta

| Exact current API | What it solves | Behavior outside Duo / implementation note | Official documentation |
|---|---|---|---|
| `ArrangementView(primary:secondary:)` | Keeps two related views together in a layout that responds to size, size class and hardware regions. | Still useful on ordinary iPhones/iPad. Choose content relationships instead of device names. | https://developer.apple.com/documentation/swiftui/arrangementview |
| `arrangementViewStyle(.split)` | Shows related content side by side using a context-appropriate horizontal or vertical axis. | Suitable for main/detail content; does not provide navigation stack or split-view navigation semantics. | https://developer.apple.com/documentation/swiftui/splitarrangementviewstyle |
| `.split.axes(_:)` | Restricts permitted split axes. | A restriction can cause secondary content to disappear; preserve another route to required content. | https://developer.apple.com/documentation/swiftui/splitarrangementviewstyle/axes(_:) |
| `arrangementViewStyle(.overlay)` | Layers primary above secondary, with the ability to separate them when a division is present. | Useful for foreground controls over a media/content surface. Primary is the foreground view. | https://developer.apple.com/documentation/swiftui/overlayarrangementviewstyle |
| `.overlay.axes(_:)` | Restricts axes that the overlay style may use when separating content. | Do not equate overlay with a static `ZStack`; it can change arrangement. | https://developer.apple.com/documentation/swiftui/overlayarrangementviewstyle/axes(_:) |
| `splitArrangementLayoutSize(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:)` | Supply minimum/ideal/maximum sizes to split children. | Width constraints apply to horizontal arrangements, height to vertical; higher `layoutPriority` sizes first. | https://developer.apple.com/documentation/swiftui/view/splitarrangementlayoutsize(minwidth:idealwidth:maxwidth:minheight:idealheight:maxheight:) |
| `splitArrangementLayoutRatio(_:)` | Express a proportional child size, such as 30% for supplementary content. | Priority and available remaining space affect allocation. Not a hard promise of pixels. | https://developer.apple.com/documentation/swiftui/view/splitarrangementlayoutratio(_:) |
| `splitArrangementLayoutRatio(minHorizontal:idealHorizontal:maxHorizontal:minVertical:idealVertical:maxVertical:)` | Set different ratio constraints per split axis. | Use when horizontal and vertical content requirements differ. | https://developer.apple.com/documentation/swiftui/view/splitarrangementlayoutratio(minhorizontal:idealhorizontal:maxhorizontal:minvertical:idealvertical:maxvertical:) |
| `splitArrangementFixedLayoutSize(horizontal:vertical:)` | Preserve ideal size along chosen axes for a split child. | The parameters are Booleans, **not point dimensions**. | https://developer.apple.com/documentation/swiftui/view/splitarrangementfixedlayoutsize(horizontal:vertical:) |
| `overlayArrangementEdge(_:)` | Anchor an overlay child to a preferred horizontal edge when separation occurs. | Accepts `HorizontalEdge?`; it is not an arbitrary x/y position. | https://developer.apple.com/documentation/swiftui/view/overlayarrangementedge(_:) |
| `EnvironmentValues.overlayArrangementZIndex` | Let child UI adapt to whether it is currently layered or separated. | Current type is `Int`; use presentation state to alter compact/expanded controls. | https://developer.apple.com/documentation/swiftui/environmentvalues/overlayarrangementzindex |
| `GeometryProxy.reservedRegions(kind:options:layoutDirectionBehavior:)` | Read local `.division` and `.occlusion` regions. | Empty/zero/inactive geometry is valid. Query the local content coordinate space. | https://developer.apple.com/documentation/swiftui/geometryproxy/reservedregions(kind:options:layoutdirectionbehavior:) |
| `ReservedRegion` | Exposes `frame: CGRect`, `margins: EdgeInsets`, `isActive: Bool`, `id: ReservedRegion.ID`, and region kind. | Region ID is not a device model ID. | https://developer.apple.com/documentation/swiftui/reservedregion |
| `ReservedRegion.QueryOptions.includeInactive` | Expose a region even while it is not actively dividing/occluding content. | Useful for diagnostics or consistent grid policy; actively avoid only active regions where appropriate. | https://developer.apple.com/documentation/swiftui/reservedregion/queryoptions/includeinactive |
| `ToolbarContent.axisBehavior(_:)` | Keep an item `.horizontalOnly`, or allow a custom item `.verticalPreferred`. | A label/title and symbol help the system infer a suitable presentation. | https://developer.apple.com/documentation/swiftui/toolbarcontent/axisbehavior(_:) |
| `EnvironmentValues.toolbarVerticalEdge` | Read the preferred horizontal edge for a vertical toolbar in a context that supports it. | Type is `HorizontalEdge?`; the preference may exist even when no vertical bar is visible. `nil` means the context does not use vertical bars. | https://developer.apple.com/documentation/swiftui/environmentvalues/toolbarverticaledge |
| `View.toolbarVerticalBehavior(_:)` | Opt a screen out with `.disabled` when vertical bars materially harm that screen. | Local design choice, not an application-wide workaround. | https://developer.apple.com/documentation/swiftui/view/toolbarverticalbehavior(_:) |
| `View.toolbarVerticalCompressionBehavior(_:)` | Prefer tabs or toolbar actions when they compete for vertical bar space. | Values include `.automatic`, `.prefersTabBar`, `.prefersToolbarItems`; meaningful only when the vertical presentation exists. | https://developer.apple.com/documentation/swiftui/view/toolbarverticalcompressionbehavior(_:) |
| `View.onHingeChange(isEnabled:_:)` | Receive previous/current `DeviceHingeContext` for hinge-driven effects or diagnostics. | `context.hinge` is optional; the context itself is not. Hinge angle is not the recommended layout driver. | https://developer.apple.com/documentation/swiftui/view/onhingechange(isenabled:_:) |
| `DeviceHinge` | Provides `angle: Angle` and a high-level `status`. | Status includes `.closed`, `.partiallyOpen`, `.fullyOpen`; treat absence of a hinge normally. | https://developer.apple.com/documentation/swiftui/devicehinge |
| `CameraCaptureAccessory` | Pair interactive camera-related content on the outer display with the inner camera UI. | Requires a suitable foreground camera experience and active camera capture; availability is system-controlled. Do not add an unrelated camera session just to showcase the API. | https://developer.apple.com/documentation/swiftui/cameracaptureaccessory |


## Other WWDC26 SwiftUI additions — extended guide

All entries below were checked against current reference documentation, beyond the video transcript.

| Family | Exact current names and availability | What it does | Why not automatically add to this POC? |
|---|---|---|---|
| Document apps | `Document`, `DocumentWriter`, `DocumentCreationSource` — iOS 27.0 | Read/write document infrastructure; snapshot capture on main actor followed by background coordinated writes, and custom creation flows. | The demo stores SwiftData records. A document architecture is a separate product feature. |
| Reordering and multiple-item drag | `DynamicViewContent.reorderable()`, `View.reorderContainer(for:isEnabled:move:)`, `ReorderDifference`, `View.dragContainer(for:in:_:)` — iOS 27.0 | Reorder in lists, stacks, grids and custom layouts; receive the resulting difference and commit it to app data. Configure multiple transferable items in a drag. | Requires a persistent ordering model and move rules. Current records are sorted by update time, so adding drag without changing data semantics would be misleading. |
| Swipe actions in custom containers | `View.swipeActionsContainer()` — iOS 27.0; expanded use of existing `swipeActions` | Coordinates one open row at a time and dismisses open actions on scroll or outside taps in a custom `ScrollView`/`LazyVStack`. | Add only when the demo has a meaningful row action. `List` already coordinates actions; this modifier is a no-op there. |
| Remote image loading | `AsyncImage.init(request:scale:)`, `View.asyncImageURLSession(_:)` — iOS 27.0 | Default caching respects transport/cache headers; callers can supply a URLRequest or a configured URLSession. | The POC currently has no remote image loading problem. This is a network/performance feature, not Duo adaptation. |
| State and builder migration | `@State` macro / `State()` and `@ContentBuilder` — new Xcode 27 behavior, documented back-deployment to iOS 13; Observable class use starts at iOS 17 | Lazy initial state avoids discarded reference allocations; unified builders reduce ambiguous overload work during type checking. | Relevant to the entire app during toolchain migration, but does not rearrange screens. Audit source compatibility and build, rather than mass-replacing every builder or state declaration. |

Current reference links:

- https://developer.apple.com/documentation/swiftui/document
- https://developer.apple.com/documentation/swiftui/documentwriter
- https://developer.apple.com/documentation/swiftui/documentcreationsource
- https://developer.apple.com/documentation/swiftui/dynamicviewcontent/reorderable()
- https://developer.apple.com/documentation/swiftui/view/reordercontainer(for:isenabled:move:)
- https://developer.apple.com/documentation/swiftui/reorderdifference
- https://developer.apple.com/documentation/swiftui/view/dragcontainer(for:in:_:)
- https://developer.apple.com/documentation/swiftui/view/swipeactionscontainer()
- https://developer.apple.com/documentation/swiftui/asyncimage/init(request:scale:)
- https://developer.apple.com/documentation/swiftui/view/asyncimageurlsession(_:)
- https://developer.apple.com/documentation/swiftui/state()
- https://developer.apple.com/documentation/swiftui/contentbuilder
- https://developer.apple.com/documentation/technotes/tn3211-resolving-swiftui-source-incompatibilities-for-state-and-contentbuilder

The new single-collection reordering signature is:

```swift
nonisolated func reorderContainer<Item>(
    for item: Item.Type,
    isEnabled: Bool = true,
    move: @escaping (
        ReorderDifference<Item.ID, ReorderableSingleCollectionIdentifier>
    ) -> ()
) -> some View where Item: Identifiable, Item.ID: Sendable
```

The current `dragContainer` payload closure takes an **array of item IDs**. The WWDC video has an older single-ID-shaped example, so do not copy that sample into current code without checking its SDK signature.

TN3211 migration checks (keep separate from runtime layout checks): initialize normal stored properties before state assignment; omit inline state defaults when an initializer supplies initial state; resolve `Color`/`Text` name collisions explicitly; prefer builder closure forms for ambiguous `background`/`overlay`; avoid unnecessarily naming concrete builder result types. An SDK upgrade can expose these compile issues even when targeting older supported OS versions.

## Video and current-reference differences

Use the declarations in the SDK you build with. The current toolbar references use `toolbarMinimizationBehavior`, while older WWDC26 sample narration uses `toolbarMinimizeBehavior`. For vertical bars use `toolbarVerticalCompressionBehavior`. Reserved-region default behavior is described differently in current prose and the Tech Talk; this project explicitly requests `.includeInactive` and filters `.isActive` for its active counts. SwiftUI normally mirrors reserved-region geometry for RTL; use `.fixed` only with matching manual coordinate handling.

## Local geometry, corners and sidebar additions

These layout topics now have runnable API Lab examples: `LayoutAPIDemo` handles reflow and SwiftUI corners, `UIKitAPIDemo` demonstrates safe areas and UIKit corners, and `TabAPIDemo` supplies the sidebar preference. Snippets below explain individual API contracts; consult those source files for enclosing state, availability guards and full interactions. Workspace keeps its existing integration until a product-specific migration is chosen.

| API / setting | Availability and integration | Visible effect |
| --- | --- | --- |
| `GeometryReader`, local environment / traits, `view.bounds` | Use current container dimensions instead of global screen dimensions. Prefer `traitCollection.displayScale` for UIKit rendering scale. If a resource requires a screen, resolve `view.window?.windowScene?.screen` dynamically. | Content and rendering resources follow their containing window. |
| `UIScreen.main` | Current Apple documentation marks it deprecated in iOS 26. Remove main-screen assumptions; do not cache a replacement screen for layout. | Avoids ambiguous display selection. |
| `ConcentricRectangle`, `UICornerConfiguration` | iOS 26. Add availability guards and compatible rounded-shape fallbacks for older systems. | Curves follow their containing geometry. |
| `.tabViewStyle(.sidebarAdaptable)` / `.defaultTabBarPlacement(.sidebar)` | Style is iOS 18; placement preference is iOS 27. Preserve destinations and selection. | Richer sidebar navigation in supported contexts. |
| `UITabBarController.mode = .tabSidebar` / `sidebar.preferredPlacement = .sidebar` | Mode is iOS 18; placement preference is iOS 27. | UIKit equivalent sidebar preference. |
| `safeAreaInsets`, `safeAreaLayoutGuide` | Read every edge independently. Use `view.bounds.inset(by: view.safeAreaInsets)` for manual layout or appropriate safe-area constraints. | Foreground avoids asymmetric system controls and hardware regions. |

Replace a global scale lookup with the local trait in a UIKit view or view controller:

```swift
// Before
let screenScale = UIScreen.main.scale

// After
let screenScale = traitCollection.displayScale
```

The two declarations are alternatives, not one code block to paste into a shared scope. If an operation genuinely needs a `UIScreen`, resolve it from the attached window when needed:

```swift
// Within a UIViewController
if let screen = view.window?.windowScene?.screen {
    // Use this screen for the display-specific operation.
}
```

Do not use the screen's bounds as a substitute for the current view's layout bounds. In SwiftUI, read the local environment and proposed geometry instead of assuming one display or a fixed device width.

For manual UIKit layout, avoid subtracting `safeAreaInsets.left * 2`. The other edge can differ:

```swift
let foregroundBounds = view.bounds.inset(by: view.safeAreaInsets)
foregroundView.frame = foregroundBounds
backgroundView.frame = view.bounds
```

These statements belong in the owning view controller's layout pass. Use `safeAreaLayoutGuide` constraints instead when Auto Layout owns the foreground frame. Layout margins also need independent edge handling.

```swift
// SwiftUI: decorative background (iOS 26+)
ConcentricRectangle()
    .fill(Color.green)
    .padding(8)
    .ignoresSafeArea()

// UIKit: view configuration (iOS 26+)
myView.cornerConfiguration = .corners(
    radius: .containerConcentric()
)
```

`myView` is an app-owned UIView. The snippets require their framework imports, appropriate enclosing context and availability checks. Corner geometry does not move interactive content away from occlusions.

Full-screen configuration does not stop open/close resizing. Apple's 04:43 `UIRequiresFullScreen` section describes orientation honoring with a scaled inner-display presentation; keep that compatibility context separate from the general adaptable-layout guidance. Re-evaluate local geometry, safe areas and margins, and test both sides of Split View, rotations, large text, keyboard and RTL.

Slide 15 is dedicated to App Resizability in Xcode 27.1; slide 16 covers migration and performance checks. The supplied screenshot demonstrates an app-wide audit prompt and the concrete replacement `UIScreen.main.scale` → `traitCollection.displayScale`. Use the prompt “Make my app follow all resizability best practices,” review the generated diff, then build both SDK paths and test state, accessibility and transitions. The skill helps a coding agent edit source; it is not a runtime modifier that automatically fixes every screen. The skill has not been executed on this project here.

## Toolbar containers, semantic actions and custom content

The 17-slide presentation covers native toolbar actions on slide 11, priority/overflow/compression on slide 12 and custom controls on slide 13. `ToolbarAPIDemo.swift` implements all seven originally cataloged toolbar policy APIs with live actions; `UIKitToolbarAPIDemo.swift` implements the UIKit priority, overflow, axis, compression and edge counterparts. An edge preference can exist while the bar is hidden; `nil` means the SwiftUI context does not use vertical bars, while UIKit uses `.unspecified`.

| Integration point | SwiftUI | UIKit | Contract and availability |
| --- | --- | --- | --- |
| System-owned toolbar | `NavigationStack` with `.toolbar` and `.bottomBar` content | A view controller's `toolbarItems`, presented by its `UINavigationController` | Existing container APIs gain system adaptation in the appropriate SDK/runtime context. A standalone `UIToolbar` does not provide the same vertical behavior. |
| Semantic close/cancel | `ToolbarItem(placement: .cancellationAction)` | `navigationItem.leadingItemGroups` | Preserve the action's meaning; do not hard-code screen coordinates. UIKit item groups are available from iOS 16. |
| Prominent pinned action | `ToolbarItem(placement: .topBarPinnedTrailing)` | `navigationItem.pinnedTrailingGroup` | SwiftUI placement: iOS 27. UIKit property: iOS 16. Pinning differs from overflow visibility priority. |
| Custom item's axis participation | `.axisBehavior(.verticalPreferred)` | Configure supported bar-button content within the navigation container | SwiftUI modifier: iOS 27.1 beta. A preference is not a command to rotate any custom view. |
| Preferred vertical edge | `@Environment(\.toolbarVerticalEdge)` | `traitCollection.verticalBarEdge` | Both are iOS 27.1 beta. SwiftUI: `HorizontalEdge?`; UIKit: `UIVerticalBarEdge`. Values can describe a preference while no vertical bar is visible. `nil` / `.unspecified` are normal when unsupported. |

Start with the system container and a labeled action:

```swift
NavigationStack {
    WorkspaceView()
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Review", systemImage: "checkmark.seal") {
                    showReview = true
                }
            }
        }
}
```

Here `WorkspaceView` is the app-owned content view and `showReview` is state owned by its enclosing view. Preserve the existing presentation route when applying this pattern. Do not wrap an existing navigation hierarchy in another `NavigationStack` simply to obtain a toolbar.

```swift
// In the displayed UIViewController, attached to a UINavigationController:
toolbarItems = [reviewItem]
navigationController?.setToolbarHidden(false, animated: false)
```

`reviewItem` is an app-configured `UIBarButtonItem` with a meaningful title, image and action. Configure item groups on `navigationItem` for semantic leading and pinned-trailing actions; do not substitute a hand-built floating control lane.

For custom content, retain the semantic label while choosing a compact visual representation in an eligible context:

```swift
@available(iOS 27.1, *)
struct ReviewActionLabel: View {
    @Environment(\.toolbarVerticalEdge) private var verticalEdge

    var body: some View {
        if verticalEdge != nil {
            Label("Review", systemImage: "checkmark.seal")
                .labelStyle(.iconOnly)
        } else {
            Label("Review", systemImage: "checkmark.seal")
                .labelStyle(.titleAndIcon)
        }
    }
}
```

Use this label inside a button in an eligible `ToolbarItem`, then apply `.axisBehavior(.verticalPreferred)` to that item. The environment read is valid in screen content or inside an item's custom view. Supply appropriate imports, a build-time SDK boundary and a runtime availability check; keep the existing labeled button on earlier OS versions.

Review fixed width and height assumptions when designing the compact representation. Avoid preserving horizontal-only metrics that crowd a vertical bar. Keep titles available for accessibility and overflow even when the visible representation is a symbol. A control excluded from one axis still needs an accessible route.

Test normal and Reduce Transparency backgrounds for legibility. A vertical bar has no scroll-edge effect by default, and Reduce Transparency adds a background. Flexible spacers are zero-sized in the vertical axis; fixed spacers retain their minimum size. Let system spacing work before adding custom spacing. Validate both preferred edges, large text, VoiceOver, overflow, compact dimensions and state continuity in the native toolbar session. Mac compilation and runtime validation remain pending.

## Priority, overflow and compression — slide 12

The supplied screenshots separate three decisions that should not be conflated. Priority determines which actions resist overflow; explicit overflow collects secondary actions; compression decides whether tabs or toolbar items surrender vertical space first.

| Decision | SwiftUI | UIKit | Availability and behavior |
| --- | --- | --- | --- |
| Favor an action | `ToolbarContent.visibilityPriority(_:)` | `UIBarButtonItem.visibilityPriority` | Both iOS 27. A higher priority delays overflow relative to lower-priority content; it does not guarantee visibility or pinning. |
| Always offer secondary actions in system overflow | `ToolbarOverflowMenu` | `UINavigationItem.additionalOverflowItems` | SwiftUI iOS 27; UIKit property iOS 16. UIKit's value is `UIDeferredMenuElement?`, not a plain array of actions. |
| Preserve toolbar items before tabs | `.toolbarVerticalCompressionBehavior(.prefersToolbarItems)` | `navigationItem.verticalBarCompressionBehavior = .prefersBarItems` | Both iOS 27.1 beta. Tabs compress first; `.automatic` prioritizes the tab bar. This preference is relevant to the shared vertical presentation. |

```swift
// Content inside the existing navigation container; iOS 27.1+.
WorkspaceView()
    .toolbar {
        ToolbarItem(placement: .primaryAction) {
            Button("Review", systemImage: "checkmark.seal") {
                showReview = true
            }
        }
        .visibilityPriority(.high)

        ToolbarOverflowMenu {
            Button("Export", systemImage: "square.and.arrow.up") {
                exportRecords()
            }
        }
    }
    .toolbarVerticalCompressionBehavior(.prefersToolbarItems)
```

`WorkspaceView`, `showReview` and `exportRecords()` are placeholders in this explanatory excerpt, not exact Workspace source. The complete implemented example is `NativeToolbarRecords`: Review updates its counter, Add changes the local record count, Reverse order changes order and Summary opens current values. Keep the older-OS branch and build-time SDK boundary. Avoid adding a second generic ellipsis menu beside system overflow; keep distinct domain menus only when their purpose and symbol are meaningful.

For UIKit, populate `additionalOverflowItems` with a `UIDeferredMenuElement` provider that completes with menu elements. Its `init(_:)` is available from iOS 14 and caches the result. Use `.uncached(_:)` when menu contents must be regenerated. Keep the action accessible when the bar compresses, and verify labels in overflow and VoiceOver.

### Priority and overflow references

- https://developer.apple.com/documentation/swiftui/toolbarcontent/visibilitypriority(_:)
- https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu
- https://developer.apple.com/documentation/swiftui/view/toolbarverticalcompressionbehavior(_:)
- https://developer.apple.com/documentation/uikit/uibarbuttonitem/visibilitypriority
- https://developer.apple.com/documentation/uikit/uinavigationitem/additionaloverflowitems
- https://developer.apple.com/documentation/uikit/uinavigationitem/verticalbarcompressionbehavior

## Existing-app migration and performance — slide 16

Apply changes at the existing ownership boundary. `RootView` already owns tab, category and presentation state; retain that ownership while changing a container or composition. Use stable model IDs and avoid replacing the entire hierarchy on every geometry change. Keep requests and expensive derived-data work outside `body`. For this sample, verify the filtered records, category and presentation before and after every transition. These are integration checks, not new runtime implementations in this revision.

The two overlapping phone screenshots contribute general performance advice. Treat them as prompts to investigate; the primary Apple material supplies the technical basis. The [WWDC26 Power and Performance Group Lab](https://developer.apple.com/videos/play/wwdc2026/8003/) recommends measuring actual bottlenecks, examining unnecessary updates and using realistic data and conditions. Do not infer a performance gain from layout correctness or a smooth Simulator capture.

Use the [SwiftUI Instruments workflow](https://developer.apple.com/videos/play/wwdc2025/306/) to inspect long view-body updates and repeated invalidations. Follow the Cause & Effect Graph to the state or dependency that triggered work, then inspect the selected interval in Time Profiler. Profile comparable resize, rotation, scrolling and sheet journeys before and after one targeted change. Preserve the trace and note the device, build, data size and accessibility settings.

Concurrency needs explicit design: wrapping synchronous CPU-heavy code in `Task {}` does not automatically move it off the main actor. Keep heavy processing behind a suitable isolation boundary, transfer data safely and publish UI changes on the owning actor. SwiftData models and contexts must retain their isolation; do not send them casually to detached work. See [Explore concurrency in SwiftUI](https://developer.apple.com/videos/play/wwdc2025/266/).

App Resizability can help audit fixed dimensions, container usage, safe-area assumptions and custom toolbar content. Review its proposed edits, build the baseline and native-enabled paths, then test transitions, accessibility, state continuity and responsiveness. No bundled-skill run, Instruments trace, Xcode build or new native capture was produced here.

### Toolbar references

- https://developer.apple.com/videos/play/tech-talks/111462/
- https://developer.apple.com/documentation/swiftui/environmentvalues/toolbarverticaledge
- https://developer.apple.com/documentation/swiftui/toolbarcontent/axisbehavior(_:)
- https://developer.apple.com/documentation/swiftui/toolbaritemplacement/topbarpinnedtrailing
- https://developer.apple.com/documentation/uikit/uitraitcollection/verticalbaredge
- https://developer.apple.com/documentation/uikit/uinavigationitem/leadingitemgroups
- https://developer.apple.com/documentation/uikit/uinavigationitem/pinnedtrailinggroup

### Apple references

- https://developer.apple.com/documentation/swiftui/concentricrectangle
- https://developer.apple.com/documentation/uikit/uicornerconfiguration-swift.struct
- https://developer.apple.com/documentation/swiftui/view/defaulttabbarplacement(_:)
- https://developer.apple.com/documentation/uikit/uitabbarcontroller/sidebar-swift.class/preferredplacement
- https://developer.apple.com/documentation/uikit/uiscreen/main
- https://developer.apple.com/videos/play/tech-talks/111461/
