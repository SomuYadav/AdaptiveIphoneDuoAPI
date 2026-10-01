import SwiftUI

struct DashboardView: View {
    let items: [WorkItem]
    let selectedCategory: WorkCategory
    @Binding var presentation: CollectionPresentation
    @Binding var pose: DemoPose
    @Binding var showsAudit: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { proxy in
            let decision = AdaptiveLayoutPolicy.decision(
                width: proxy.size.width,
                pose: pose,
                presentation: presentation,
                height: proxy.size.height,
                dynamicTypeSize: dynamicTypeSize
            )
            // A demo content budget, independent of device model or orientation.
            // Large text and short windows reserve the detail area for records.
            let usesCompactControls = proxy.size.height < 520 || dynamicTypeSize >= .xxxLarge

            ZStack {
                LinearGradient(
                    colors: [
                        Color.indigo.opacity(0.18),
                        Color.cyan.opacity(0.08),
                        Color(uiColor: .systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 14) {
                    if usesCompactControls {
                        Text(decision.usesGrid ? "\(decision.columnCount)-column grid" : "Adaptive list")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("layout.decision")
                    } else {
                        DashboardHeader(
                            presentation: $presentation,
                            pose: $pose,
                            showsAudit: $showsAudit,
                            decision: decision
                        )
                    }

                    content(for: decision)
                }
                .padding(.horizontal, decision.contentPadding)
                .padding(.top, 12)
            }
            .navigationTitle(usesCompactControls ? "Adaptive Workspace" : selectedCategory.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if usesCompactControls {
                    ToolbarItem(placement: .topBarTrailing) {
                        compactOptionsMenu
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showsAudit = true
                        } label: {
                            Label("Layout Review", systemImage: "checkmark.seal")
                        }
                        .labelStyle(.iconOnly)
                        .accessibilityIdentifier("audit.open")
                    }
                }
            }
        }
    }

    private var compactOptionsMenu: some View {
        Menu {
            Section("Layout") {
                ForEach(CollectionPresentation.allCases) { option in
                    Button {
                        withAnimation(.snappy) {
                            presentation = option
                        }
                    } label: {
                        Label(option.rawValue, systemImage: option.symbol)
                    }
                    .accessibilityIdentifier("layout.\(option.rawValue.lowercased())")
                }
            }

            Menu {
                Picker("Preview pose", selection: $pose) {
                    ForEach(DemoPose.allCases) { option in
                        Label(option.rawValue, systemImage: option.symbol)
                            .tag(option)
                    }
                }
            } label: {
                Label(pose.rawValue, systemImage: pose.symbol)
            }
            .accessibilityLabel("Preview pose")
            .accessibilityValue(pose.rawValue)
            .accessibilityIdentifier("pose.menu")
        } label: {
            Label("Workspace options", systemImage: "slider.horizontal.3")
        }
        .labelStyle(.iconOnly)
        .accessibilityValue(presentation.rawValue)
        .accessibilityIdentifier("layout.menu")
    }

    @ViewBuilder
    private func content(for decision: LayoutDecision) -> some View {
        switch decision.composition {
        case .single:
            ItemCollection(items: items, decision: decision)
        case .book:
            BookFoldLayout(items: items)
        case .tabletop:
            TabletopLayout(items: items, decision: decision)
        }
    }
}

