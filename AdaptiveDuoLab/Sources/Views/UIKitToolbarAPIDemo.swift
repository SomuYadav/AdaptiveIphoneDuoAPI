import Observation
import SwiftUI
import UIKit

/// Presents UIKit's own tab/navigation controllers rather than nesting them in
/// the API Lab's SwiftUI navigation stack.
/// Presents UIKit's own tab/navigation controllers rather than nesting them in
/// the API Lab's SwiftUI navigation stack.
@MainActor
struct UIKitToolbarAPIDemo: View {
	@State private var state = UIKitToolbarDemoState()
	@State private var prefersTabs = false
	@State private var horizontalReview = false
	@State private var showingSession = false

	var body: some View {
		List {
			Section {
				Text(
					"Review, Pin, Sort and Add use native UIKit bar buttons " +
					"and the system overflow menu. The Records and Actions " +
					"tabs share the same local state."
				)

				Toggle(
					"Prefer tabs when vertical space is limited",
					isOn: $prefersTabs
				)

				Toggle(
					"Keep Review in horizontal bars",
					isOn: $horizontalReview
				)

				Button(
					"Open UIKit toolbar session",
					systemImage: "play.rectangle"
				) {
					showingSession = true
				}
				.accessibilityIdentifier(
					"apiLab.uiKitToolbar.open"
				)
			} header: {
				Text("UIKit toolbar session")
			} footer: {
				Text(availabilityDescription)
			}

			Section {
				LabeledContent(
					"Reviews",
					value: state.reviewCount.formatted()
				)
				.accessibilityIdentifier(
					"apiLab.uiKitToolbar.launcherReviewCount"
				)

				LabeledContent(
					"Records",
					value: state.recordCount.formatted()
				)

				Text(state.lastAction)
					.foregroundStyle(.secondary)
			} header: {
				Text("Session state")
			}
		}
		.navigationTitle("UIKit toolbar APIs")
		.navigationBarTitleDisplayMode(.inline)
		.accessibilityIdentifier(
			"apiLab.uiKitToolbar.screen"
		)
		.fullScreenCover(isPresented: $showingSession) {
			UIKitToolbarControllerHost(
				state: state,
				prefersTabs: prefersTabs,
				horizontalReview: horizontalReview,
				close: {
					showingSession = false
				}
			)
			.ignoresSafeArea()
		}
	}

	private var availabilityDescription: String {
		#if DUO_SDK
		if #available(iOS 27.1, *) {
			return """
			Native priority, axis and compression preferences are active. \
			The system chooses whether a vertical bar is available.
			"""
		}
		#endif

		return """
		The system overflow menu and actions work in this build. \
		Priority, axis and vertical compression settings require the \
		iOS 27.1 SDK, DUO_SDK=1 and iOS 27.1 or later.
		"""
	}
}


@MainActor
@Observable
private final class UIKitToolbarDemoState {
    var recordCount = 30
    var reviewCount = 0
    var pinned = false
    var newestFirst = false
    var lastAction = "Session ready"
}

@MainActor
private struct UIKitToolbarControllerHost: UIViewControllerRepresentable {
    let state: UIKitToolbarDemoState
    let prefersTabs: Bool
    let horizontalReview: Bool
    let close: () -> Void

    func makeUIViewController(context: Context) -> UITabBarController {
        let records = UIKitToolbarRecordsController(
            state: state, showsActions: false, prefersTabs: prefersTabs,
            horizontalReview: horizontalReview, close: close
        )
        let actions = UIKitToolbarRecordsController(
            state: state, showsActions: true, prefersTabs: prefersTabs,
            horizontalReview: horizontalReview, close: close
        )
        let recordNavigation = UINavigationController(rootViewController: records)
        recordNavigation.tabBarItem = UITabBarItem(title: "Records", image: UIImage(systemName: "doc.on.doc"), tag: 0)
        let actionNavigation = UINavigationController(rootViewController: actions)
        actionNavigation.tabBarItem = UITabBarItem(title: "Actions", image: UIImage(systemName: "checklist"), tag: 1)
        let tabs = UITabBarController()
        tabs.setViewControllers([recordNavigation, actionNavigation], animated: false)
        return tabs
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        // Configuration is fixed for this presentation. UIKit keeps controller,
        // table scroll and tab state when the window changes size.
    }
}

@MainActor
private final class UIKitToolbarRecordsController: UITableViewController {
    private let state: UIKitToolbarDemoState
    private let showsActions: Bool
    private let prefersTabs: Bool
    private let horizontalReview: Bool
    private let close: () -> Void
    private var edgeDescription = "Native vertical edge unavailable in this build"
    private var pinItem: UIBarButtonItem?

