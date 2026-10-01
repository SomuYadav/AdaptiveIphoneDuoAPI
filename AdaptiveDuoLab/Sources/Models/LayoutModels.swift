import SwiftUI

enum CollectionPresentation: String, CaseIterable, Identifiable {
    case automatic = "Automatic"
    case list = "List"
    case grid = "Grid"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .automatic: "wand.and.stars"
        case .list: "list.bullet"
        case .grid: "square.grid.2x2"
        }
    }
}

enum DemoPose: String, CaseIterable, Identifiable {
    case automatic = "Current Window"
    case outerPortrait = "Outer Portrait"
    case outerLandscape = "Outer Landscape"
    case innerOpen = "Inner Open"
    case bookFold = "Book Fold"
    case tabletop = "Tabletop"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .automatic: "iphone"
        case .outerPortrait: "rectangle.portrait"
        case .outerLandscape: "rectangle"
        case .innerOpen: "rectangle.split.2x1"
        case .bookFold: "book.closed"
        case .tabletop: "rectangle.split.1x2"
        }
    }

    var explanation: String {
        switch self {
        case .automatic: "Uses the available content size and text size."
        case .outerPortrait: "Portrait preview label. Resize the window to test narrow content."
        case .outerLandscape: "Landscape preview label. The actual content width controls density."
        case .innerOpen: "Open-display preview label. Native navigation controls sidebar visibility."
        case .bookFold: "Simulated fold regions when cards fit, with one collection for constrained layouts."
        case .tabletop: "Simulated content above records when space permits, with one collection as fallback."
        }
    }
}

enum AdaptiveComposition: Equatable {
    case single
    case book
    case tabletop
}

struct LayoutDecision: Equatable {
    let usesGrid: Bool
    let columnCount: Int
    let composition: AdaptiveComposition
    let contentPadding: CGFloat
}
