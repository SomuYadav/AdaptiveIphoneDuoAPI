# Use Apple’s App Resizability skill with AdaptiveDuoLab

Research checked: September 26, 2026. This is a workflow for running the Apple-provided skills on a Mac. The bundled Apple skills were not executed while preparing this project, and this document is not an export of an Apple skill.


The included presentation now dedicates slide 15 to this workflow, using `Docs/Screenshots/06_app_resizability.png`. The native API examples can be launched with `./Automation/run-api-demos.sh` after selecting the matching Xcode SDK and Simulator. The API Lab includes toolbar, layout, UIKit, camera and presentation examples; it does not execute the development skill itself.

## The skill that was missing from the explanation

Apple’s **App Resizability** skill is included in **Xcode 27.1**. It is the renamed app modernization skill introduced at WWDC26, now expanded to support **SwiftUI and iPhone Duo**. Apple introduces the updated name in [Prepare your app for iPhone Duo, 9:12](https://developer.apple.com/videos/play/tech-talks/111461/?time=552).

| Apple-provided skill | Where it fits |
| --- | --- |
| App Resizability — Xcode 27.1 | Review and update an existing app for resizing and adaptive layouts, including SwiftUI and Duo. |
| SwiftUI Specialist Skill — Xcode 27 | Review SwiftUI implementation, data flow, performance and correctness. |
| What’s New In SwiftUI Skill — Xcode 27 | Help adopt new SwiftUI APIs with current framework guidance. |

The latter two names and their availability in Coding Assistant are documented in [What’s new in SwiftUI](https://developer.apple.com/videos/play/wwdc2026/269/). These are development-time skills. They are not SwiftUI modifiers, libraries linked into the app, or features of the app’s Review screen.

## Three kinds of automatic behavior

| Mechanism | What happens | What the developer still provides |
| --- | --- | --- |
| Standard SwiftUI containers | Navigation, tabs, bars and presentations respond to supported environments. | Appropriate content hierarchy, readable custom content, and preserved state. |
| Building with the newer SDK | The iOS 27.1 SDK enables the fuller Duo screen layout and updated standard-bar behavior described by Apple. | An SDK-compatible build and validation of the resulting layout. Updating the SDK does not require raising this app’s iOS 17 deployment target. |
| App Resizability with a coding agent | The agent uses project context and skill guidance to propose or perform source changes. | Clear scope, source review, successful builds and tests, and validation of the user experience. |

Apple demonstrates the first two mechanisms in [Prepare your app for iPhone Duo, 0:30](https://developer.apple.com/videos/play/tech-talks/111461/?time=30) and [5:01](https://developer.apple.com/videos/play/tech-talks/111461/?time=301). There is no documented one-line runtime API that fixes every custom screen in an application.

The earlier modernization skill’s demonstrated work includes replacing main-screen references, updating orientation-dependent layout, and migrating legacy UIKit app lifecycle code to scenes. Apple also explains that complicated work can require questions, and unfinished large tasks can be recorded in comments. See [Modernize your UIKit app, 14:07](https://developer.apple.com/videos/play/wwdc2026/278/?time=847). Treat this as assisted implementation, with results to verify.

## Apply it to the entire existing workspace

1. Keep a source-control checkpoint of the project, then open `AdaptiveDuoLab.xcworkspace` in Xcode 27.1. Choose the `AdaptiveDuoLab` scheme and an installed simulator runtime. Keep the deployment target at iOS 17 unless a separate product decision changes it.
2. Open Coding Assistant with an agent configured. Type `/` to discover loaded skills and commands, and choose the displayed App Resizability skill. Use completion rather than assuming a slash-command spelling. Apple describes this discovery mechanism in [Coding Intelligence for Beginners, 5:31](https://developer.apple.com/videos/play/wwdc2026/8007/?time=331).
3. Give the agent the whole workspace and the prompt below. The filename list is a starting map; ask it to inspect related files and the API Lab too.
4. Inspect the proposed changes and their effect on the existing flows. Ask the agent to build and run the project’s tests, fix failures, and list any checks it cannot complete.
5. Exercise the app in Device Hub across changing widths and Duo poses, then validate applicable flows on real devices. Apple demonstrates resizing tools in [Modernize your UIKit app, 8:19](https://developer.apple.com/videos/play/wwdc2026/278/?time=499).

Suggested project prompt — authored for AdaptiveDuoLab:

```text
Use Apple’s App Resizability skill to audit and update this entire
AdaptiveDuoLab workspace, including every tab, sheet and custom content view.

Preserve the iOS 17 deployment target, the existing SwiftData model and seeded
records, selected category, presentation choice, navigation state and tab state.
Inspect related files as needed, starting with AdaptiveDuoLabApp, RootView,
DashboardView, WorkItemCard, LayoutAuditView, DemoSettingsView,
AdaptiveLayoutPolicy, LayoutModels and the API Lab.

Find fixed-screen, device-idiom, orientation, safe-area and text-size assumptions.
Use local available geometry and standard navigation containers where suitable.
Keep foreground controls reachable and handle asymmetric safe areas correctly.
Review narrow split panes, ordinary iPhones, iPad, resizable iPhone windows,
Dynamic Type, long labels and right-to-left layout.

Separate automatic system adaptation from APIs that need explicit adoption.
For each proposed new API, verify its symbol, SDK and OS availability, identify
the actual call site, and implement the older-OS fallback. Do not add camera or
hinge behavior unless it serves a concrete feature. Keep simulated demo poses
clearly separate from real device geometry and capability observations.

Produce a file-by-file issue and change list, then implement the applicable
fixes. Build the app and run the existing unit and UI tests. Validate state
continuity while switching tabs, categories, sizes and presentations. Report
the exact checks executed, results, remaining issues and checks not executed.
Do not mark an issue fixed solely because its source code was changed.
```

The app’s policy thresholds are example product choices, not Apple-prescribed breakpoints. Keep them only where content measurements and actual usability justify them.

## Follow up with targeted SwiftUI review

Once layout changes build, use the SwiftUI Specialist Skill for correctness and the What’s New In SwiftUI Skill for API adoption. Suggested follow-up prompt:

```text
Use the SwiftUI Specialist Skill and What’s New In SwiftUI Skill to review the
updated AdaptiveDuoLab implementation. Verify stable view identity and state
ownership across TabView, NavigationSplitView, sheets and layout alternatives.
Check Dynamic Type, VoiceOver labels, main-actor work and collection rendering.

Compare the API Lab and API adoption guide with the actual source. Label each
API as used by the app, demonstrated in the lab, documented only, or unavailable
on this build/runtime. Remove unsupported claims. Keep the iOS 17 fallback and
check every availability boundary using the selected Xcode SDK.

Build and rerun affected tests. Give a short explanation of each material
change and its validation evidence. List anything requiring real-device review.
```

These prompts are project guidance, not official Apple skill content or guaranteed invocation syntax.

## What the source audit already establishes

| Existing source | Finding | Implication |
| --- | --- | --- |
| `Sources/App/AdaptiveDuoLabApp.swift` | SwiftUI `App` with `WindowGroup` and a shared SwiftData model container. | Legacy UIKit scene migration is not the starting problem in this app. |
| `Sources/Views/RootView.swift` | Native tabs and `NavigationSplitView`; shared workspace choices are owned above tab content. | Review continuity and presentation behavior; preserve this ownership during refactoring. |
| `Sources/Views/DashboardView.swift` | Local `GeometryReader` measurement and `ViewThatFits` alternatives. | There is already a flexible baseline; verify custom content within its actual available space. |
| `Sources` audit | No `UIScreen.main`, `UIDevice`, `userInterfaceIdiom` or `interfaceOrientation` references were found in the inspected baseline. | Do not report replacements for these patterns unless subsequent changes introduce them. |

Remaining validation work includes narrow panes and large text, safe areas on each side, real Duo bar placement, state continuity during resizing and transitions, and SDK/runtime availability. Screenshots taken before the changes are evidence of the previous UI only. Manually choosing a preview pose is not proof that a real hinge API or system pose transition was exercised.

The project’s Review destination is a local layout checklist. It does not run Apple’s Xcode skills. The API Lab and [API adoption guide](API_Adoption_Guide.md) identify current implementation and demonstrations; reconcile those statuses with successful builds on the selected Mac toolchain.

## Export Apple skills for another coding tool

Apple publishes this command in [Modernize your UIKit app, 15:05](https://developer.apple.com/videos/play/wwdc2026/278/?time=905):

```bash
xcrun agent skills export
```

Run it on the Mac with the intended Xcode selected. Inspect the command’s output for the exported Markdown files, then import them using the receiving coding tool’s documented skill mechanism. The cited talk does not establish a universal export directory or external-agent installation path. Exporting guidance does not run a migration or alter the app’s runtime behavior.

Apple’s skill files and Xcode are not included in this project archive. If a skill is absent from Coding Assistant, check the installed Xcode version and the list of loaded skills before making an invocation claim.

## Keep third-party guidance distinct

[SwiftUI Expert Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) is a separate community skill. Its [5.1.0 release](https://github.com/AvdLee/SwiftUI-Agent-Skill/releases/tag/5.1.0) adds resizability and iPhone Duo guidance. It can supplement a coding workflow, but it is not Apple’s App Resizability skill.

The POC’s proposed AIHubServices integration is also separate. Neither that service idea nor a locally generated layout recommendation proves that any Apple development skill was invoked.
