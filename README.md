# AdaptiveIphoneDuoAPI

**Adaptive layouts for iPhone Duo with SwiftUI and UIKit**

The demo project from my talk at the [Swift Bengaluru](https://www.linkedin.com/company/swiftbengaluru/) meetup, hosted by [PhonePe](https://www.linkedin.com/company/phonepe-internet/).

[Somendra Yadav](https://www.linkedin.com/in/somendrayadav/), Senior Software Engineer at Microsoft.

> Build for the available window space. Let content, local geometry and safe areas guide the layout while preserving the user's task.

## About the project

**AdaptiveDuoLab** explores adapting an existing iOS app across changing window sizes, orientations and display configurations. It combines an adaptive workspace with **8 interactive API Lab routes and 25 API catalog entries**.

The examples cover SwiftUI and UIKit, including navigation, content reflow, system arrangements, reserved regions, toolbars, concentric corners, presentations and camera accessories.

## The main app

| Screen | What it demonstrates |
| --- | --- |
| **Workspace** | Shared SwiftData records, category filtering, automatic/list/grid presentation, adaptive controls and simulated Book Fold and Tabletop previews. |
| **Review** | The selected category, presentation, pose and record count, with configuration-based layout guidance. Also available as a sheet. |
| **Settings** | Shared demo preferences and access to API Lab. |

Root-owned selections keep navigation and configuration consistent as layouts change. SwiftData supplies the shared record store.

## What I demonstrated

### Flexible layouts and content reflow

- Use [GeometryReader](https://developer.apple.com/documentation/swiftui/geometryreader) to measure the local container.
- Switch between horizontal and vertical content with [AnyLayout](https://developer.apple.com/documentation/swiftui/anylayout), preserving the editor and its state.
- Use [ViewThatFits](https://developer.apple.com/documentation/swiftui/viewthatfits) for row, stacked and compact control alternatives.
- Adapt to Dynamic Type, allow text to grow vertically and use a single content column at accessibility sizes.
- Respect Reduce Motion when animating the reflow example.

**Try it:** Edit the task title and completion count, then resize or enable **Prefer a vertical layout**. The values stay intact.

### Native navigation, tabs and sidebar

- [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview) preserves access to the workspace as the navigation presentation changes.
- [TabView](https://developer.apple.com/documentation/swiftui/tabview), `.sidebarAdaptable` and tab-placement preferences keep destinations consistent across available space.
- The UIKit example uses `UITabBarController`, `UITab` and `UISplitViewController`.
- Tab notes and per-topic UIKit drafts remain available while switching destinations and resizing within the demo session.

### Safe areas and local geometry

- Keep interactive content within its safe area while allowing decorative backgrounds to extend behind system bars.
- Test left and right insets independently instead of assuming symmetry.
- Use UIKit's `safeAreaLayoutGuide`, `view.bounds`, `safeAreaInsets` and `traitCollection.displayScale`.

**Try it:** Change the UIKit example's left and right test insets and inspect the local geometry readout.

### Split and overlay arrangements

[ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview) demonstrates two relationships between content:

- **Split:** Every filtered record stays in the primary view, with a category summary in secondary. The example allows both axes, applies a `0.35` secondary ratio preference and displays `splitArrangementAxis`.
- **Overlay:** Review controls use `overlayArrangementEdge` and adapt their presentation through `overlayArrangementZIndex`. The completed-only toggle filters actual records.

A separate summary/review route preserves access to those functions.

### Reserved regions and hinge diagnostics

- Inspect division and occlusion geometry through [ReservedRegion](https://developer.apple.com/documentation/swiftui/reservedregion) queries.
- Distinguish active, inactive and empty results.
- Measure a custom Review button and position it around active reserved frames.
- Keep a native toolbar Review action available when the custom button cannot fit.
- Observe optional [DeviceHinge](https://developer.apple.com/documentation/swiftui/devicehinge) information through `onHingeChange`.

Reserved-region queries report geometry; the app supplies custom-control avoidance. Hinge information remains diagnostic.

### SwiftUI and UIKit toolbars

The toolbar sessions use working **Review, Pin, Add, Sort/Reverse order and Summary** actions.

- Semantic placements, including a prominent pinned trailing action.
- `visibilityPriority` and [ToolbarOverflowMenu](https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu).
- `axisBehavior` choices for the custom Review control.
- `toolbarVerticalCompressionBehavior` to compare tab and action priorities.
- `toolbarVerticalBehavior` for the session's bar preference.
- `toolbarMinimizationBehavior` while scrolling.
- [toolbarVerticalEdge](https://developer.apple.com/documentation/swiftui/environmentvalues/toolbarverticaledge) for adapting the custom control's representation.

The UIKit session demonstrates navigation-item groups, `pinnedTrailingGroup`, a navigation-controller-managed toolbar, overflow actions and corresponding native priority, axis and compression properties.

**Try it:** Choose policies before opening a session, trigger actions and inspect the updated counts. Alternate content/actions routes keep key operations reachable.

### Concentric corners

Compare fixed corners with [ConcentricRectangle](https://developer.apple.com/documentation/swiftui/concentricrectangle) in SwiftUI and [UICornerConfiguration](https://developer.apple.com/documentation/uikit/uicornerconfiguration-swift.struct) in UIKit.

**Try it:** Toggle concentric corners and adjust the inset to see how the inner curve follows its container.

### Sheets and presentations

An editable sheet with medium and large detents shares its draft with the presenting view. The route also includes a popover, alert and action menu with visible state changes.

**Try it:** Edit the draft, resize, dismiss and reopen the sheet. The parent retains the draft.

### Camera accessory

A user-started AVFoundation rear-camera preview demonstrates [CameraCaptureAccessory](https://developer.apple.com/documentation/swiftui/cameracaptureaccessory), `sceneAccessory` and availability changes.

**Try it:** Start the camera, change the shared speaker prompt and enable the accessory when the system reports availability. The preview remains usable without the accessory. Leaving the screen or backgrounding stops capture.

### App Resizability workflow

The talk also covered Apple's **App Resizability skill in Xcode**: inspect an existing project, review proposed source changes and validate resizing, state continuity, safe areas and older-OS fallbacks.

The repository includes the [App Resizability workflow guide](Docs/Apple_App_Resizability_Workflow.md).

## Explore the code

Open **Settings → Open API Lab**.

| Interactive route | Implementation |
| --- | --- |
| System layout and regions | [SystemArrangementDemo.swift](Sources/Views/SystemArrangementDemo.swift) |
| SwiftUI toolbar actions | [ToolbarAPIDemo.swift](Sources/Views/ToolbarAPIDemo.swift) |
| Tabs and sidebar | [TabAPIDemo.swift](Sources/Views/TabAPIDemo.swift) |
| Reflow and concentric corners | [LayoutAPIDemo.swift](Sources/Views/LayoutAPIDemo.swift) |
| UIKit layout and navigation | [UIKitAPIDemo.swift](Sources/Views/UIKitAPIDemo.swift) |
| UIKit toolbar actions | [UIKitToolbarAPIDemo.swift](Sources/Views/UIKitToolbarAPIDemo.swift) |
| Sheets and presentations | [PresentationAPIDemo.swift](Sources/Views/PresentationAPIDemo.swift) |
| Camera accessory | [CameraAPIDemo.swift](Sources/Views/CameraAPIDemo.swift) |

See the [API adoption guide](Docs/API_Adoption_Guide.md) for the complete API, availability and fallback mapping.

## Run the project

1. Install [Xcode](https://developer.apple.com/xcode/) from [Apple Developer Downloads](https://developer.apple.com/download/).
2. Open `AdaptiveDuoLab.xcworkspace` and select the **AdaptiveDuoLab** scheme.
3. Use the **iOS 26 SDK or later** for the baseline build. The deployment target is **iOS 17**.
4. For the full native Duo path, use **Xcode 27.1 / iOS 27.1 or later**, add `DUO_SDK` to **Active Compilation Conditions** and choose a compatible runtime.
5. Run the app and open **Settings → Open API Lab**.

The camera preview requires a physical device and camera permission.

## Demo scope

- Workspace's Book Fold and Tabletop modes are simulated previews. Native arrangements and region handling live in API Lab.
- Layout thresholds and split ratios are sample content preferences.
- Root selections and local drafts follow their view/session lifetime. The sample does not implement app-relaunch restoration for them.
- Layout Review uses local configuration rules. App Resizability is a development workflow discussed in the talk.
- The camera example previews only; it does not save photos, audio or video.
- Unit and UI tests are included. Xcode compilation and native runtime validation of this revision remain pending.

## Apple resources

- [Prepare your app for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111461/)
- [Raise the bar with iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111462/)
- [Strike a pose with adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/)
- [Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111466/)
