import Observation
import SwiftUI

/// A real system-toolbar experiment in the existing demo app.
/// Preferences are chosen before presenting a session, so vertical-bar behavior
/// remains stable while navigating, scrolling, and resizing that session.
@MainActor
struct ToolbarAPIDemo: View {
    @State private var configuration = ToolbarDemoConfiguration()
    @State private var session = ToolbarDemoState()
    @State private var showingSession = false

    var body: some View {
        List {
            Section {
                Text("Compare system tabs, toolbar actions and overflow as available space changes. Review, Pin and Add all update this session's local records.")
            }

			Section {
				Picker(
					"Bar placement",
					selection: $configuration.vertical
				) {
					ForEach(ToolbarVerticalChoice.allCases) {
						Text($0.rawValue)
							.tag($0)
					}
				}

				Picker(
					"Compression priority",
					selection: $configuration.compression
				) {
					ForEach(ToolbarCompressionChoice.allCases) {
						Text($0.rawValue)
							.tag($0)
					}
				}

				Picker(
					"Review control axis",
					selection: $configuration.axis
				) {
					ForEach(ToolbarAxisChoice.allCases) {
						Text($0.rawValue)
							.tag($0)
					}
				}

				Picker(
					"Minimize navigation bar",
					selection: $configuration.minimization
				) {
					ForEach(ToolbarMinimizationChoice.allCases) {
						Text($0.rawValue)
							.tag($0)
					}
				}

				Toggle(
					"Give Review high visibility priority",
					isOn: $configuration.prioritizeReview
				)
			} header: {
				Text("Choose the next session")
			} footer: {
				Text(
					"System geometry decides whether vertical bars exist. " +
					"Horizontal-only Review stays reachable from the record list " +
					"and Actions tab. Bar placement is a stable preference for each session."
				)
			}


            availabilitySection

            Section("Session state") {
                ToolbarSessionSummary(session: session)
                Text("Closing and reopening the preview keeps these values. Resizing never recreates the record model.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Toolbar APIs")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("apiLab.toolbarScreen")
        .fullScreenCover(isPresented: $showingSession) {
            #if DUO_SDK
            if #available(iOS 27.1, *) {
                NativeToolbarSession(configuration: configuration, session: session)
            } else {
                BaselineToolbarSession(session: session)
            }
            #else
            BaselineToolbarSession(session: session)
            #endif
        }
    }

    @ViewBuilder
    private var availabilitySection: some View {
        Section {
            #if DUO_SDK
            if #available(iOS 27.1, *) {
                Button("Open native toolbar session", systemImage: "play.rectangle") {
                    showingSession = true
                }
                .accessibilityIdentifier("apiLab.toolbar.openNative")
            } else {
                baselineLaunch("Native toolbar source is included; iOS 27.1 or later is required. The baseline preview uses ordinary system toolbar items.")
            }
            #else
            baselineLaunch("Build with the iOS 27.1 SDK and DUO_SDK=1 to enable the native preferences above. The baseline preview uses ordinary system toolbar items.")
            #endif
        }
    }

    @ViewBuilder
    private func baselineLaunch(_ message: String) -> some View {
        Text(message).font(.footnote).foregroundStyle(.secondary)
        Button("Open baseline toolbar preview", systemImage: "play.rectangle") {
            showingSession = true
        }
        .accessibilityIdentifier("apiLab.toolbar.openBaseline")
    }
}

private enum ToolbarVerticalChoice: String, CaseIterable, Identifiable {
    case automatic = "System default"
    case horizontal = "Horizontal bars"
    var id: Self { self }
}

private enum ToolbarCompressionChoice: String, CaseIterable, Identifiable {
    case automatic = "Automatic"
    case tabs = "Prefer tabs"
    case actions = "Prefer toolbar actions"
    var id: Self { self }
}

private enum ToolbarAxisChoice: String, CaseIterable, Identifiable {
    case automatic = "Automatic"
    case horizontal = "Horizontal only"
    case vertical = "Prefer vertical"
    var id: Self { self }
}

private enum ToolbarMinimizationChoice: String, CaseIterable, Identifiable {
    case automatic = "Automatic"
    case never = "Never"
    case down = "On scroll down"
    case up = "On scroll up"
    var id: Self { self }
}

private struct ToolbarDemoConfiguration {
    var vertical: ToolbarVerticalChoice = .automatic
    var compression: ToolbarCompressionChoice = .actions
    var axis: ToolbarAxisChoice = .vertical
    var minimization: ToolbarMinimizationChoice = .down
    var prioritizeReview = true
}

