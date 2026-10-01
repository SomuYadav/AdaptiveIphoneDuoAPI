import Foundation

/// Stable destinations shared by modern and legacy native tab containers.
enum AppTab: String, CaseIterable, Identifiable {
    case workspace = "Workspace"
    case review = "Review"
    case settings = "Settings"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .workspace: "square.grid.2x2"
        case .review: "checkmark.seal"
        case .settings: "gearshape"
        }
    }

    var accessibilityIdentifier: String {
        "tabs.\(rawValue.lowercased())"
    }
}
