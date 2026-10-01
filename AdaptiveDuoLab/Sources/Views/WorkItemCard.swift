import SwiftUI

struct WorkItemCard: View {
    let item: WorkItem
    let compact: Bool
    @ScaledMetric(relativeTo: .title2) private var symbolSize: CGFloat = 42

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 10 : 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: item.symbolName)
                    .font(.title2)
                    .foregroundStyle(.indigo)
                    .frame(width: symbolSize, height: symbolSize)
                    .background(.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityHidden(true)

                Spacer()

                Label(item.status.rawValue, systemImage: item.status.symbol)
                    .font(.caption.bold())
                    .foregroundStyle(statusColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(item.title)
                .font(compact ? .headline : .title3.bold())
                .fixedSize(horizontal: false, vertical: true)

            Text(item.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            ProgressView(value: item.progress)
                .tint(statusColor)
                .accessibilityLabel("Progress")

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    categoryLabel
                    Spacer(minLength: 8)
                    updateLabel
                }
                .fixedSize(horizontal: true, vertical: false)

                VStack(alignment: .leading, spacing: 4) {
                    categoryLabel
                    updateLabel
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .adaptivePanel()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("workItem.\(item.id.uuidString)")
    }

    private var categoryLabel: some View {
        Label(item.category.rawValue, systemImage: item.category.symbol)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var updateLabel: some View {
        Text(item.updatedAt, style: .relative)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var statusColor: Color {
        switch item.status {
        case .planned: .orange
        case .inProgress: .indigo
        case .complete: .green
        }
    }
}

extension View {
    @ViewBuilder
    func adaptivePanel() -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: .rect(cornerRadius: 22))
        } else {
            background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
        }
    }
}