@MainActor
@Observable
private final class ToolbarDemoState {
    var recordCount = 30
    var reviewCount = 0
    var isPinned = false
    var newestFirst = false
    var selectedTab = 0
    var activity: [String] = ["Session ready"]

    var records: [Int] {
        let values = Array(1...recordCount)
        return newestFirst ? Array(values.reversed()) : values
    }

    func review() {
        reviewCount += 1
        record("Reviewed the current records · \(reviewCount)")
    }

    func togglePin() {
        isPinned.toggle()
        record(isPinned ? "Pinned this collection" : "Unpinned this collection")
    }

    func toggleSort() {
        newestFirst.toggle()
        record(newestFirst ? "Newest records first" : "Oldest records first")
    }

    func addRecord() {
        recordCount += 1
        record("Added demo record \(recordCount)")
    }

    private func record(_ message: String) {
        activity.insert(message, at: 0)
        activity = Array(activity.prefix(30))
    }
}

@MainActor
private struct ToolbarSessionSummary: View {
    let session: ToolbarDemoState

    var body: some View {
        LabeledContent("Records", value: session.recordCount.formatted())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Records")
            .accessibilityValue(session.recordCount.formatted())
            .accessibilityIdentifier("apiLab.toolbar.recordCount")
        LabeledContent("Review actions", value: session.reviewCount.formatted())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Review actions")
            .accessibilityValue(session.reviewCount.formatted())
            .accessibilityIdentifier("apiLab.toolbar.reviewCount")
        LabeledContent("Collection", value: session.isPinned ? "Pinned" : "Not pinned")
        Text(session.activity.first ?? "Session ready")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("apiLab.toolbar.lastAction")
    }
}

@MainActor
private struct ToolbarRecordList: View {
    let session: ToolbarDemoState

    var body: some View {
        List {
            Section("Live session") {
                ToolbarSessionSummary(session: session)
                Button("Review records", systemImage: "checkmark.seal") { session.review() }
                    .accessibilityIdentifier("apiLab.toolbar.reviewFallback")
            }
            Section("Scroll to compare bar minimization") {
                ForEach(session.records, id: \.self) { number in
                    Label("Demo record \(number)", systemImage: "doc.text")
                        .padding(.vertical, 4)
                }
            }
        }
    }
}

@MainActor
private struct ToolbarActionList: View {
    let session: ToolbarDemoState

    var body: some View {
        List {
            Section("All actions remain reachable") {
                Button("Review records", systemImage: "checkmark.seal") { session.review() }
                Button(session.isPinned ? "Unpin collection" : "Pin collection", systemImage: "pin") {
                    session.togglePin()
                }
                Button("Reverse record order", systemImage: "arrow.up.arrow.down") { session.toggleSort() }
                Button("Add demo record", systemImage: "plus") { session.addRecord() }
            }
            Section("Session state") { ToolbarSessionSummary(session: session) }
        }
    }
}

@MainActor
private struct BaselineToolbarSession: View {
    let session: ToolbarDemoState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ToolbarRecordList(session: session)
                .navigationTitle("Baseline toolbar")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", systemImage: "xmark") { dismiss() }
                            .accessibilityIdentifier("apiLab.toolbar.close")
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Review", systemImage: "checkmark.seal") { session.review() }
                    }
                    ToolbarItem(placement: .secondaryAction) {
                        Menu("Collection actions", systemImage: "ellipsis") {
                            Button("Add demo record", systemImage: "plus") { session.addRecord() }
                            Button("Reverse record order", systemImage: "arrow.up.arrow.down") { session.toggleSort() }
                        }
                    }
                }
        }
    }
}

