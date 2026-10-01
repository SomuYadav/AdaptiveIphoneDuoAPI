import Foundation
import Testing
@testable import AdaptiveDuoLab

struct ReservedRegionPlacementTests {
    private let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
    private let size = CGSize(width: 100, height: 50)
    private let center = CGPoint(x: 200, y: 150)

    @Test
    func noRegionsPreservesCenteredControl() {
        let frame = ReservedRegionPlacement.frame(
            for: size, in: bounds, avoiding: [], preferredCenter: center
        )
        #expect(frame == CGRect(x: 150, y: 125, width: 100, height: 50))
    }

    @Test
    func activeFullHeightDivisionMovesWholeControlToOneSide() throws {
        let division = CGRect(x: 180, y: 0, width: 40, height: 300)
        let frame = try #require(ReservedRegionPlacement.frame(
            for: size, in: bounds,
            avoiding: [.init(frame: division, isActive: true)], preferredCenter: center
        ))
        #expect(bounds.contains(frame))
        #expect(frame.maxX <= division.minX || frame.minX >= division.maxX)
        #expect(frame.midY == center.y)
    }

    @Test
    func occlusionMovesAlongShortestAvailableAxis() throws {
        let occlusion = CGRect(x: 190, y: 140, width: 20, height: 20)
        let frame = try #require(ReservedRegionPlacement.frame(
            for: size, in: bounds,
            avoiding: [.init(frame: occlusion, isActive: true)], preferredCenter: center
        ))
        #expect(frame.midX == center.x)
        #expect(frame.maxY <= occlusion.minY || frame.minY >= occlusion.maxY)
    }

    @Test
    func inactiveAndNonintersectingRegionsDoNotMoveControl() {
        let frame = ReservedRegionPlacement.frame(
            for: size, in: bounds,
            avoiding: [
                .init(frame: bounds, isActive: false),
                .init(frame: CGRect(x: 500, y: 0, width: 100, height: 300), isActive: true)
            ], preferredCenter: center
        )
        #expect(frame == CGRect(x: 150, y: 125, width: 100, height: 50))
    }

    @Test
    func multipleRegionsAreAvoidedTogether() throws {
        let frame = try #require(ReservedRegionPlacement.frame(
            for: size, in: bounds,
            avoiding: [
                .init(frame: CGRect(x: 180, y: 0, width: 40, height: 300), isActive: true),
                .init(frame: CGRect(x: 0, y: 100, width: 180, height: 100), isActive: true)
            ], preferredCenter: center
        ))
        #expect(frame.minX >= 220)
        #expect(bounds.contains(frame))
    }

    @Test
    func noSafeRectangleRequestsToolbarFallback() {
        #expect(ReservedRegionPlacement.frame(
            for: size, in: bounds,
            avoiding: [.init(frame: bounds, isActive: true)], preferredCenter: center
        ) == nil)
        #expect(ReservedRegionPlacement.frame(
            for: CGSize(width: 500, height: 50), in: bounds,
            avoiding: [], preferredCenter: center
        ) == nil)
    }

    @Test
    func nonzeroLocalOriginAndPreferredPointOutsideBoundsAreClamped() throws {
        let local = CGRect(x: 12, y: 20, width: 300, height: 200)
        let frame = try #require(ReservedRegionPlacement.frame(
            for: size, in: local, avoiding: [], preferredCenter: CGPoint(x: 900, y: -10)
        ))
        #expect(frame == CGRect(x: 212, y: 20, width: 100, height: 50))
    }
}
