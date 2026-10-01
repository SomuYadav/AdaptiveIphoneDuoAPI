import SwiftUI

struct PresentationAPIDemo: View {
    @State private var showsSheet = false
    @State private var showsPopover = false
    @State private var showsAlert = false
    @State private var draft = "Review adaptive layout"
    @State private var lastAction = "No action yet"

    var body: some View {
        Form {
            Section("Presentations") {
                Button("Edit in a sheet") { showsSheet = true }
                    .accessibilityIdentifier("presentations.sheet")
                Button("Show popover") { showsPopover = true }
                    .popover(isPresented: $showsPopover) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Context for this action").font(.headline)
                            Text("The system adapts the presentation to available space.")
                            Button("Dismiss") { showsPopover = false }
                        }
                        .padding()
                    }
                Button("Show alert") { showsAlert = true }
                Menu("Actions", systemImage: "ellipsis.circle") {
                    Button("Mark reviewed", systemImage: "checkmark") { lastAction = "Reviewed" }
                    Button("Pin note", systemImage: "pin") { lastAction = "Pinned" }
                }
            }
            Section("Shared state") {
                Text(draft).accessibilityIdentifier("presentations.draftSummary")
                LabeledContent("Last action", value: lastAction)
            }
            Section("Try it") {
                Text("Keep the sheet open while resizing, rotating, or changing the supported device configuration. Your draft remains in the parent view.")
            }
        }
        .navigationTitle("Presentations")
        .sheet(isPresented: $showsSheet) {
            NavigationStack {
                Form {
                    TextField("Note", text: $draft, axis: .vertical)
                        .accessibilityIdentifier("presentations.draft")
                }
                .navigationTitle("Edit note")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showsSheet = false }
                            .accessibilityIdentifier("presentations.done")
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert("Mark this note reviewed?", isPresented: $showsAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Mark reviewed") { lastAction = "Reviewed" }
        } message: {
            Text("This changes only the local example state.")
        }
    }
}
