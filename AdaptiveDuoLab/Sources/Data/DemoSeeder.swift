import Foundation
import SwiftData

enum DemoSeeder {
    static func seedIfNeeded(in context: ModelContext, reset: Bool) throws {
        if reset {
            try context.delete(model: WorkItem.self)
        }

        let count = try context.fetchCount(FetchDescriptor<WorkItem>())
        guard count == 0 else { return }

        let now = Date()
        let records: [(String, String, WorkCategory, WorkStatus, Double, String)] = [
            ("Adaptive navigation", "Move naturally between collapsed and multi-column navigation.", .engineering, .complete, 1.0, "sidebar.left"),
            ("Safe-area review", "Keep foreground controls clear of cameras, bars, and asymmetric insets.", .design, .inProgress, 0.72, "rectangle.inset.filled"),
            ("Even grid columns", "Prefer balanced columns when a fold divides the available content region.", .design, .inProgress, 0.56, "square.grid.2x2"),
            ("Appium device flow", "Document the client, server, XCUITest Driver, WDA, and XCTest chain.", .research, .complete, 1.0, "point.3.connected.trianglepath.dotted"),
            ("Tabletop controls", "Keep content visible above the fold and touch controls in the lower region.", .engineering, .planned, 0.2, "rectangle.split.1x2"),
            ("Layout review", "Review local guidance for the selected pose and content mode.", .research, .inProgress, 0.65, "checkmark.seal"),
            ("Vertical toolbar audit", "Use symbols and system placements so controls adapt to a vertical edge.", .design, .planned, 0.35, "rectangle.trailinghalf.inset.filled"),
            ("Scene-aware geometry", "Make decisions from local geometry instead of main-screen assumptions.", .engineering, .complete, 1.0, "macwindow.on.rectangle")
        ]

        for (index, record) in records.enumerated() {
            context.insert(
                WorkItem(
                    title: record.0,
                    summary: record.1,
                    category: record.2,
                    status: record.3,
                    progress: record.4,
                    updatedAt: now.addingTimeInterval(TimeInterval(-index * 900)),
                    symbolName: record.5
                )
            )
        }
        try context.save()
    }
}
