import Foundation

/// Places one foreground control using geometry from its own container.
/// Apple's ReservedRegion.frame already includes its interactive margins.
/// Callers must not expand the frame by those margins a second time.
enum ReservedRegionPlacement {
    struct Obstacle {
        let frame: CGRect
        let isActive: Bool
    }

    static func frame(
        for controlSize: CGSize,
        in bounds: CGRect,
        avoiding regions: [Obstacle],
        preferredCenter: CGPoint
    ) -> CGRect? {
        guard isFinite(bounds),
              controlSize.width.isFinite, controlSize.height.isFinite,
              preferredCenter.x.isFinite, preferredCenter.y.isFinite,
              controlSize.width > 0, controlSize.height > 0,
              bounds.width >= controlSize.width,
              bounds.height >= controlSize.height else {
            return nil
        }

        let obstacles = regions.filter {
            $0.isActive && isFinite($0.frame) && overlaps($0.frame, bounds)
        }.map(\.frame)
        let minX = bounds.minX
        let maxX = bounds.maxX - controlSize.width
        let minY = bounds.minY
        let maxY = bounds.maxY - controlSize.height
        let idealX = preferredCenter.x - controlSize.width / 2
        let idealY = preferredCenter.y - controlSize.height / 2

        // For axis-aligned rectangles a nearest valid position is at the
        // preferred coordinate, a container edge, or an obstacle edge.
        let xs = [clamp(idealX, minX, maxX), minX, maxX] + obstacles.flatMap {
            [clamp($0.minX - controlSize.width, minX, maxX), clamp($0.maxX, minX, maxX)]
        }
        let ys = [clamp(idealY, minY, maxY), minY, maxY] + obstacles.flatMap {
            [clamp($0.minY - controlSize.height, minY, maxY), clamp($0.maxY, minY, maxY)]
        }

        var result: CGRect?
        var shortestDistance = CGFloat.infinity
        for x in xs {
            for y in ys {
                let candidate = CGRect(origin: CGPoint(x: x, y: y), size: controlSize)
                guard !obstacles.contains(where: { overlaps(candidate, $0) }) else { continue }
                let dx = candidate.midX - preferredCenter.x
                let dy = candidate.midY - preferredCenter.y
                let distance = dx * dx + dy * dy
                if distance < shortestDistance {
                    shortestDistance = distance
                    result = candidate
                }
            }
        }
        return result
    }

    private static func clamp(_ value: CGFloat, _ lower: CGFloat, _ upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }

    private static func isFinite(_ rect: CGRect) -> Bool {
        rect.origin.x.isFinite && rect.origin.y.isFinite &&
        rect.width.isFinite && rect.height.isFinite &&
        rect.width > 0 && rect.height > 0
    }

    private static func overlaps(_ lhs: CGRect, _ rhs: CGRect) -> Bool {
        lhs.minX < rhs.maxX && lhs.maxX > rhs.minX &&
        lhs.minY < rhs.maxY && lhs.maxY > rhs.minY
    }
}
