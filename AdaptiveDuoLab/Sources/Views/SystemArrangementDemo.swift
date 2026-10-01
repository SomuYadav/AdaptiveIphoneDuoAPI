import SwiftUI

/// The compile gate protects builds using an SDK that does not contain 27.1 symbols.
/// The runtime check separately protects devices running an earlier OS.
struct SystemArrangementDemo: View {
    let items: [WorkItem]
    let category: WorkCategory

    var body: some View {
        content
            .navigationTitle("System layout")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("apiLab.systemScreen")
    }

    @ViewBuilder
    private var content: some View {
        #if DUO_SDK
        if #available(iOS 27.1, *) {
            NativeArrangementContent(items: items, category: category)
        } else {
            fallback("This build includes the native demo. Run iOS 27.1 or later to use it.")
        }
        #else
        fallback("Native API source is included but disabled in this build. Build with the iOS 27.1 SDK and DUO_SDK=1 to enable it.")
        #endif
    }

    private func fallback(_ message: String) -> some View {
        List {
            Section("Native example availability") {
                Text(message).accessibilityIdentifier("apiLab.nativeStatus")
                Text("The current build keeps a normal continuous list with no artificial hinge gap.")
            }
            Section {
                APILabSummary(items: items, category: category)
            }
            Section("All filtered records") {
                ForEach(items) { item in
                    WorkItemCard(item: item, compact: false)
                }
            }
        }
    }
}

private struct APILabSummary: View {
    let items: [WorkItem]
    let category: WorkCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary").font(.title2.bold())
            LabeledContent("Category", value: category.rawValue)
            LabeledContent("Records", value: items.count.formatted())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Records")
                .accessibilityValue(items.count.formatted())
                .accessibilityIdentifier("apiLab.recordCount")
            LabeledContent("Complete", value: items.filter { $0.status == .complete }.count.formatted())
            LabeledContent("In progress", value: items.filter { $0.status == .inProgress }.count.formatted())
            Text("Primary contains every filtered record. This summary remains reachable from the toolbar when a secondary region is not displayed.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#if DUO_SDK
@available(iOS 27.1, *)
private struct NativeArrangementContent: View {
    let items: [WorkItem]
    let category: WorkCategory
    @State private var hinge: DeviceHinge?
    @State private var receivedHingeEvent = false

    var body: some View {
        GeometryReader { proxy in
            let divisions = proxy.reservedRegions(kind: .division, options: .includeInactive)
            let occlusions = proxy.reservedRegions(kind: .occlusion, options: .includeInactive)

            ArrangementView {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        Text("All \(items.count) records")
                            .font(.headline)
                            .accessibilityLabel("Records")
                            .accessibilityValue(items.count.formatted())
                            .accessibilityIdentifier("apiLab.recordCount")
                        ForEach(items) { item in
                            WorkItemCard(item: item, compact: false)
                        }
                    }
                    .padding()
                }
                .accessibilityIdentifier("apiLab.nativeRecords")
            } secondary: {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        APILabSummary(items: items, category: category)
                        SplitArrangementReadout()
                        Divider()
                        Text("System geometry").font(.headline)
                        LabeledContent("Active divisions", value: divisions.filter(\.isActive).count.formatted())
                        LabeledContent("Active occlusions", value: occlusions.filter(\.isActive).count.formatted())
                        Text(hingeDescription).font(.footnote).foregroundStyle(.secondary)
                        Text("ArrangementView chooses the relationship between these two regions. No angle thresholds or simulated-pose values drive this screen.")
                            .font(.footnote)
                    }
                    .padding()
                }
                .splitArrangementLayoutRatio(0.35)
            }
            .arrangementViewStyle(.split.axes([.horizontal, .vertical]))
        }
        .onHingeChange(isEnabled: true) { _, context in
            receivedHingeEvent = true
            hinge = context.hinge
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink {
                        ScrollView {
                            APILabSummary(items: items, category: category).padding()
                        }
                        .navigationTitle("Summary")
                    } label: {
                        Label("Summary", systemImage: "chart.bar")
                    }
                    NavigationLink {
                        NativeRegionInspector()
                    } label: {
                        Label("Inspect reserved regions", systemImage: "viewfinder")
                    }
                    NavigationLink {
                        NativeRegionAvoidanceDemo(items: items, category: category)
                    } label: {
                        Label("Move a custom control", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                    }
                    NavigationLink {
                        NativeOverlayArrangementDemo(items: items, category: category)
                    } label: {
                        Label("Overlay arrangement", systemImage: "square.2.layers.3d")
                    }
                } label: {
                    Label("System layout details", systemImage: "info.circle")
                }
                .accessibilityIdentifier("apiLab.nativeDetails")
            }
        }
    }

    private var hingeDescription: String {
        guard receivedHingeEvent else { return "Hinge: awaiting a system event." }
        guard let hinge else { return "Hinge: none reported by the latest event." }
        return "Hinge angle: \(hinge.angle.degrees.formatted(.number.precision(.fractionLength(0))))°. Read-only diagnostic."
    }
}

