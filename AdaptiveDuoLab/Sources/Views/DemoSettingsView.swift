import SwiftUI

struct DemoSettingsView: View {
    @Binding var category: WorkCategory
    @Binding var presentation: CollectionPresentation
    @Binding var pose: DemoPose
    let totalItemCount: Int
    let filteredItemCount: Int
    let items: [WorkItem]

    @State private var showsAPILab = false

    var body: some View {
        Form {
            Section {
                Button {
                    showsAPILab = true
                } label: {
                    Label("Open API Lab", systemImage: "curlybraces")
                }
                .accessibilityIdentifier("settings.apiLab")
            } header: {
                Text("Apple API examples")
            } footer: {
                Text("Explore what each API changes, its availability, and the live system-layout examples.")
            }

            Section {
                Picker("Category", selection: $category) {
                    ForEach(WorkCategory.allCases) { option in
                        Label(option.rawValue, systemImage: option.symbol)
                            .tag(option)
                    }
                }
                .accessibilityIdentifier("settings.category")
                .accessibilityValue(category.rawValue)

                Picker("Content mode", selection: $presentation) {
                    ForEach(CollectionPresentation.allCases) { option in
                        Label(option.rawValue, systemImage: option.symbol)
                            .tag(option)
                    }
                }
                .accessibilityIdentifier("settings.presentation")
                .accessibilityValue(presentation.rawValue)

                Picker("Preview pose", selection: $pose) {
                    ForEach(DemoPose.allCases) { option in
                        Label(option.rawValue, systemImage: option.symbol)
                            .tag(option)
                    }
                }
                .accessibilityIdentifier("settings.pose")
                .accessibilityValue(pose.rawValue)
            } header: {
                Text("Workspace configuration")
            } footer: {
                Text("Changes apply to Workspace and Review. Preview poses simulate content layouts; the system chooses the tab bar position.")
            }
            .pickerStyle(.menu)

            Section("Records") {
                recordCount("In selected category", count: filteredItemCount, id: "settings.filteredCount")
                recordCount("All records", count: totalItemCount, id: "settings.recordCount")
            }
        }
        .navigationTitle("Settings")
        .fullScreenCover(isPresented: $showsAPILab) {
            APILabView(items: items, category: category)
        }
    }

    private func recordCount(_ title: String, count: Int, id: String) -> some View {
        LabeledContent(title, value: count.formatted())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(count.formatted())
            .accessibilityIdentifier(id)
    }
}
