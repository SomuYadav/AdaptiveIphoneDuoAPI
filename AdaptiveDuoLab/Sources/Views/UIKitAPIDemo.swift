import SwiftUI
import UIKit

struct UIKitAPIDemo: View {
    var body: some View {
        UIKitLayoutControllerHost()
            .navigationTitle("UIKit layout")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("apiLab.uikit.screen")
    }
}

private struct UIKitLayoutControllerHost: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIKitLayoutController {
        UIKitLayoutController()
    }

    func updateUIViewController(_ uiViewController: UIKitLayoutController, context: Context) {}
}

/// The background fills bounds; all interactive content uses this view's
/// safe-area guide. No global screen reference or mirrored inset is needed.
private final class UIKitLayoutController: UIViewController {
    var showsNavigationDemoButton = true
    private let geometryLabel = UIKitLayoutController.makeLabel(style: .footnote)
    private let insetLabel = UIKitLayoutController.makeLabel(style: .body)
    private let outerCard = UIView()
    private let innerCard = UIView()
    private let insetSlider = UISlider()
    private let concentricSwitch = UISwitch()
    private var innerConstraints: [NSLayoutConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // Safe-area constraints already provide the insets; don't apply them twice.
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 24, trailing: 16)
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        stack.addArrangedSubview(Self.makeLabel("Independent safe-area edges", style: .title2))
        stack.addArrangedSubview(Self.makeLabel("Apply an extra test inset to either side. Auto Layout follows each edge independently while the background still fills the view."))
        let edgeControl = UISegmentedControl(items: ["None", "Left +44", "Right +44"])
        edgeControl.selectedSegmentIndex = 0
        edgeControl.accessibilityLabel = "Additional safe-area inset"
        edgeControl.accessibilityIdentifier = "apiLab.uikit.safeAreaControl"
        edgeControl.addTarget(self, action: #selector(changeSafeArea(_:)), for: .valueChanged)
        stack.addArrangedSubview(edgeControl)
        geometryLabel.textColor = .secondaryLabel
        geometryLabel.accessibilityIdentifier = "apiLab.uikit.geometry"
        stack.addArrangedSubview(geometryLabel)

        stack.addArrangedSubview(Self.makeLabel("Concentric UIKit corners", style: .title2))
        let switchLabel = Self.makeLabel("Use concentric corners")
        let switchRow = UIStackView(arrangedSubviews: [switchLabel, concentricSwitch])
        switchRow.spacing = 12
        switchRow.alignment = .center
        concentricSwitch.isOn = true
        concentricSwitch.accessibilityLabel = "Use concentric corners"
        concentricSwitch.accessibilityIdentifier = "apiLab.uikit.concentric"
        concentricSwitch.setContentHuggingPriority(.required, for: .horizontal)
        concentricSwitch.addTarget(self, action: #selector(changeCorners), for: .valueChanged)
        stack.addArrangedSubview(switchRow)

        insetSlider.minimumValue = 8
        insetSlider.maximumValue = 32
        insetSlider.value = 12
        insetSlider.accessibilityLabel = "UIKit card inset"
        insetSlider.accessibilityIdentifier = "apiLab.uikit.inset"
        insetSlider.addTarget(self, action: #selector(changeInset), for: .valueChanged)
        stack.addArrangedSubview(insetLabel)
        stack.addArrangedSubview(insetSlider)
        configureCard()
        stack.addArrangedSubview(outerCard)

        if #available(iOS 26.0, *) {
            stack.addArrangedSubview(Self.makeLabel("UICornerConfiguration resolves the inner corners against their containing view. Drag the inset slider or compare fixed corners.", style: .footnote))
        } else {
            concentricSwitch.isEnabled = false
            concentricSwitch.isOn = false
            stack.addArrangedSubview(Self.makeLabel("Concentric corners require iOS 26. This device uses fixed rounded corners; safe areas and split navigation still work.", style: .footnote))
        }

        if showsNavigationDemoButton {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.title = "Open UIKit tabs and split navigation"
            let splitButton = UIButton(configuration: buttonConfiguration)
            splitButton.accessibilityIdentifier = "apiLab.uikit.openSplit"
            splitButton.addTarget(self, action: #selector(openSplitNavigation), for: .touchUpInside)
            stack.addArrangedSubview(splitButton)
            stack.addArrangedSubview(Self.makeLabel("Switch tabs, select a topic and edit its draft, then change the window width. The system chooses the navigation presentation.", style: .footnote))
        }
        changeInset()
        changeCorners()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGeometryLabel()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateGeometryLabel()
    }

    private func configureCard() {
        outerCard.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.22)
        innerCard.backgroundColor = .secondarySystemGroupedBackground
        innerCard.translatesAutoresizingMaskIntoConstraints = false
        outerCard.addSubview(innerCard)
        innerConstraints = [
            innerCard.topAnchor.constraint(equalTo: outerCard.topAnchor, constant: 12),
            innerCard.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor, constant: 12),
            outerCard.trailingAnchor.constraint(equalTo: innerCard.trailingAnchor, constant: 12),
            outerCard.bottomAnchor.constraint(equalTo: innerCard.bottomAnchor, constant: 12)
        ]
        NSLayoutConstraint.activate(innerConstraints)

        let text = Self.makeLabel("Adaptive card\nChange the inset to compare the inner and outer curves.")
        text.translatesAutoresizingMaskIntoConstraints = false
        innerCard.addSubview(text)
        NSLayoutConstraint.activate([
            text.topAnchor.constraint(equalTo: innerCard.topAnchor, constant: 24),
            text.leadingAnchor.constraint(equalTo: innerCard.leadingAnchor, constant: 24),
            text.trailingAnchor.constraint(equalTo: innerCard.trailingAnchor, constant: -24),
            text.bottomAnchor.constraint(equalTo: innerCard.bottomAnchor, constant: -24)
        ])
    }

