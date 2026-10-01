import SwiftUI

enum AdaptiveLayoutPolicy {
    static func decision(
        width: CGFloat,
        pose: DemoPose,
        presentation: CollectionPresentation,
        height: CGFloat = .infinity,
        dynamicTypeSize: DynamicTypeSize = .large
    ) -> LayoutDecision {
        let contentPadding: CGFloat = width < 500 ? 16 : 24
        let needsReadableColumn = dynamicTypeSize.isAccessibilitySize
        // The simulated book has a 26-point divider and 14-point padding on
        // each side of each region. Measure the room left for the actual card.
        // This is a sample content-fit rule, not a device or display breakpoint.
        let bookCardWidth = (width - contentPadding * 2 - 26) / 2 - 28
        let hasRoomForBook = bookCardWidth >= 280 && !needsReadableColumn
        // This is a demo content budget, not a hardware or orientation check.
        // Preserve the selected pose while rendering a continuous collection
        // when the tabletop placeholder would compete with readable records.
        let hasRoomForTabletop = height >= 520 && !needsReadableColumn
        let composition: AdaptiveComposition = switch pose {
        case .bookFold: hasRoomForBook ? .book : .single
        case .tabletop: hasRoomForTabletop ? .tabletop : .single
        default: .single
        }

        let automaticGrid = width >= 620 && !needsReadableColumn
        let usesGrid = switch presentation {
        case .automatic: automaticGrid
        case .list: false
        case .grid: true
        }

        let columns: Int
        if !usesGrid || needsReadableColumn {
            columns = 1
        } else if width >= 1_100 {
            columns = 4
        } else if width >= 820 {
            columns = 3
        } else if width >= 560 {
            columns = 2
        } else {
            columns = 1
        }

        return LayoutDecision(
            usesGrid: usesGrid,
            columnCount: composition == .book ? 2 : columns,
            composition: composition,
            contentPadding: contentPadding
        )
    }
}