#if DUO_SDK
@available(iOS 27.1, *)
@MainActor
private struct NativeToolbarSession: View {
    let configuration: ToolbarDemoConfiguration
    @Bindable var session: ToolbarDemoState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(selection: $session.selectedTab) {
            Tab("Records", systemImage: "doc.on.doc", value: 0) {
                NavigationStack {
                    NativeToolbarRecords(configuration: configuration, session: session, close: { dismiss() })
                }
            }
            Tab("Activity", systemImage: "clock", value: 1) {
                NavigationStack {
                    List(Array(session.activity.enumerated()), id: \.offset) { _, message in
                        Text(message)
                    }
                    .navigationTitle("Activity")
                    .toolbar { closeButton }
                }
            }
            Tab("Actions", systemImage: "checklist", value: 2) {
                NavigationStack {
                    ToolbarActionList(session: session)
                        .navigationTitle("All actions")
                        .toolbar { closeButton }
                }
            }
        }
        .toolbarVerticalBehavior(configuration.vertical == .horizontal ? .disabled : .automatic)
        .accessibilityIdentifier("apiLab.toolbar.nativeSession")
    }

    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close", systemImage: "xmark") { dismiss() }
                .accessibilityIdentifier("apiLab.toolbar.close")
        }
    }
}

@available(iOS 27.1, *)
@MainActor
private struct NativeToolbarRecords: View {
    let configuration: ToolbarDemoConfiguration
    let session: ToolbarDemoState
    let close: () -> Void
    @Environment(\.toolbarVerticalEdge) private var preferredVerticalEdge
    @State private var showingSummary = false

    var body: some View {
        ToolbarRecordList(session: session)
            .navigationTitle("Toolbar records")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", action: close)
                        .accessibilityIdentifier("apiLab.toolbar.close")
                }
                ToolbarItem(placement: .primaryAction) {
                    NativeReviewControl(reviewCount: session.reviewCount, action: session.review)
                }
                .visibilityPriority(configuration.prioritizeReview ? .high : .automatic)
                .axisBehavior(axisBehavior)

                ToolbarItem(placement: .topBarPinnedTrailing) {
                    Button(session.isPinned ? "Unpin" : "Pin", systemImage: session.isPinned ? "pin.fill" : "pin") {
                        session.togglePin()
                    }
                    .accessibilityIdentifier("apiLab.toolbar.pin")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Reverse order", systemImage: "arrow.up.arrow.down") { session.toggleSort() }
                }
                .visibilityPriority(.low)

                ToolbarOverflowMenu {
                    Button("Add demo record", systemImage: "plus") { session.addRecord() }
                        .accessibilityIdentifier("apiLab.toolbar.overflowAdd")
                    Button("Session summary", systemImage: "chart.bar") { showingSummary = true }
                    Button("Review records", systemImage: "checkmark.seal") { session.review() }
                }
            }
            .toolbarVerticalCompressionBehavior(compressionBehavior)
            .toolbarMinimizationBehavior(minimizationBehavior, for: .navigationBar)
            .sheet(isPresented: $showingSummary) {
                NavigationStack {
                    List {
                        Section("Live values") { ToolbarSessionSummary(session: session) }
                        Section("Preferred vertical context") {
                            Text(edgeDescription)
                            Text("The edge is a system preference, not proof that a bar is currently visible. No custom side rail is drawn.")
                        }
                    }
                    .navigationTitle("Session summary")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingSummary = false }
                        }
                    }
                }
            }
    }

    private var axisBehavior: ToolbarItemAxisBehavior {
        switch configuration.axis {
        case .automatic: .automatic
        case .horizontal: .horizontalOnly
        case .vertical: .verticalPreferred
        }
    }

    private var compressionBehavior: ToolbarVerticalCompressionBehavior {
        switch configuration.compression {
        case .automatic: .automatic
        case .tabs: .prefersTabBar
        case .actions: .prefersToolbarItems
        }
    }

    private var minimizationBehavior: ToolbarMinimizationBehavior {
        switch configuration.minimization {
        case .automatic: .automatic
        case .never: .never
        case .down: .onScrollDown
        case .up: .onScrollUp
        }
    }

    private var edgeDescription: String {
        guard let preferredVerticalEdge else { return "None in this context" }
        return preferredVerticalEdge == .leading ? "Leading edge preferred" : "Trailing edge preferred"
    }
}

@available(iOS 27.1, *)
@MainActor
private struct NativeReviewControl: View {
    let reviewCount: Int
    let action: () -> Void
    @Environment(\.toolbarVerticalEdge) private var preferredVerticalEdge

    var body: some View {
        Button(action: action) {
            if preferredVerticalEdge == nil {
                Label("Review", systemImage: "checkmark.seal")
            } else {
                Label("Review", systemImage: "checkmark.seal")
                    .labelStyle(.iconOnly)
            }
        }
        .accessibilityLabel("Review records")
        .accessibilityValue("\(reviewCount) reviews")
        .accessibilityIdentifier("apiLab.toolbar.review")
    }
}
#endif
