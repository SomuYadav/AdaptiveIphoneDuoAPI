import Foundation
import SwiftData

enum WorkCategory: String, CaseIterable, Codable, Identifiable {
    case all = "All"
    case design = "Design"
    case engineering = "Engineering"
    case research = "Research"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .all: "square.grid.2x2"
        case .design: "paintpalette"
        case .engineering: "hammer"
        case .research: "sparkle.magnifyingglass"
        }
    }
}

enum WorkStatus: String, Codable {
    case planned = "Planned"
    case inProgress = "In progress"
    case complete = "Complete"

    var symbol: String {
        switch self {
        case .planned: "clock"
        case .inProgress: "circle.lefthalf.filled"
        case .complete: "checkmark.circle.fill"
        }
    }
}

@Model
final class WorkItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var categoryRawValue: String
    var statusRawValue: String
    var progress: Double
    var updatedAt: Date
    var symbolName: String

    init(
        id: UUID = UUID(),
        title: String,
        summary: String,
        category: WorkCategory,
        status: WorkStatus,
        progress: Double,
        updatedAt: Date,
        symbolName: String
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        categoryRawValue = category.rawValue
        statusRawValue = status.rawValue
        self.progress = progress
        self.updatedAt = updatedAt
        self.symbolName = symbolName
    }

    var category: WorkCategory {
        WorkCategory(rawValue: categoryRawValue) ?? .research
    }

    var status: WorkStatus {
        WorkStatus(rawValue: statusRawValue) ?? .planned
    }
}
