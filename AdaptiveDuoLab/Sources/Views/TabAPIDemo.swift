import SwiftUI

/// Presents a real tab container independently of API Lab's navigation stack.
struct TabAPIDemo: View {
    @State private var prefersSidebar = true
    @State private var showsSession = false

	var body: some View {
		Form {
			Section {
				Toggle(
					"Prefer sidebar where supported",
					isOn: $prefersSidebar
				)
				.accessibilityIdentifier(
					"tabsDemo.sidebarPreference"
				)

				Button("Open tab example") {
					showsSession = true
				}
				.accessibilityIdentifier(
					"tabsDemo.open"
				)
			} header: {
				Text("Presentation preference")
			} footer: {
				Text(
					"The system chooses the supported placement for the current window. " +
					"Open a fresh example after changing the preference."
				)
			}

			Section {
				Text(
					"Edit a note, switch destinations, and resize or rotate. " +
					"The note and selected destination belong to the same session."
				)

				Text(
					"On iPad, the adaptable bar uses its own default placement preference. " +
					"The newer defaultTabBarPlacement API supplies the preference on " +
					"supported iPhone contexts."
				)
			} header: {
				Text("Try it")
			}
		}
		.navigationTitle("Tabs and sidebar")
		.fullScreenCover(isPresented: $showsSession) {
			TabDemoSession(
				prefersSidebar: prefersSidebar
			)
		}
	}
}

private struct TabDemoSession: View {
    let prefersSidebar: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedTab = 0
    @State private var draft = "My adaptive note"

    var body: some View {
        tabs.tint(.indigo)
    }

    @ViewBuilder
    private var tabs: some View {
        if #available(iOS 18.0, *) {
            modernPresentation
        } else {
            TabView(selection: $selectedTab) {
                editor.tabItem { Label("Note", systemImage: "note.text") }.tag(0)
                summary.tabItem { Label("Summary", systemImage: "doc.text.magnifyingglass") }.tag(1)
            }
        }
    }

    @available(iOS 18.0, *)
    @ViewBuilder
    private var modernPresentation: some View {
        #if DUO_SDK
        if #available(iOS 27.0, *) {
            modernTabs
                .tabViewStyle(.sidebarAdaptable)
                .defaultAdaptableTabBarPlacement(prefersSidebar ? .sidebar : .tabBar)
                .defaultTabBarPlacement(prefersSidebar ? .sidebar : .tabBar)
        } else {
            adaptableTabs
        }
        #else
        adaptableTabs
        #endif
    }

    @available(iOS 18.0, *)
    private var adaptableTabs: some View {
        modernTabs
            .tabViewStyle(.sidebarAdaptable)
            .defaultAdaptableTabBarPlacement(prefersSidebar ? .sidebar : .tabBar)
    }

    @available(iOS 18.0, *)
    private var modernTabs: some View {
        TabView(selection: $selectedTab) {
            Tab("Note", systemImage: "note.text", value: 0) { editor }
            Tab("Summary", systemImage: "doc.text.magnifyingglass", value: 1) { summary }
        }
    }

    private var editor: some View {
        NavigationStack {
            Form {
                Section("Shared note") {
                    TextField("Note", text: $draft, axis: .vertical)
                        .accessibilityIdentifier("tabsDemo.draft")
                }
                Section("Current window") {
                    LabeledContent("Size class", value: sizeClass == .regular ? "Regular" : "Compact or unspecified")
                    Text("This reads the current environment. It does not infer a device from screen dimensions.")
                }
            }
            .navigationTitle("Note")
            .toolbar { closeButton }
        }
    }

    private var summary: some View {
        NavigationStack {
            Form {
                Section("Same note") {
                    Text(draft.isEmpty ? "No note yet" : draft)
                        .accessibilityIdentifier("tabsDemo.summary")
                }
            }
            .navigationTitle("Summary")
            .toolbar { closeButton }
        }
    }

    @ToolbarContentBuilder
    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close example") { dismiss() }
                .accessibilityIdentifier("tabsDemo.close")
        }
    }
}