private struct DashboardHeader: View {
    @Binding var presentation: CollectionPresentation
    @Binding var pose: DemoPose
    @Binding var showsAudit: Bool
    let decision: LayoutDecision

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 16) {
                    heading
                    Spacer(minLength: 12)
                    auditButton
                }
                .fixedSize(horizontal: true, vertical: false)

                VStack(alignment: .leading, spacing: 12) {
                    heading
                    auditButton
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    layoutButtons
                    Spacer(minLength: 12)
                    poseControl
                    decisionBadge
                }
                .fixedSize(horizontal: true, vertical: false)

                VStack(alignment: .leading, spacing: 10) {
                    layoutControls
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 12) {
                            poseControl
                            Spacer(minLength: 12)
                            decisionBadge
                        }
                        .fixedSize(horizontal: true, vertical: false)

                        VStack(alignment: .leading, spacing: 10) {
                            poseControl
                            decisionBadge
                        }
                    }
                }
            }
        }
        .padding(18)
        .adaptivePanel()
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Adaptive Workspace")
                .font(.largeTitle.bold())
            Text(layoutExplanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var layoutExplanation: String {
        if pose == .bookFold && decision.composition == .single {
            return "Book preview uses one region when available space or text size requires it."
        }
        if pose == .tabletop && decision.composition == .single {
            return "Tabletop preview uses one collection when window height or text size requires it."
        }
        return pose.explanation
    }

    private var auditButton: some View {
        Button {
            showsAudit = true
        } label: {
            Label("Layout Review", systemImage: "checkmark.seal")
        }
        .buttonStyle(.borderedProminent)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityIdentifier("audit.open")
    }

    private var layoutControls: some View {
        ViewThatFits(in: .horizontal) {
            layoutButtons
                .fixedSize(horizontal: true, vertical: false)

            Menu {
                ForEach(CollectionPresentation.allCases) { option in
                    Button {
                        select(option)
                    } label: {
                        Label(option.rawValue, systemImage: option.symbol)
                    }
                    .accessibilityIdentifier("layout.\(option.rawValue.lowercased())")
                }
            } label: {
                Label(presentation.rawValue, systemImage: presentation.symbol)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Layout")
            .accessibilityValue(presentation.rawValue)
            .accessibilityIdentifier("layout.menu")
        }
    }

    private var layoutButtons: some View {
        HStack(spacing: 8) {
            layoutButton(.automatic)
            layoutButton(.list)
            layoutButton(.grid)
        }
    }

    @ViewBuilder
    private func layoutButton(_ option: CollectionPresentation) -> some View {
        if option == presentation {
            Button {
                select(option)
            } label: {
                Label(option.rawValue, systemImage: option.symbol)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("layout.\(option.rawValue.lowercased())")
        } else {
            Button {
                select(option)
            } label: {
                Label(option.rawValue, systemImage: option.symbol)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("layout.\(option.rawValue.lowercased())")
        }
    }

    private func select(_ option: CollectionPresentation) {
        withAnimation(.snappy) {
            presentation = option
        }
    }

    private var poseControl: some View {
        Menu {
            Picker("Preview pose", selection: $pose) {
                ForEach(DemoPose.allCases) { option in
                    Label(option.rawValue, systemImage: option.symbol)
                        .tag(option)
                }
            }
        } label: {
            Label(pose.rawValue, systemImage: pose.symbol)
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("pose.menu")
    }

    private var decisionBadge: some View {
        Text(decision.usesGrid ? "\(decision.columnCount)-column grid" : "Adaptive list")
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.indigo.opacity(0.12), in: Capsule())
            .accessibilityIdentifier("layout.decision")
    }
}

private struct ItemCollection: View {
    let items: [WorkItem]
    let decision: LayoutDecision

    var body: some View {
        ScrollView {
            if decision.usesGrid {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: 14),
                        count: decision.columnCount
                    ),
                    spacing: 14
                ) {
                    cards
                }
            } else {
                LazyVStack(spacing: 12) {
                    cards
                }
            }
        }
        .contentMargins(.bottom, 24, for: .scrollContent)
        .accessibilityIdentifier("dashboard.collection")
    }

    @ViewBuilder
    private var cards: some View {
        ForEach(items) { item in
            WorkItemCard(item: item, compact: decision.usesGrid)
        }
    }
}

private struct BookFoldLayout: View {
    let items: [WorkItem]

    var body: some View {
        HStack(spacing: 0) {
            DuoRegion(
                title: "Leading region",
                items: items.enumerated().compactMap {
                    $0.offset.isMultiple(of: 2) ? $0.element : nil
                }
            )

            LinearGradient(
                colors: [.black.opacity(0.42), .indigo.opacity(0.32), .black.opacity(0.42)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 26)
            .overlay {
                Text("FOLD")
                    .font(.caption2.bold())
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize()
                    .rotationEffect(.degrees(-90))
            }

            DuoRegion(
                title: "Trailing region",
                items: items.enumerated().compactMap {
                    $0.offset.isMultiple(of: 2) ? nil : $0.element
                }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityIdentifier("pose.bookLayout")
    }
}

private struct DuoRegion: View {
    let title: String
    let items: [WorkItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(items) { item in
                        WorkItemCard(item: item, compact: true)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.thinMaterial)
    }
}

private struct TabletopLayout: View {
    let items: [WorkItem]
    let decision: LayoutDecision

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: "rectangle.split.1x2")
                    .font(.system(size: 42))
                    .foregroundStyle(.indigo)
                Text("Content region")
                    .font(.title2.bold())
                Text("High-visibility content stays above the simulated hinge.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.thinMaterial)

            Rectangle()
                .fill(.black.opacity(0.55))
                .frame(height: 20)
                .overlay {
                    Text("SIMULATED HINGE")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.82))
                }

            ItemCollection(items: items, decision: decision)
                .frame(maxHeight: .infinity)
                .padding(.top, 12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityIdentifier("pose.tabletopLayout")
    }
}