    init(state: UIKitToolbarDemoState, showsActions: Bool, prefersTabs: Bool,
         horizontalReview: Bool, close: @escaping () -> Void) {
        self.state = state
        self.showsActions = showsActions
        self.prefersTabs = prefersTabs
        self.horizontalReview = horizontalReview
        self.close = close
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("Use the programmatic initializer") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = showsActions ? "UIKit actions" : "UIKit records"
        tableView.accessibilityIdentifier = "apiLab.uiKitToolbar.table"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
        let closeItem = barButton("Close", symbol: "xmark", action: #selector(closeSession))
        closeItem.accessibilityIdentifier = "apiLab.uiKitToolbar.close"
        navigationItem.leadingItemGroups = [
            UIBarButtonItemGroup(barButtonItems: [closeItem], representativeItem: nil)
        ]

        let review = barButton("Review", symbol: "checkmark.seal", action: #selector(reviewRecords))
        review.accessibilityIdentifier = "apiLab.uiKitToolbar.review"
        let pin = barButton("Pin collection", symbol: "pin", action: #selector(togglePin))
        pinItem = pin
        let sort = barButton("Reverse order", symbol: "arrow.up.arrow.down", action: #selector(reverseOrder))
        navigationItem.trailingItemGroups = [
            UIBarButtonItemGroup(barButtonItems: [review], representativeItem: nil),
            UIBarButtonItemGroup(barButtonItems: [sort], representativeItem: nil)
        ]
        // Pin belongs only to this group, never simultaneously to a trailing
        // group or rightBarButtonItems. One item needs no representative item.
        navigationItem.pinnedTrailingGroup = UIBarButtonItemGroup(
            barButtonItems: [pin], representativeItem: nil
        )

        // The navigation controller owns this toolbar, so it participates in
        // system layout and safe-area updates when its presentation changes.
        let add = barButton("Add demo record", symbol: "plus", action: #selector(addRecord))
        add.accessibilityIdentifier = "apiLab.uiKitToolbar.add"
        let summary = barButton("Session summary", symbol: "chart.bar", action: #selector(showSummary))
        summary.accessibilityIdentifier = "apiLab.uiKitToolbar.summary"
        toolbarItems = [
            add,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            summary
        ]

        // UIKit's property takes a deferred menu element, not bar button items.
        let overflowActions: [UIMenuElement] = [
            UIAction(title: "Add demo record", image: UIImage(systemName: "plus")) { [weak self] _ in
                self?.addRecord()
            },
            UIAction(title: "Session summary", image: UIImage(systemName: "chart.bar")) { [weak self] _ in
                self?.showSummary()
            }
        ]
        navigationItem.additionalOverflowItems = UIDeferredMenuElement.uncached { completion in
            completion(overflowActions)
        }

        #if DUO_SDK
        if #available(iOS 27.1, *) {
            review.visibilityPriority = .high
            pin.visibilityPriority = .standard
            sort.visibilityPriority = .low
            review.axisBehavior = horizontalReview ? .horizontalOnly : .verticalPreferred
            navigationItem.verticalBarCompressionBehavior = prefersTabs ? .prefersTabBar : .prefersBarItems
        }
        #endif
        refreshState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
        refreshState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        #if DUO_SDK
        if #available(iOS 27.1, *) {
            let newDescription: String
            switch traitCollection.verticalBarEdge {
            case .leading: newDescription = "Leading edge preferred"
            case .trailing: newDescription = "Trailing edge preferred"
            case .unspecified: newDescription = "No preferred vertical edge in this context"
            @unknown default: newDescription = "Unrecognized vertical edge"
            }
            if newDescription != edgeDescription {
                edgeDescription = newDescription
                tableView.reloadData()
            }
        }
        #endif
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 4 : (showsActions ? 4 : state.recordCount)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Live session" : (showsActions ? "Every action is reachable here" : "Records")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.accessibilityIdentifier = nil
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                content.text = "Reviews: \(state.reviewCount) · Records: \(state.recordCount)"
                cell.accessibilityIdentifier = "apiLab.uiKitToolbar.counts"
            case 1:
                content.text = state.lastAction
                cell.accessibilityIdentifier = "apiLab.uiKitToolbar.lastAction"
            case 2:
                content.text = edgeDescription
                content.secondaryText = "The preferred edge is not a bar visibility detector."
            default:
                content.text = "Review records"
                content.image = UIImage(systemName: "checkmark.seal")
                cell.selectionStyle = .default
                cell.accessibilityIdentifier = "apiLab.uiKitToolbar.reviewFallback"
            }
        } else if showsActions {
            content.text = ["Review records", "Toggle collection pin", "Reverse record order", "Add demo record"][indexPath.row]
            cell.selectionStyle = .default
        } else {
            let number = state.newestFirst ? state.recordCount - indexPath.row : indexPath.row + 1
            content.text = "Demo record \(number)"
            content.image = UIImage(systemName: "doc.text")
        }
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0, indexPath.row == 3 {
            reviewRecords()
        } else if indexPath.section == 1, showsActions {
            switch indexPath.row {
            case 0: reviewRecords()
            case 1: togglePin()
            case 2: reverseOrder()
            default: addRecord()
            }
        }
    }

    private func barButton(_ title: String, symbol: String, action: Selector) -> UIBarButtonItem {
        let item = UIBarButtonItem(image: UIImage(systemName: symbol), style: .plain, target: self, action: action)
        item.title = title
        item.accessibilityLabel = title
        return item
    }

    @objc private func closeSession() { close() }

    @objc private func reviewRecords() {
        state.reviewCount += 1
        state.lastAction = "Reviewed records · \(state.reviewCount)"
        refreshState()
    }

    @objc private func togglePin() {
        state.pinned.toggle()
        state.lastAction = state.pinned ? "Collection pinned" : "Collection unpinned"
        refreshState()
    }

    @objc private func reverseOrder() {
        state.newestFirst.toggle()
        state.lastAction = state.newestFirst ? "Newest records first" : "Oldest records first"
        refreshState()
    }

    @objc private func addRecord() {
        state.recordCount += 1
        state.lastAction = "Added demo record \(state.recordCount)"
        refreshState()
    }

    @objc private func showSummary() {
        let alert = UIAlertController(title: "Session summary", message: "\(state.recordCount) records · \(state.reviewCount) reviews\n\(edgeDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        present(alert, animated: true)
    }

    private func refreshState() {
        pinItem?.title = state.pinned ? "Unpin collection" : "Pin collection"
        pinItem?.accessibilityLabel = pinItem?.title
        pinItem?.image = UIImage(systemName: state.pinned ? "pin.fill" : "pin")
        tableView.reloadData()
    }
}
