import Foundation

/// Maps each example to its real source and availability. Hardware remains optional.
struct APICatalogEntry: Identifiable {
    let id: String
    let name: String
    let version: String
    let purpose: String
    let status: String
    let ordinaryPhone: String
    let source: String
    let documentation: String


    var demoRoute: APIDemoRoute? {
        switch id {
        case "arrangement", "regions", "hinge": .system
        case "overflow", "priority", "axis", "minimization", "compression", "edge", "vertical": .toolbar
        case "tabs", "tabPlacement": .tabs
        case "anylayout", "corners": .layout
        case "uikitCorners", "uikitSafeArea", "uikitNavigation", "uikitTabs": .uikit
        case "uikitBars": .uikitToolbar
        case "sheets": .presentations
        case "camera": .camera
        default: nil
        }
    }

    var documentationURL: URL? {
        URL(string: documentation.hasPrefix("https://")
            ? documentation
            : "https://developer.apple.com/documentation/swiftui/" + documentation)
    }

    static let entries: [Self] = [
        .init(id: "navigation", name: "NavigationSplitView", version: "iOS 16+",
              purpose: "Adapts sidebar and detail navigation to the available space.",
              status: "Implemented in Workspace",
              ordinaryPhone: "Collapses navigation in compact space; preserve the selected category above the container.",
              source: "RootView.workspace", documentation: "navigationsplitview"),
        .init(id: "fit", name: "ViewThatFits", version: "iOS 16+",
              purpose: "Chooses the first supplied view alternative that fits.",
              status: "Implemented in the dashboard header",
              ordinaryPhone: "The same horizontal, stacked and menu alternatives work on narrow iPhones and large text sizes.",
              source: "DashboardHeader", documentation: "viewthatfits"),
        .init(id: "geometry", name: "GeometryReader", version: "iOS 13+",
              purpose: "Supplies local space for content-fit decisions.",
              status: "Implemented in Workspace and the native API demo",
              ordinaryPhone: "Measures the actual content area; the app still supplies its own grid and header rules.",
              source: "DashboardView / SystemArrangementDemo", documentation: "geometryreader"),
        .init(id: "tabs", name: "Tab and TabView", version: "Tab: iOS 18+; TabView: iOS 13+",
              purpose: "Declares stable destinations and lets the system present native tabs.",
              status: "Implemented; iOS 17 uses tabItem and tags",
              ordinaryPhone: "The system chooses supported bar placement. A preview pose does not force vertical tabs.",
              source: "RootView.tabs", documentation: "tabview"),
        .init(id: "glass", name: "glassEffect", version: "iOS 26+",
              purpose: "Applies the system glass appearance to the demo panels.",
              status: "Implemented with a material fallback",
              ordinaryPhone: "Appearance adapts on iOS 26+; this effect does not fix content sizing or a fold layout.",
              source: "WorkItemCard.adaptivePanel", documentation: "view/glasseffect(_:in:)"),
        .init(id: "overflow", name: "ToolbarOverflowMenu", version: "iOS 27+",
              purpose: "Groups secondary toolbar actions in the system overflow presentation.",
              status: "Implemented in the interactive toolbar example",
              ordinaryPhone: "Useful whenever a supported system toolbar has limited room, independent of a hinge.",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "toolbaroverflowmenu"),
        .init(id: "priority", name: "visibilityPriority", version: "iOS 27+",
              purpose: "Prioritizes which toolbar content remains visible as space changes.",
              status: "Implemented in the interactive toolbar example",
              ordinaryPhone: "Prioritize essential actions and keep overflow actions reachable on every supported layout.",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "toolbarcontent/visibilitypriority(_:)"),
        .init(id: "arrangement", name: "ArrangementView", version: "iOS 27.1 beta+",
              purpose: "Arranges primary and secondary content for the size, traits and hardware context.",
              status: "Native demo source; requires DUO_SDK and iOS 27.1",
              ordinaryPhone: "Uses available space without inventing a fold. All records remain in primary; Summary is also a toolbar destination.",
              source: "SystemArrangementDemo / NativeArrangementContent", documentation: "arrangementview"),
        .init(id: "regions", name: "ReservedRegion and reservedRegions", version: "iOS 27.1 beta+",
              purpose: "Reports local division and occlusion frames, margins and active state.",
              status: "Live inspector and custom control avoidance example",
              ordinaryPhone: "A device may report occlusions without a fold. Empty and inactive results are valid; the avoidance example explicitly uses active frames to position its button.",
              source: "SystemArrangementDemo / ReservedRegionPlacement", documentation: "geometryproxy/reservedregions(kind:options:layoutdirectionbehavior:)"),
        .init(id: "axis", name: "ToolbarContent.axisBehavior", version: "iOS 27.1 beta+",
              purpose: "Controls whether custom toolbar content can participate in each bar axis.",
              status: "Implemented with a selectable custom-control axis",
              ordinaryPhone: "Prefer system defaults; provide another route for any action excluded from an axis.",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "toolbarcontent/axisbehavior(_:)"),
        .init(id: "minimization", name: "toolbarMinimizationBehavior", version: "iOS 27+",
              purpose: "Controls whether a toolbar can minimize as content changes.",
              status: "Implemented with selectable toolbar preferences",
              ordinaryPhone: "Keep actions discoverable when bars minimize; this is different from changing their axis.",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "view/toolbarminimizationbehavior(_:for:)"),
        .init(id: "compression", name: "toolbarVerticalCompressionBehavior", version: "iOS 27.1 beta+",
              purpose: "Controls supported vertical toolbar compression behavior.",
              status: "Implemented with selectable toolbar preferences",
              ordinaryPhone: "Custom controls still need readable compact representations and complete labels.",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "view/toolbarverticalcompressionbehavior(_:)"),
        .init(id: "edge", name: "toolbarVerticalEdge", version: "iOS 27.1 beta+",
              purpose: "Reports the preferred vertical toolbar edge, even while a bar is hidden.",
              status: "Implemented for custom-control adaptation and diagnostics",
              ordinaryPhone: "A nil value means this context does not use vertical bars; it is not a visibility test.",
              source: "NativeToolbarRecords / NativeReviewControl", documentation: "environmentvalues/toolbarverticaledge"),
        .init(id: "vertical", name: "toolbarVerticalBehavior", version: "iOS 27.1 beta+",
              purpose: "Expresses a preference for vertical toolbar presentation.",
              status: "Implemented with selectable toolbar preferences",
              ordinaryPhone: "A preference does not create a hardware capability or force a universal bar position.",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "view/toolbarverticalbehavior(_:)"),
        .init(id: "hinge", name: "onHingeChange and DeviceHingeContext", version: "iOS 27.1 beta+",
              purpose: "Receives optional physical hinge information for diagnostics or effects.",
              status: "Native demo source; read-only event display",
              ordinaryPhone: "The context can contain no hinge. Core layout follows the container, not a hinge angle threshold.",
              source: "NativeArrangementContent", documentation: "view/onhingechange(isenabled:_:)"),
        .init(id: "camera", name: "CameraCaptureAccessory", version: "iOS 27.1 beta+",
              purpose: "Supports an eligible camera-capture accessory presentation on another display.",
              status: "Implemented in the user-started camera preview",
              ordinaryPhone: "The rear-camera preview remains usable when the system reports no accessory. Camera permission is requested only after Start.",
              source: "CameraAPIDemo / NativeCameraDemo", documentation: "cameracaptureaccessory"),
        .init(id: "anylayout", name: "AnyLayout", version: "iOS 16+",
              purpose: "Reflows the same view hierarchy while preserving editor state.",
              status: "Interactive horizontal/vertical task editor",
              ordinaryPhone: "Narrow windows and accessibility text choose a vertical layout.",
              source: "LayoutAPIDemo", documentation: "anylayout"),
        .init(id: "corners", name: "ConcentricRectangle", version: "iOS 26+",
              purpose: "Resolves inner corner curves from the containing shape and inset.",
              status: "Interactive concentric/fixed comparison and inset slider",
              ordinaryPhone: "Older systems keep the editor and show corner availability.",
              source: "LayoutAPIDemo / ConcentricCornerDemo", documentation: "concentricrectangle"),
        .init(id: "tabPlacement", name: "defaultTabBarPlacement", version: "iOS 27+; adaptable placement iOS 18+",
              purpose: "Sets the default tab/sidebar presentation preference in supported contexts.",
              status: "Native tab session with shared note state",
              ordinaryPhone: "The system keeps supported placement; iPad uses defaultAdaptableTabBarPlacement.",
              source: "TabAPIDemo / TabDemoSession", documentation: "view/defaulttabbarplacement(_:)"),
        .init(id: "uikitCorners", name: "UICornerConfiguration", version: "iOS 26+",
              purpose: "Aligns nested UIKit view corners with their container.",
              status: "Interactive UIKit inset and corner comparison",
              ordinaryPhone: "Earlier systems use fixed layer corner radii.",
              source: "UIKitAPIDemo / UIKitLayoutController", documentation: "https://developer.apple.com/documentation/uikit/uicornerconfiguration"),
        .init(id: "uikitSafeArea", name: "safeAreaLayoutGuide and local traits", version: "iOS 11+; used with iOS 17 baseline",
              purpose: "Keeps controls within independent safe-area edges and reads local display scale.",
              status: "Hosted UIKit Auto Layout and asymmetric inset experiment",
              ordinaryPhone: "Left and right insets remain independent through rotation and resizing.",
              source: "UIKitAPIDemo / UIKitLayoutController", documentation: "https://developer.apple.com/documentation/uikit/uiview/safearealayoutguide"),
        .init(id: "uikitNavigation", name: "UISplitViewController", version: "iOS 3.2+; column style iOS 14+",
              purpose: "Collapses and expands native navigation columns.",
              status: "Hosted UIKit list/detail with editable draft",
              ordinaryPhone: "Native compact navigation preserves the selected draft.",
              source: "UIKitAPIDemo", documentation: "https://developer.apple.com/documentation/uikit/uisplitviewcontroller"),
        .init(id: "uikitTabs", name: "UITabBarController sidebar", version: "Sidebar mode iOS 18+; placement iOS 27+",
              purpose: "Presents native UIKit destinations with a sidebar preference.",
              status: "Full-screen UIKit tab comparison",
              ordinaryPhone: "Normal tabs remain on contexts without sidebar support.",
              source: "UIKitAPIDemo", documentation: "https://developer.apple.com/documentation/uikit/uitabbarcontroller/sidebar-swift.class/preferredplacement"),
        .init(id: "uikitBars", name: "UIKit toolbar adaptation", version: "Overflow iOS 16+; priority iOS 27+; vertical controls iOS 27.1+",
              purpose: "Adapts UIKit navigation-managed actions, priority, overflow and custom controls.",
              status: "Interactive UIKit toolbar session",
              ordinaryPhone: "Baseline system actions remain available on earlier systems.",
              source: "UIKitToolbarAPIDemo", documentation: "https://developer.apple.com/documentation/uikit/uibarbuttonitem/visibilitypriority"),
        .init(id: "sheets", name: "sheet and presentationDetents", version: "iOS 16+ detents",
              purpose: "Presents a resizable editor while its parent retains the draft.",
              status: "Working sheet, popover, alert and action menu",
              ordinaryPhone: "Native presentations adapt to available space on every supported phone.",
              source: "PresentationAPIDemo", documentation: "view/presentationdetents(_:)")
    ]
}


enum APIDemoRoute: String, CaseIterable, Identifiable {
    case system, toolbar, tabs, layout, uikit, uikitToolbar, presentations, camera
    var id: Self { self }

    var title: String {
        switch self {
        case .system: "System layout and regions"
        case .toolbar: "SwiftUI toolbar actions"
        case .tabs: "Tabs and sidebar"
        case .layout: "Reflow and concentric corners"
        case .uikit: "UIKit layout and navigation"
        case .uikitToolbar: "UIKit toolbar actions"
        case .presentations: "Sheets and presentations"
        case .camera: "Camera accessory"
        }
    }

    var symbol: String {
        switch self {
        case .system: "rectangle.split.2x1"
        case .toolbar: "ellipsis.rectangle"
        case .tabs: "sidebar.left"
        case .layout: "rectangle.2.swap"
        case .uikit: "square.stack.3d.up"
        case .uikitToolbar: "slider.horizontal.3"
        case .presentations: "rectangle.bottomthird.inset.filled"
        case .camera: "camera"
        }
    }

    var accessibilityIdentifier: String {
        self == .system ? "apiLab.systemDemo" : "apiLab.demo.\(rawValue)"
    }
}
