# AdaptiveDuoLab iPhone Duo talk

**Revision:** 26 September 2026  
**Deck:** AdaptiveDuoLab_iPhone_Duo_Demo.pptx — 17 slides on adapting an existing application

## Talk structure

| Slide | API / function | Visible result and code status |
| --- | --- | --- |
| 1 | Introduction | **Adaptive layout for iPhone Duo** — adapting an existing app with SwiftUI and UIKit. Presented by Somendra. Objective: adaptive UI while preserving state. |
| 2 | Adaptive layout for iPhone Duo | Establish the objective using the project's earlier compact capture: one application that fits changing space and preserves state. |
| 3 | `GeometryReader`, `horizontalSizeClass`, `AnyLayout` | The reflow example uses local width and text size to switch one `AnyLayout` while preserving editable state. The tab example reads its current size class. Do not infer layout from hardware names. |
| 4 | `TabView`, `Tab`, sidebar preference | The app retains three native tabs. A separate tab example implements `.sidebarAdaptable` plus the applicable default-placement modifiers, with a shared note and stable selection. |
| 5 | `NavigationSplitView` | Keep one hierarchy and stable category selection while columns collapse or expand. The earlier project wide capture illustrates its content; it is not a new native runtime validation. |
| 6 | `ignoresSafeArea`, `safeAreaInsets`, `safeAreaLayoutGuide` | Extend backgrounds while protecting foreground controls. Read every inset independently and test both Split View positions. |
| 7 | `ViewThatFits`, `fixedSize` | Supply readable fitting alternatives. The project crop is before-fix evidence; current header and text code has not been recaptured at runtime. |
| 8 | `ArrangementView`, `.split` | API Lab source arranges real records and a summary with a ratio preference. Its overlay route adapts foreground controls and filters the real records. Workspace remains a separate composition. |
| 9 | `reservedRegions`, `.division`, `.occlusion`, `isActive` | The new custom-control route measures a Review button and avoids active region frames. A native toolbar fallback preserves access when it cannot fit. Empty and inactive results are valid. |
| 10 | `ConcentricRectangle`, `UICornerConfiguration` | Interactive SwiftUI and UIKit examples compare concentric and fixed corners while changing an inset. Older OS paths remain usable; corner matching does not replace safe areas. |
| 11 | Native toolbar actions | The toolbar examples use navigation containers and working close/action controls. Exact source locations and framework-specific coverage are listed in the API guide. |
| 12 | Priority, overflow and compression | `visibilityPriority` affects overflow order; `ToolbarOverflowMenu` holds secondary actions; `.prefersToolbarItems` compresses tabs first. The supplied vertical-bar screenshot illustrates the overflow control. |
| 13 | `toolbarVerticalEdge`, `.axisBehavior(.verticalPreferred)` | The custom Review control adapts in a vertical-capable context. An edge preference can exist while the bar is hidden; it is not a visibility detector. |
| 14 | `.sheet`, `NavigationStack`, `presentationDetents` | PresentationAPIDemo implements an editable sheet with detents plus a popover, alert and menu. The parent owns the draft and action result. |
| 15 | App Resizability in Xcode 27.1 | Use the supplied workflow screenshot to explain an app-wide audit, local-trait replacement and review/build/test checks. The skill has not been executed on this project here. |
| 16 | Existing-app migration and performance | Audit, choose targeted APIs, preserve state, gate SDK usage and profile transitions. App Resizability assists source changes; developers review and validate them. |
| 17 | Thank you | Close with Somendra and the single-experience message. |

The deck keeps the main story concise, pairs formatted Swift code with relevant UI and ends with Thank you. It has no References or Appendix slides; source links and longer technical details stay in speaker notes and these guides. App-defined helpers and omitted context are identified in notes. This revision adds executable examples to the same app and synchronizes their implementation status. Source presence is distinct from successful SDK compilation or observed device behavior; those checks remain pending.

The design guidance follows Apple's *Design for iPhone Duo*: preserve one hierarchy and the same functionality, use actual window traits and safe areas, and let system components provide their supported adaptation. Compact outer and regular inner are useful design descriptions, not a rule for identifying hardware. Multitasking and pinned picture-in-picture can change the space available to the application.

Apple **App Resizability** in Xcode 27.1 is the renamed modernization skill with SwiftUI and Duo support. It assists a coding agent in changing source. System containers adapt their own UI; developers still choose how custom content fits and how state survives. There is no single runtime modifier that repairs an entire application.

