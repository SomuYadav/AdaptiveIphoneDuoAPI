import SwiftData
import SwiftUI

struct RootView: View {
    @Query(sort: \WorkItem.updatedAt, order: .reverse)
    private var items: [WorkItem]

    @State private var selectedCategory: WorkCategory? = .all
    @State private var presentation: CollectionPresentation
    @State private var pose: DemoPose
    @State private var showsAudit: Bool
    @State private var selectedTab: AppTab

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        _presentation = State(
            initialValue: Self.launchValue(
                named: "-demo-presentation",
                in: arguments,
                as: CollectionPresentation.self
            ) ?? .automatic
        )
        _pose = State(
            initialValue: Self.launchValue(
                named: "-demo-pose",
                in: arguments,
                as: DemoPose.self
            ) ?? .automatic
        )
        _showsAudit = State(initialValue: arguments.contains("-show-audit"))
        _selectedTab = State(
            initialValue: Self.launchValue(
                named: "-demo-tab",
                in: arguments,
                as: AppTab.self
            ) ?? .workspace
        )
    }

    private var activeCategory: WorkCategory {
        selectedCategory ?? .all
    }

    private var filteredItems: [WorkItem] {
        guard activeCategory != .all else { return items }
        return items.filter { $0.category == activeCategory }
    }

    var body: some View {
        tabs
            .sheet(isPresented: $showsAudit) {
                LayoutAuditView(
                    itemCount: filteredItems.count,
                    pose: pose,
                    presentation: presentation,
                    category: activeCategory
                )
            }
            .tint(.indigo)
    }

    // Keep app state above the native container. Preview poses change workspace
    // content only; the system remains responsible for tab bar placement.
    @ViewBuilder
    private var tabs: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $selectedTab) {
                Tab("Workspace", systemImage: "square.grid.2x2", value: AppTab.workspace) {
                    workspace
                }
                .accessibilityIdentifier(AppTab.workspace.accessibilityIdentifier)

                Tab("Review", systemImage: "checkmark.seal", value: AppTab.review) {
                    review
                }
                .accessibilityIdentifier(AppTab.review.accessibilityIdentifier)

                Tab("Settings", systemImage: "gearshape", value: AppTab.settings) {
                    settings
                }
                .accessibilityIdentifier(AppTab.settings.accessibilityIdentifier)
            }
        } else {
            TabView(selection: $selectedTab) {
                workspace
                    .tabItem { tabLabel(.workspace) }
                    .tag(AppTab.workspace)

                review
                    .tabItem { tabLabel(.review) }
                    .tag(AppTab.review)

                settings
                    .tabItem { tabLabel(.settings) }
                    .tag(AppTab.settings)
            }
        }
    }

    private func tabLabel(_ tab: AppTab) -> some View {
        Label(tab.rawValue, systemImage: tab.symbol)
            .accessibilityIdentifier(tab.accessibilityIdentifier)
    }

    private var workspace: some View {
        NavigationSplitView {
            List(selection: $selectedCategory) {
                ForEach(WorkCategory.allCases) { category in
                    NavigationLink(value: category) {
                        Label(category.rawValue, systemImage: category.symbol)
                    }
                    .accessibilityIdentifier("category.\(category.rawValue.lowercased())")
                }
            }
            .navigationTitle("Adaptive Duo Lab")
        } detail: {
            DashboardView(
                items: filteredItems,
                selectedCategory: activeCategory,
                presentation: $presentation,
                pose: $pose,
                showsAudit: $showsAudit
            )
        }
        .accessibilityIdentifier("workspace.screen")
    }

    private var review: some View {
        NavigationStack {
            LayoutAuditContent(
                itemCount: filteredItems.count,
                pose: pose,
                presentation: presentation,
                category: activeCategory
            )
        }
        .accessibilityIdentifier("review.screen")
    }

    private var settings: some View {
        NavigationStack {
            DemoSettingsView(
                category: Binding(
                    get: { activeCategory },
                    set: { selectedCategory = $0 }
                ),
                presentation: $presentation,
                pose: $pose,
                totalItemCount: items.count,
                filteredItemCount: filteredItems.count,
                items: filteredItems
            )
        }
        .accessibilityIdentifier("settings.screen")
    }

    private static func launchValue<Value: RawRepresentable>(
        named name: String,
        in arguments: [String],
        as type: Value.Type
    ) -> Value? where Value.RawValue == String {
        guard
            let index = arguments.firstIndex(of: name),
            arguments.indices.contains(index + 1)
        else {
            return nil
        }
        return Value(rawValue: arguments[index + 1])
    }
}
