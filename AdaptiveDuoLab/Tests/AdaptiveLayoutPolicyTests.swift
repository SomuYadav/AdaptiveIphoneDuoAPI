import SwiftUI
import Testing
@testable import AdaptiveDuoLab

struct AdaptiveLayoutPolicyTests {
    @Test
    func compactAutomaticUsesList() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 390,
            pose: .automatic,
            presentation: .automatic
        )
        #expect(!decision.usesGrid)
        #expect(decision.columnCount == 1)
    }

    @Test
    func innerOpenUsesAvailableWidth() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 900,
            pose: .innerOpen,
            presentation: .automatic
        )
        #expect(decision.usesGrid)
        #expect(decision.columnCount == 3)
    }

    @Test
    func narrowInnerOpenDoesNotForceDenseGrid() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 390,
            pose: .innerOpen,
            presentation: .automatic
        )
        #expect(!decision.usesGrid)
        #expect(decision.columnCount == 1)
    }

    @Test
    func bookFoldUsesTwoRegions() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 760,
            pose: .bookFold,
            presentation: .grid
        )
        #expect(decision.composition == .book)
        #expect(decision.columnCount == 2)
    }

    @Test
    func narrowBookFoldKeepsOneContinuousCollection() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 390,
            pose: .bookFold,
            presentation: .automatic
        )
        #expect(decision.composition == .single)
        #expect(!decision.usesGrid)
        #expect(decision.columnCount == 1)
    }

    @Test
    func bookFoldRequiresEnoughWidthForBothCards() {
        // 48 outer padding + 26 fold + 56 region padding + 2 * 280 card width.
        for (width, expectedComposition) in [
            (CGFloat(689), AdaptiveComposition.single),
            (CGFloat(690), AdaptiveComposition.book)
        ] {
            let decision = AdaptiveLayoutPolicy.decision(
                width: width,
                pose: .bookFold,
                presentation: .grid
            )
            #expect(decision.composition == expectedComposition)
        }
    }

    @Test
    func explicitListOverridesWideWindow() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 1_200,
            pose: .innerOpen,
            presentation: .list
        )
        #expect(!decision.usesGrid)
        #expect(decision.columnCount == 1)
    }

    @Test
    func accessibilityTextUsesOneContinuousColumn() {
        for pose in [DemoPose.automatic, .bookFold, .tabletop] {
            for presentation in CollectionPresentation.allCases {
                let decision = AdaptiveLayoutPolicy.decision(
                    width: 1_200,
                    pose: pose,
                    presentation: presentation,
                    height: 900,
                    dynamicTypeSize: .accessibility1
                )
                #expect(decision.composition == .single)
                #expect(decision.columnCount == 1)
                // Grid stays the selected rendering style, with readable density.
                #expect(decision.usesGrid == (presentation == .grid))
            }
        }
    }

    @Test
    func tabletopRequiresEnoughLocalHeight() {
        for (height, expectedComposition) in [
            (CGFloat(519), AdaptiveComposition.single),
            (CGFloat(520), AdaptiveComposition.tabletop)
        ] {
            let decision = AdaptiveLayoutPolicy.decision(
                width: 900,
                pose: .tabletop,
                presentation: .list,
                height: height
            )
            #expect(decision.composition == expectedComposition)
            #expect(!decision.usesGrid)
        }
    }

    @Test
    func accessibilityBoundaryChangesDensityAndComposition() {
        for (textSize, expectedComposition, expectedColumns) in [
            (DynamicTypeSize.xxxLarge, AdaptiveComposition.book, 2),
            (DynamicTypeSize.accessibility1, AdaptiveComposition.single, 1)
        ] {
            let decision = AdaptiveLayoutPolicy.decision(
                width: 900,
                pose: .bookFold,
                presentation: .grid,
                height: 900,
                dynamicTypeSize: textSize
            )
            #expect(decision.composition == expectedComposition)
            #expect(decision.columnCount == expectedColumns)
        }
    }
}