    @objc private func changeSafeArea(_ sender: UISegmentedControl) {
        additionalSafeAreaInsets = UIEdgeInsets(
            top: 0,
            left: sender.selectedSegmentIndex == 1 ? 44 : 0,
            bottom: 0,
            right: sender.selectedSegmentIndex == 2 ? 44 : 0
        )
    }

    @objc private func changeInset() {
        let inset = CGFloat(insetSlider.value.rounded())
        innerConstraints.forEach { $0.constant = inset }
        insetLabel.text = "Card inset: \(Int(inset)) pt"
        insetSlider.accessibilityValue = "\(Int(inset)) points"
    }

    @objc private func changeCorners() {
        if #available(iOS 26.0, *) {
            outerCard.cornerConfiguration = .corners(radius: .fixed(40))
            innerCard.cornerConfiguration = .corners(
                radius: concentricSwitch.isOn ? .containerConcentric() : .fixed(24)
            )
        } else {
            outerCard.layer.cornerRadius = 40
            innerCard.layer.cornerRadius = 24
        }
    }

    private func updateGeometryLabel() {
        let insets = view.safeAreaInsets
        let text = String(
            format: "Local view: %.0f × %.0f pt · scale %.1f×\nSafe area: top %.0f · left %.0f · bottom %.0f · right %.0f",
            view.bounds.width, view.bounds.height,
            view.traitCollection.displayScale,
            insets.top, insets.left, insets.bottom, insets.right
        )
        if geometryLabel.text != text { geometryLabel.text = text }
    }

    @objc private func openSplitNavigation() {
        let tabs = UIKitNavigationDemoController()
        tabs.modalPresentationStyle = .fullScreen
        present(tabs, animated: true)
    }

    fileprivate static func makeLabel(_ text: String = "", style: UIFont.TextStyle = .body) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }
}

private final class UIKitNavigationDemoController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UIKitLayoutController()
        layout.showsNavigationDemoButton = false
        layout.title = "Layout"
        layout.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(closeDemo)
        )
        let layoutNavigation = UINavigationController(rootViewController: layout)
        let split = UIKitSplitDemoController(style: .doubleColumn)
        split.onClose = { [weak self] in self?.dismiss(animated: true) }

        if #available(iOS 18.0, *) {
            tabs = [
                UITab(title: "Layout", image: UIImage(systemName: "rectangle.inset.filled"), identifier: "layout") { _ in
                    layoutNavigation
                },
                UITab(title: "Topics", image: UIImage(systemName: "rectangle.split.2x1"), identifier: "topics") { _ in
                    split
                }
            ]
            mode = .tabSidebar
            #if DUO_SDK
            if #available(iOS 27.1, *) {
                // Sidebar preference is iOS 27 API, compiled only with the
                // optional 27.1 SDK profile used by the rest of the Duo lab.
                sidebar.preferredPlacement = .sidebar
            }
            #endif
        } else {
            layoutNavigation.tabBarItem = UITabBarItem(title: "Layout", image: UIImage(systemName: "rectangle.inset.filled"), tag: 0)
            split.tabBarItem = UITabBarItem(title: "Topics", image: UIImage(systemName: "rectangle.split.2x1"), tag: 1)
            viewControllers = [layoutNavigation, split]
        }
        view.accessibilityIdentifier = "apiLab.uikit.tabs"
    }

    @objc private func closeDemo() {
        dismiss(animated: true)
    }
}

/// Hosted directly as tab content, never pushed into a navigation stack.
private final class UIKitSplitDemoController: UISplitViewController {
    var onClose: (() -> Void)?
    private let list = UIKitTopicListController(style: .insetGrouped)
    private let detail = UIKitTopicDetailController()

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .oneBesideSecondary
        setViewController(UINavigationController(rootViewController: list), for: .primary)
        setViewController(UINavigationController(rootViewController: detail), for: .secondary)
        list.onSelect = { [weak self] title in
            guard let self else { return }
            self.detail.setTopic(title)
            self.show(.secondary)
        }
        for child in [list as UIViewController, detail] {
            child.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done, target: self, action: #selector(closeDemo)
            )
        }
    }

    @objc private func closeDemo() {
        if let onClose { onClose() } else { dismiss(animated: true) }
    }
}

private final class UIKitTopicListController: UITableViewController {
    var onSelect: ((String) -> Void)?
    private let topics = ["Navigation", "Safe areas", "Concentric corners"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Topics"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "topic")
        tableView.accessibilityIdentifier = "apiLab.uikit.topics"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        topics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topic", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = topics[indexPath.row]
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(topics[indexPath.row])
    }
}

private final class UIKitTopicDetailController: UIViewController, UITextViewDelegate {
    private var topic = "Navigation"
    private var drafts: [String: String] = [:]
    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = topic
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.delegate = self
        textView.text = drafts[topic] ?? "Draft notes for \(topic). Edit this text, then resize the window."
        textView.accessibilityLabel = "Topic notes"
        textView.accessibilityIdentifier = "apiLab.uikit.draft"
        textView.contentInsetAdjustmentBehavior = .never
        view.addSubview(textView)
        // Both horizontal edges are local and independent. The keyboard guide
        // keeps the editor usable while typing on compact windows.
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -12)
        ])
    }

    func setTopic(_ newTopic: String) {
        if isViewLoaded { drafts[topic] = textView.text }
        topic = newTopic
        title = newTopic
        if isViewLoaded {
            textView.text = drafts[newTopic] ?? "Draft notes for \(newTopic). Edit this text, then resize the window."
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        drafts[topic] = textView.text
    }
}