@available(iOS 27.1, *)
private struct SplitArrangementReadout: View {
    @Environment(\.splitArrangementAxis) private var axis

    var body: some View {
        LabeledContent("Split axis", value: axisDescription)
            .font(.footnote)
    }

    private var axisDescription: String {
        switch axis {
        case .horizontal: "Horizontal"
        case .vertical: "Vertical"
        case nil: "Not split"
        @unknown default: "System selected"
        }
    }
}

/// A foreground/background relationship, kept separate from split navigation.
/// Its controls read arrangement state, not a device name or a hinge threshold.
@available(iOS 27.1, *)
private struct NativeOverlayArrangementDemo: View {
    let items: [WorkItem]
    let category: WorkCategory
    @State private var completedOnly = false

    private var selectedItems: [WorkItem] {
        completedOnly ? items.filter { $0.status == .complete } : items
    }

    var body: some View {
        ArrangementView {
            OverlayReviewControls(completedOnly: $completedOnly, count: selectedItems.count)
                .overlayArrangementEdge(.trailing)
        } secondary: {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Review board").font(.largeTitle.bold())
                    Text(category.rawValue).font(.title2)
                    Text(selectedItems.count.formatted())
                        .font(.system(size: 76, weight: .semibold, design: .rounded))
                        .contentTransition(.numericText())
                    Text(completedOnly ? "Completed records" : "All filtered records")
                        .font(.title3)
                    Text("The controls are a foreground layer. When the system separates the layers, the controls expand in their own region.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                // A scrollable background can move clear of its overlay.
                .padding(.bottom, 240)
            }
            .background(.blue.opacity(0.08))
        }
        .arrangementViewStyle(.overlay.axes([.horizontal, .vertical]))
        .navigationTitle("Overlay arrangement")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    List(selectedItems) { item in
                        WorkItemCard(item: item, compact: false)
                    }
                    .navigationTitle("Review records")
                } label: {
                    Label("Review records", systemImage: "list.bullet")
                }
            }
        }
        .accessibilityIdentifier("apiLab.overlayScreen")
    }
}