## What the existing project implements

Workspace, Review and Settings share preferences and one SwiftData container. `RootView` owns the selected tab, category, presentation and preview pose above its native containers. Native `Tab` is used on iOS 18+, with `tabItem` on iOS 17. Workspace uses one `NavigationSplitView`; it does not swap separate navigation hierarchies for each size.

Headers choose fitting alternatives. Cards expose complete title and summary text, and metadata can stack. The background gradient ignores safe areas without applying that modifier to the interactive foreground. Accessibility text uses one collection column. Short-window and large-text controls can move into a compact menu. Constrained book/tabletop previews fall back without changing the selected preset.

**Settings → Open API Lab** now provides **8 interactive routes and 25 catalog entries** covering reflow/corners, SwiftUI and UIKit toolbars, tab/sidebar, UIKit navigation, presentations, camera and system layout. The system-layout route uses current filtered records. Native split/overlay, active-region avoidance and read-only hinge diagnostics have source implementations. Every record remains reachable, and Summary has another route. Workspace poses remain simulated; the lab does not replace every Workspace screen.

The review action says **Layout Review** and displays local configuration checks. These checks are not a measurement of every screen or a cloud AI service. Existing stored records remain intact; reset demo data explicitly to see revised seed wording.

## Example integration and remaining boundaries

- **Adaptive grid:** retain explicit List/Grid/Automatic choices when adopting a scaled readability preference, and check containers narrower than the preferred card width. The longer grid example remains guide material rather than a separate slide. `AdaptiveLayoutPolicy` currently uses the automatic-grid threshold at 620 points and column thresholds at 560, 820 and 1100 points. These are sample content rules, not Apple display breakpoints. Book/tabletop composition remains driven by `DemoPose` and content-budget checks.
- **AnyLayout:** slide 3 maps to `LayoutAPIDemo`, whose editor and summary remain children of one `AnyLayout`. A 640-point sample content preference, accessibility text size and a manual vertical preference select its axis. The current Dashboard still has its own policy; size class alone is not a complete layout algorithm.
- **Safe areas:** slide 6 maps to the existing gradient/foreground separation and `UIKitAPIDemo`'s local constraints. The UIKit example independently applies extra left or right test insets so the behavior can be inspected on ordinary phones too.
- **Native arrangement:** split, overlay, ratio preference, region queries and custom-control avoidance are implemented in API Lab. Workspace has not been migrated to them. An arrangement expresses a content relationship; it does not replace navigation or every scrolling feed.
- **Toolbar APIs:** slides 11–13 now map to executable toolbar sessions with state-changing actions. Policies are selected before launching a session, keeping vertical-bar preferences stable. `toolbarVerticalEdge` is a preferred edge even when hidden; `nil` means the context does not use vertical bars. See the API guide for exact SwiftUI/UIKit coverage and fallback paths.
- **Sheets:** `PresentationAPIDemo` adds a draft editor with medium/large detents, a popover, alert and menu. Layout Review retains its existing route. Custom region avoidance is explicit application work; continuous scrolling content need not be displaced around the fold.

The hinge readout remains diagnostic: no angle threshold selects a layout. No event, no hinge and empty region results are normal. `CameraAPIDemo` now supplies a real, user-started rear-camera preview and shared speaker prompt; a native camera accessory is offered only when the system reports it available. No microphone, recording, photo output or general external-display playback is configured.

## Mac walkthrough

Baseline builds need Xcode 26+ for the existing glassEffect symbol. The deployment target stays iOS 17. Native examples require Xcode 27.1 / iOS 27.1 SDK and this project's DUO_SDK condition.

```bash
open AdaptiveDuoLab.xcworkspace
./Automation/run-demo.sh -demo-tab Settings
./Automation/run-tests.sh

DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-demo.sh -demo-tab Settings
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-tests.sh
```

1. Select Research, List and Book Fold in Settings. Confirm the same values and two records across tabs.
2. Resize Workspace and increase Dynamic Type. Explain its existing policy separately from the API Lab reflow example; do not attribute Workspace behavior to an API it does not use.
3. Open Layout Review and distinguish configuration guidance from measured geometry.
4. Open API Lab, inspect an API's status, then enter **System layout and regions**.
5. With the native build, resize using Device Hub. Inspect regions and hinge-event text, open Overlay arrangement, and use Move a custom control. Show the alternate Review/Summary routes when content cannot fit.
6. Repeat on an ordinary iPhone. Empty division results and absent hinge information are valid.
7. Use slide 4 to explain native tabs. The app's pose menu simulates content layout and does not reposition native bars.
8. Use slide 3 for local geometry and trait decisions, and slide 5 for navigation columns inside one app. Read actual traits in multitasking and check selection continuity while resizing.
9. Open the toolbar session for slides 11–13. Inspect working actions, overflow, VoiceOver labels, compact metrics, both vertical edges and Reduce Transparency. Repeat with baseline and native build paths.
10. Use slide 16 to explain the migration checklist. Capture real transition traces and compare state, requests and responsiveness before and after each change.

