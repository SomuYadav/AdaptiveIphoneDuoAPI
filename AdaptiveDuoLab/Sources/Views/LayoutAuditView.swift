import SwiftUI

struct LayoutAuditView: View {
    let itemCount: Int
    let pose: DemoPose
    let presentation: CollectionPresentation
    var category: WorkCategory = .all

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            LayoutAuditContent(
                itemCount: itemCount,
                pose: pose,
                presentation: presentation,
                category: category
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("audit.done")
                }
            }
        }
        .accessibilityIdentifier("audit.sheet")
    }
}

/// The same configuration guidance is available as a tab and a modal sheet.
struct LayoutAuditContent: View {
    let itemCount: Int
    let pose: DemoPose
    let presentation: CollectionPresentation
    let category: WorkCategory

    private var recommendations: [String] {
        var values = [
            "Use local geometry and size classes instead of checking device type or orientation.",
            "Keep interactive foreground controls inside the safe area.",
            "Allow decorative backgrounds to extend behind system bars."
        ]

        if pose == .bookFold {
            values.append("Keep every card inside one region and away from the fold.")
        } else if pose == .tabletop {
            values.append("Place glanceable content above the fold and frequent controls below it.")
        } else if presentation == .list {
            values.append("Keep continuous lists continuous rather than displacing individual rows.")
        } else {
            values.append("Confirm every grid item remains readable and interactive at the current width.")
        }

        return values
    }

    var body: some View {
        List {
            Section("Current configuration") {
                configurationRow("Category", value: category.rawValue, id: "review.category")
                configurationRow("Pose", value: pose.rawValue, id: "review.pose")
                configurationRow("Content mode", value: presentation.rawValue, id: "review.presentation")
                configurationRow("Records", value: itemCount.formatted(), id: "review.recordCount")
            }

            Section("Layout checks") {
                ForEach(recommendations, id: \.self) {
                    Label($0, systemImage: "checkmark.seal")
                }
            }

            Section {
                Text("These checks follow the selected configuration. Use the API Lab to inspect actual system geometry, then verify the layout while resizing.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Layout Review")
    }

    private func configurationRow(_ title: String, value: String, id: String) -> some View {
        LabeledContent(title, value: value)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(value)
            .accessibilityIdentifier(id)
    }
}