@available(iOS 27.1, *)
private struct OverlayReviewControls: View {
    @Environment(\.overlayArrangementZIndex) private var zIndex
    @Binding var completedOnly: Bool
    let count: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if zIndex == 0 {
                    Text("Review controls").font(.title2.bold())
                    Text("These controls now have their own region.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Toggle("Completed only", isOn: $completedOnly)
                    .accessibilityIdentifier("apiLab.overlayCompletedOnly")
                Text("Showing \(count) records")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .frame(maxWidth: 360, maxHeight: zIndex == 0 ? .infinity : 220)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

@available(iOS 27.1, *)
private struct NativeRegionAvoidanceDemo: View {
    let items: [WorkItem]
    let category: WorkCategory
    // Keep the custom button hidden until its actual Dynamic Type size is known.
    @State private var controlSize = CGSize.zero
    @State private var showsRegions = true
    @State private var prefersBottom = false
    @State private var showsSummary = false

    var body: some View {
        GeometryReader { proxy in
            let regions = proxy.reservedRegions(kind: .division, options: .includeInactive)
                + proxy.reservedRegions(kind: .occlusion, options: .includeInactive)
            let bounds = CGRect(
                x: 12, y: 12,
                width: max(0, proxy.size.width - 24),
                height: max(0, proxy.size.height - 24)
            )
            let preferred = CGPoint(x: bounds.midX, y: prefersBottom ? bounds.maxY : bounds.midY)
            let placement = ReservedRegionPlacement.frame(
                for: controlSize,
                in: bounds,
                avoiding: regions.map { .init(frame: $0.frame, isActive: $0.isActive) },
                preferredCenter: preferred
            )

            ZStack(alignment: .topLeading) {
                Color.blue.opacity(0.06)
                if showsRegions {
                    ForEach(Array(regions.enumerated()), id: \.offset) { _, region in
                        Rectangle()
                            .fill(region.isActive ? Color.orange.opacity(0.28) : Color.gray.opacity(0.12))
                            .overlay {
                                Rectangle().strokeBorder(
                                    region.isActive ? Color.orange : Color.gray,
                                    style: StrokeStyle(lineWidth: 1, dash: region.isActive ? [] : [4, 4])
                                )
                            }
                            .frame(width: max(0, region.frame.width), height: max(0, region.frame.height))
                            .position(x: region.frame.midX, y: region.frame.midY)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
                Button {
                    showsSummary = true
                } label: {
                    Label("Review records", systemImage: "checklist")
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .fixedSize()
                .onGeometryChange(for: CGSize.self) { $0.size } action: { controlSize = $0 }
                .position(x: placement?.midX ?? bounds.midX, y: placement?.midY ?? bounds.midY)
                .opacity(placement == nil ? 0 : 1)
                .allowsHitTesting(placement != nil)
                .accessibilityHidden(placement == nil)
                .accessibilityIdentifier("apiLab.avoidingControl")
            }
            .clipped()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Review stays clear of active regions. If it cannot fit, use Review in the toolbar.")
                Text("Orange: active • Gray: inactive. Frames include interactive margins.")
                    .foregroundStyle(.secondary)
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial)
        }
        .navigationTitle("Custom control placement")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Review", systemImage: "checklist") { showsSummary = true }
                    .accessibilityIdentifier("apiLab.reviewFallback")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Toggle("Show reserved regions", isOn: $showsRegions)
                    Toggle("Prefer bottom center", isOn: $prefersBottom)
                    NavigationLink("Geometry details") { NativeRegionInspector() }
                } label: {
                    Label("Placement options", systemImage: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $showsSummary) {
            NavigationStack {
                List {
                    Section { APILabSummary(items: items, category: category) }
                    Section("Records") {
                        ForEach(items) { WorkItemCard(item: $0, compact: false) }
                    }
                }
                .navigationTitle("Review records")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showsSummary = false }
                    }
                }
            }
        }
        .accessibilityIdentifier("apiLab.regionAvoidanceScreen")
    }
}

@available(iOS 27.1, *)
private struct NativeRegionInspector: View {
    var body: some View {
        GeometryReader { proxy in
            let divisions = proxy.reservedRegions(kind: .division, options: .includeInactive)
            let occlusions = proxy.reservedRegions(kind: .occlusion, options: .includeInactive)
            List {
                Section {
                    Text("These values describe this inspector's local coordinate space. Inactive regions are included explicitly; only active regions should affect avoidance decisions.")
                    Text("Local size: \(number(proxy.size.width)) × \(number(proxy.size.height)) pt")
                }
                regionSection("Divisions", regions: divisions)
                regionSection("Occlusions", regions: occlusions)
            }
        }
        .navigationTitle("Reserved regions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func regionSection(_ title: String, regions: [ReservedRegion]) -> some View {
        Section(title) {
            if regions.isEmpty {
                Text("No intersecting regions. This is a valid result.")
            }
            ForEach(Array(regions.enumerated()), id: \.offset) { index, region in
                VStack(alignment: .leading, spacing: 6) {
                    Text("Region \(index + 1): \(region.isActive ? "active" : "inactive")").font(.headline)
                    Text("Origin: \(number(region.frame.minX)), \(number(region.frame.minY)) pt")
                    Text("Size: \(number(region.frame.width)) × \(number(region.frame.height)) pt")
                    Text("Margins: \(String(describing: region.margins))")
                    Text("Identifier: \(String(describing: region.id))")
                }
                .font(.footnote)
            }
        }
    }

    private func number(_ value: CGFloat) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }
}
#endif