## Evidence and remaining work

The source includes **17 unit tests** (10 layout-policy and 7 reserved-region placement) and **7 UI tests**. **No Xcode compilation, Simulator tests or Apple bundled skill execution occurred here.** Run baseline and native-enabled builds on a Mac before presenting runtime behavior. Source inspection and geometry-focused tests do not prove native bar movement, camera accessory availability or fold transitions.

Screenshot semantics matter. Slides 2 and 5 use earlier compact and wide project captures. Slide 7 uses an earlier cramped-control crop as before-fix evidence. They do not demonstrate a freshly compiled native build or these new examples. Apple reference UI illustrates system behavior and is distinct from project runtime evidence. API Lab explicitly allows both split axes. Executable toolbar, camera and region-avoidance source still needs fresh validation and captures on a Mac/device.

Visual sources and timestamps are recorded in speaker notes. Current 27.1 references are beta; the API adoption guide records differences between current API names and early video examples. A screenshot alone does not establish SDK version, API adoption, hardware state, successful transitions or test results.

See [API adoption guide](API_Adoption_Guide.md) for the API inventory and [Apple App Resizability workflow](Apple_App_Resizability_Workflow.md) for skills, export and whole-project prompts. Validate large text, VoiceOver, RTL, keyboard and presentation changes, resizing and state continuity. The existing/new API distinction matters: `AnyLayout` and `ViewThatFits` are iOS 16; `LazyVGrid` and `ScaledMetric` are iOS 14; `dynamicTypeSize` environment usage requires iOS 15. New device behavior can be provided through existing APIs in the appropriate system context.

## Sources

