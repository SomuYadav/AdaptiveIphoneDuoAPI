import SwiftUI

/// Uses local view geometry. A window resize changes layout, not the view model.
struct LayoutAPIDemo: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var preferStack = false
    @State private var title = "Ship the adaptive layout"
    @State private var completed = 2

    var body: some View {
        GeometryReader { geometry in
            let useStack = preferStack || geometry.size.width < 640 || dynamicTypeSize.isAccessibilitySize
            let layout = useStack
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 16))
                : AnyLayout(HStackLayout(alignment: .top, spacing: 16))

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reflow without losing state").font(.title2.bold())
                        Text("Edit the task, then resize the window or switch layouts. The same fields and values stay in place.")
                            .foregroundStyle(.secondary)
                        Toggle("Prefer a vertical layout", isOn: $preferStack)
                            .accessibilityIdentifier("apiLab.layout.preferStack")
                        Text(useStack ? "Vertical layout" : "Horizontal layout")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("apiLab.layout.mode")
                    }

                    // Keep both children inside one AnyLayout call. Replacing them
                    // with separate if/else subtrees would change their identity.
                    layout {
                        editor
                        summary
                    }
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: useStack)

                    Divider()
                    if #available(iOS 26.0, *) {
                        ConcentricCornerDemo()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Concentric corners").font(.title2.bold())
                            Text("Run iOS 26 or later to compare ConcentricRectangle with fixed-radius corners. Reflow above works on iOS 17 and later.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 1000, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Reflow and corners")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("apiLab.layout.screen")
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task editor").font(.headline)
            TextField("Task title", text: $title, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("apiLab.layout.title")
            Stepper("Completed: \(completed) of 5", value: $completed, in: 0...5)
                .accessibilityIdentifier("apiLab.layout.completed")
            ProgressView(value: Double(completed), total: 5)
                .accessibilityLabel("Task progress")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 18))
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live summary").font(.headline)
            Text(title.isEmpty ? "Untitled task" : title)
                .font(.title3)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(5 - completed) steps remaining")
                .foregroundStyle(.secondary)
            Label("State is preserved while the layout changes", systemImage: "checkmark.circle")
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 18))
    }
}

@available(iOS 26.0, *)
private struct ConcentricCornerDemo: View {
    @State private var inset = 12.0
    @State private var useConcentric = true

    private let outerShape = RoundedRectangle(cornerRadius: 40)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Corners that follow their container").font(.title2.bold())
            Toggle("Use concentric corners", isOn: $useConcentric)
                .accessibilityIdentifier("apiLab.corners.concentric")
            VStack(alignment: .leading, spacing: 8) {
                Text("Inset: \(inset.formatted(.number.precision(.fractionLength(0)))) pt")
                Slider(value: $inset, in: 8...32, step: 1)
                    .accessibilityLabel("Card inset")
                    .accessibilityIdentifier("apiLab.corners.inset")
            }

            VStack(alignment: .leading, spacing: 12) {
                Label("Adaptive card", systemImage: "rectangle.inset.filled")
                    .font(.headline)
                Text("Change the inset to compare the inner and outer curves.")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if useConcentric {
                    ConcentricRectangle().fill(.background)
                } else {
                    RoundedRectangle(cornerRadius: 24).fill(.background)
                }
            }
            .padding(CGFloat(inset))
            .containerShape(outerShape)
            .background(outerShape.fill(.indigo.opacity(0.22)))
            .accessibilityIdentifier("apiLab.corners.preview")

            Text(useConcentric
                 ? "ConcentricRectangle resolves each inner corner from this container's shape and inset."
                 : "The inner radius stays at 24 pt, regardless of its distance from the outer edge.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
