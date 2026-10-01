import XCTest

@MainActor
final class AdaptiveDuoLabUITests: XCTestCase {
    func testEditableLayoutStateSurvivesRotation() {
        let app = openExample("layout")
        let editor = app.descendants(matching: .any)["apiLab.layout.title"]
        XCTAssertTrue(editor.waitForExistence(timeout: 3))
        editor.tap()
        editor.typeText(" preserved")
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value CONTAINS %@", "preserved"),
            object: editor
        )
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 4), .completed)
    }

    func testToolbarActionsSurviveClosingAndReopeningSession() {
        let app = openExample("toolbar")
        let nativeLaunch = app.buttons["apiLab.toolbar.openNative"]
        let baselineLaunch = app.buttons["apiLab.toolbar.openBaseline"]
        scrollToEither(nativeLaunch, baselineLaunch, in: app)
        (nativeLaunch.exists ? nativeLaunch : baselineLaunch).tap()
        let review = app.buttons["apiLab.toolbar.reviewFallback"]
        XCTAssertTrue(review.waitForExistence(timeout: 4))
        review.tap()
        assertValue("1", for: "apiLab.toolbar.reviewCount", in: app)
        app.buttons["apiLab.toolbar.close"].tap()
        scrollToEither(nativeLaunch, baselineLaunch, in: app)
        (nativeLaunch.exists ? nativeLaunch : baselineLaunch).tap()
        assertValue("1", for: "apiLab.toolbar.reviewCount", in: app)
        app.buttons["apiLab.toolbar.close"].tap()
    }

    func testCameraExampleStartsWithCaptureOff() {
        let app = openExample("camera")
        let start = app.buttons["apiLab.cameraStart"]
        for _ in 0..<6 where !start.isHittable { app.swipeUp() }
        XCTAssertTrue(start.exists)
        XCTAssertFalse(app.buttons["apiLab.cameraStop"].exists)
    }

    func testAPILabUsesSharedRecordsAndCanDismiss() {
        let app = launch(tab: "Settings")
        select("Engineering", from: "settings.category", in: app)
        let openLab = app.buttons["settings.apiLab"]
        XCTAssertTrue(openLab.waitForExistence(timeout: 5))
        openLab.tap()
        XCTAssertTrue(app.navigationBars["API Lab"].waitForExistence(timeout: 3))

        let systemDemo = app.buttons["apiLab.systemDemo"]
        XCTAssertTrue(systemDemo.waitForExistence(timeout: 3))
        systemDemo.tap()
        XCTAssertTrue(app.navigationBars["System layout"].waitForExistence(timeout: 3))
        // Baseline builds show preparation text; native builds show the records.
        // Either route preserves access to every record from the selected category.
        XCTAssertTrue(
            app.descendants(matching: .any)["apiLab.nativeStatus"].exists ||
            app.descendants(matching: .any)["apiLab.nativeRecords"].exists
        )
        assertValue("3", for: "apiLab.recordCount", in: app)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["API Lab"].waitForExistence(timeout: 3))
        app.buttons["apiLab.done"].tap()
        assertValue("8", for: "settings.recordCount", in: app)
        assertValue("Engineering", for: "settings.category", in: app)
        assertValue("3", for: "settings.filteredCount", in: app)
    }

    func testListGridAndAuditJourney() {
        let app = launch(tab: "Workspace")
        showWorkspaceDetail(in: app)

        if !app.buttons["layout.grid"].isHittable {
            app.buttons["layout.menu"].tap()
        }
        app.buttons["layout.grid"].tap()
        XCTAssertTrue(
            app.descendants(matching: .any)["layout.decision"]
                .waitForExistence(timeout: 3)
        )

        app.buttons["audit.open"].tap()
        XCTAssertTrue(app.navigationBars["Layout Review"].waitForExistence(timeout: 3))
        app.buttons["audit.done"].tap()
        XCTAssertTrue(app.buttons["audit.open"].waitForExistence(timeout: 3))
    }

    func testSettingsStaySharedAcrossTabsAndRotation() {
        let app = launch(tab: "Settings")
        assertValue("8", for: "settings.recordCount", in: app)

        select("Engineering", from: "settings.category", in: app)
        select("Grid", from: "settings.presentation", in: app)
        select("Book Fold", from: "settings.pose", in: app)
        assertValue("3", for: "settings.filteredCount", in: app)

        openTab("Review", in: app)
        assertReviewState(in: app)

        openTab("Workspace", in: app)
        showWorkspaceDetail(in: app, category: "engineering")
        XCTAssertTrue(app.descendants(matching: .any)["layout.decision"].exists)

        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        openTab("Review", in: app)
        assertReviewState(in: app)

        openTab("Settings", in: app)
        assertValue("Engineering", for: "settings.category", in: app)
        assertValue("Grid", for: "settings.presentation", in: app)
        assertValue("Book Fold", for: "settings.pose", in: app)
        assertValue("3", for: "settings.filteredCount", in: app)
    }

    func testReviewLaunchUsesExistingSeededData() {
        let app = launch(tab: "Review")
        assertValue("All", for: "review.category", in: app)
        assertValue("8", for: "review.recordCount", in: app)
        assertValue("Current Window", for: "review.pose", in: app)
        assertValue("Automatic", for: "review.presentation", in: app)
        XCTAssertFalse(app.buttons["audit.done"].exists)

        openTab("Settings", in: app)
        assertValue("8", for: "settings.recordCount", in: app)
        assertValue("8", for: "settings.filteredCount", in: app)
    }

    private func launch(tab: String) -> XCUIApplication {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-reset-data", "-demo-tab", tab]
        app.launch()
        return app
    }

    private func openExample(_ route: String) -> XCUIApplication {
        let app = launch(tab: "Settings")
        let openLab = app.buttons["settings.apiLab"]
        XCTAssertTrue(openLab.waitForExistence(timeout: 5))
        openLab.tap()
        let destination = app.buttons["apiLab.demo.\(route)"]
        XCTAssertTrue(destination.waitForExistence(timeout: 3))
        for _ in 0..<6 where !destination.isHittable { app.swipeUp() }
        XCTAssertTrue(destination.isHittable)
        destination.tap()
        return app
    }

    private func scrollToEither(_ first: XCUIElement, _ second: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 where !first.isHittable && !second.isHittable { app.swipeUp() }
        XCTAssertTrue(first.isHittable || second.isHittable)
    }

    private func openTab(_ title: String, in app: XCUIApplication) {
        // Lookup by the native item label works without assuming a bar axis.
        let identifiedItem = app.buttons["tabs.\(title.lowercased())"]
        let item = identifiedItem.exists ? identifiedItem : app.buttons.matching(
            NSPredicate(format: "label == %@", title)
        ).firstMatch
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        item.tap()
    }

    private func select(_ option: String, from identifier: String, in app: XCUIApplication) {
        let picker = app.buttons[identifier]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.tap()
        let choice = app.buttons.matching(identifier: option).firstMatch
        XCTAssertTrue(choice.waitForExistence(timeout: 3))
        choice.tap()
        assertValue(option, for: identifier, in: app)
    }

    private func assertValue(_ value: String, for identifier: String, in app: XCUIApplication) {
        let element = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing \(identifier)")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", value),
            object: element
        )
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 3), .completed,
                       "Expected \(identifier) to expose \(value)")
    }

    private func assertReviewState(in app: XCUIApplication) {
        assertValue("Engineering", for: "review.category", in: app)
        assertValue("Grid", for: "review.presentation", in: app)
        assertValue("Book Fold", for: "review.pose", in: app)
        assertValue("3", for: "review.recordCount", in: app)
    }

    private func showWorkspaceDetail(in app: XCUIApplication, category: String = "all") {
        let dashboard = app.staticTexts["Adaptive Workspace"]
        if !dashboard.waitForExistence(timeout: 3) {
            let categoryLink = app.buttons["category.\(category)"]
            XCTAssertTrue(categoryLink.waitForExistence(timeout: 5))
            categoryLink.tap()
        }
        XCTAssertTrue(dashboard.waitForExistence(timeout: 8))
    }
}