- [Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111466/) — design principles, safe areas, inner/outer display layouts, sheets and fold avoidance.
- [Prepare your app, App Resizability at 09:12](https://developer.apple.com/videos/play/tech-talks/111461/?time=552)
- [Raise the bar with iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111462/)
- [Strike a pose with adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/)
- [Multiple displays and scenes](https://developer.apple.com/videos/play/tech-talks/111464/)
- [What's new in SwiftUI, WWDC26](https://developer.apple.com/videos/play/wwdc2026/269/)
- [Modernize your UIKit app, WWDC26](https://developer.apple.com/videos/play/wwdc2026/278/)
- [State and ContentBuilder migration, TN3211](https://developer.apple.com/documentation/technotes/tn3211-resolving-swiftui-source-incompatibilities-for-state-and-contentbuilder)

## Additional adaptation details

Slides 3, 4, 6 and 10 cover local geometry, tab containers, safe areas and corners. Each has an API Lab implementation, while the guide identifies which APIs also operate in Workspace. UIKit layout, corner and split-navigation examples are executable via a SwiftUI controller host; further UIKit API mappings are documented separately from source coverage.

Keep `UIRequiresFullScreen` and supported-orientation settings separate from layout logic. The video's `UIRequiresFullScreen` section at 04:43 describes an orientation-honoring, scaled inner-display presentation, including Split View; the supplied screenshot labels that context explicitly. This is scoped compatibility guidance, not a general inner-display orientation rule. Opening and closing still resize the app. Read current bounds and traits, and validate the configured behavior with the target SDK.

The sidebar preference requires the adaptable tab style. Preserve existing selected-tab state. Concentric geometry adjusts a shape; it does not avoid a fold, camera or toolbar. Continue to respect safe areas and use appropriate container layout.

## Toolbar adoption details

Slides 11–13 cover toolbar containers, actions and custom content. In SwiftUI, attach `.toolbar` to content inside a navigation container, using semantic placements such as `.bottomBar`, `.cancellationAction` and `.topBarPinnedTrailing` for the intended role. In UIKit, configure the view controller's `toolbarItems` and show its navigation controller's toolbar with `setToolbarHidden(false, animated:)`. Keep the system navigation container in charge; a separately constructed `UIToolbar` does not acquire the same vertical adaptation.

The source now demonstrates these roles directly: SwiftUI Pin uses `.topBarPinnedTrailing`; UIKit Close, Review/Sort and Pin use separate leading, trailing and pinned-trailing groups, while Add/Summary are managed bottom-toolbar items. UIKit overflow uses `additionalOverflowItems` with a deferred menu provider. The exact eight route labels and source files are in the API guide.

Supply both titles and symbols for actions. A compact visual can hide its title while retaining its semantic label for accessibility and overflow. A close/cancel action should use its semantic placement instead of a manually positioned corner button. Pinning is distinct from visibility priority; preserve normal navigation and use the pinned location selectively.

`toolbarVerticalEdge` is an optional preferred `HorizontalEdge` for a vertical-capable context, even if a vertical bar is not currently visible. `nil` means the context does not use vertical bars. UIKit's equivalent `traitCollection.verticalBarEdge` returns `UIVerticalBarEdge`, with `.unspecified` when the context does not support a vertical bar. Neither value is a visibility detector. For a suitable custom toolbar item, `.axisBehavior(.verticalPreferred)` opts into vertical participation; then choose compact labels and adjust fixed width/height assumptions as needed. Wide controls can remain horizontal with an appropriate accessible route.

Check custom content against normal and Reduce Transparency backgrounds. Flexible spacers have zero size on the vertical axis; fixed spacers preserve their minimum size. Avoid adding manual spacing that fights the system's layout. The new source examples have not been compiled with Xcode or captured at runtime here.

## Review of the seven new attachments

The five screenshot times below refer to 26 September 2026. These images informed the code and guidance; not every attachment becomes a full slide image.

| Attachment | What it contributes | Where it is used |
| --- | --- | --- |
| Screenshot at 09:50:15 AM | SwiftUI and UIKit visibility priority | Slide 12 and API guide: higher priority delays overflow; it does not guarantee visibility. Both APIs are iOS 27. |
| Screenshot at 09:51:17 AM | SwiftUI and UIKit vertical compression preferences | Slide 12: `.prefersToolbarItems` / `.prefersBarItems` compress tabs first. These preferences are iOS 27.1 beta. |
| Screenshot at 09:53:51 AM | `ToolbarOverflowMenu` and UIKit `additionalOverflowItems` | Slide 12 and guide: explicit secondary actions stay in system overflow. SwiftUI is iOS 27; UIKit's property is iOS 16. |
| Screenshot at 09:55:11 AM | Visible overflow control in a vertical bar | Slide 12's UI example, paired with editable code rather than treated as evidence of project integration. |
| Screenshot at 09:58:13 AM | Audit, build, custom-item and overflow checks | Slide 16's migration checklist; retain full implementation details in the guide. |
| `IMG_5133.PNG` | Third-party advice on adaptive geometry, cheap updates, state and real transitions | Slide 16's performance/state guidance, checked against Apple sessions below. |
| `IMG_5134.PNG` | Overlapping continuation of the same performance advice | Combined with the previous image to avoid repeating the same content. No author names or social-feed chrome are needed in the deck. |

The later App Resizability screenshot, included as `Docs/Screenshots/06_app_resizability.png`, has a dedicated slide 15. It shows the prompt “Make my app follow all resizability best practices” and an example change from `UIScreen.main.scale` to `traitCollection.displayScale`. Explain audit → review diff → build → test; do not present the screenshot as evidence that the skill ran on this project.

## Performance and state checks for slide 16

Keep selection and model ownership stable while layout changes; do not start requests or expensive processing from `body`. Resizing should rearrange an experience without duplicating its work. The examples preserve state within their owners, but no performance gain has been measured here.

Profile realistic resize, rotation, tab and sheet transitions. Use the SwiftUI instrument to locate expensive or repeated updates, its Cause & Effect Graph to trace dependencies, and Time Profiler to inspect CPU work. Compare equivalent runs after a targeted change. See [Optimize SwiftUI performance with Instruments](https://developer.apple.com/videos/play/wwdc2025/306/) and the current [Power and Performance Group Lab](https://developer.apple.com/videos/play/wwdc2026/8003/).

`Task {}` creates asynchronous work but does not by itself move CPU-heavy work off the main actor. Separate expensive non-UI processing with explicit isolation and safe data transfer, then publish UI state on its owning actor. See [Explore concurrency in SwiftUI](https://developer.apple.com/videos/play/wwdc2025/266/). No performance improvement or runtime validation is claimed from these screenshots.
