import SwiftUI

/// Presented independently of Workspace's NavigationSplitView.
struct APILabView: View {
	let items: [WorkItem]
	let category: WorkCategory

	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			List {
				Section {
					ForEach(APIDemoRoute.allCases) { route in
						NavigationLink {
							APIDemoDestination(
								route: route,
								items: items,
								category: category
							)
						} label: {
							Label(
								route.title,
								systemImage: route.symbol
							)
						}
						.accessibilityIdentifier(
							route.accessibilityIdentifier
						)
					}
				} header: {
					Text("Interactive examples")
				} footer: {
					Text(
						"System layout uses your selected category's records. " +
						"Other examples keep their own editable demo state. " +
						"The system determines supported placements and hardware capabilities."
					)
				}

				Section {
					Text(
						"Native navigation and bars adapt their own presentation. " +
						"Your app supplies content relationships, fallback layouts and state."
					)

					Text(
						"Apple's App Resizability skill assists source changes in Xcode; " +
						"it is not a runtime layout API."
					)
				} header: {
					Text("Automatic adaptation")
				}

				Section {
					ForEach(APICatalogEntry.entries) { entry in
						NavigationLink {
							APICatalogDetail(
								entry: entry,
								items: items,
								category: category
							)
						} label: {
							VStack(
								alignment: .leading,
								spacing: 5
							) {
								Text(entry.name)
									.font(.headline)

								Text(entry.version)
									.font(.caption)
									.foregroundStyle(.secondary)

								Text(entry.status)
									.font(.subheadline)
							}
							.padding(.vertical, 3)
						}
						.accessibilityIdentifier(
							"apiLab.entry.\(entry.id)"
						)
					}
				} header: {
					Text("API inventory")
				}
			}
			.navigationTitle("API Lab")
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") {
						dismiss()
					}
					.accessibilityIdentifier("apiLab.done")
				}
			}
		}
		.accessibilityIdentifier("apiLab.screen")
	}
}


private struct APICatalogDetail: View {
	let entry: APICatalogEntry
	let items: [WorkItem]
	let category: WorkCategory

	var body: some View {
		List {
			if let route = entry.demoRoute {
				Section {
					NavigationLink {
						APIDemoDestination(
							route: route,
							items: items,
							category: category
						)
					} label: {
						Label(
							"Try this API",
							systemImage: "play.circle"
						)
					}
				}
			}

			Section {
				Text(entry.version)
			} header: {
				Text("Availability")
			}

			Section {
				Text(entry.purpose)
			} header: {
				Text("What it does")
			}

			Section {
				Text(entry.status)

				Text(entry.source)
					.font(.footnote)
					.foregroundStyle(.secondary)
			} header: {
				Text("In this project")
			}

			Section {
				Text(entry.ordinaryPhone)
			} header: {
				Text("Other supported iPhones")
			}

			Section {
				if let url = entry.documentationURL {
					Link(
						"Apple documentation",
						destination: url
					)
				}
			} footer: {
				Text(
					"Some examples require the native build and a supported OS. " +
					"Hardware features remain optional."
				)
			}
		}
		.navigationTitle(entry.name)
		.navigationBarTitleDisplayMode(.inline)
		.accessibilityIdentifier(
			"apiLab.detail.\(entry.id)"
		)
	}
}


private struct APIDemoDestination: View {
	let route: APIDemoRoute
	let items: [WorkItem]
	let category: WorkCategory

	@ViewBuilder
	var body: some View {
		switch route {
		case .system:
			SystemArrangementDemo(
				items: items,
				category: category
			)

		case .toolbar:
			ToolbarAPIDemo()

		case .tabs:
			TabAPIDemo()

		case .layout:
			LayoutAPIDemo()

		case .uikit:
			UIKitAPIDemo()

		case .uikitToolbar:
			UIKitToolbarAPIDemo()

		case .presentations:
			PresentationAPIDemo()

		case .camera:
			CameraAPIDemo()
		}
	}
}
