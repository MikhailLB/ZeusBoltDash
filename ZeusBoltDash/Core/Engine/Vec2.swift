import CoreGraphics
import Foundation

struct Vec2 {
    var x: Double
    var y: Double

    static let zero = Vec2(x: 0, y: 0)

    var magnitude: Double { (x * x + y * y).squareRoot() }

    var normalized: Vec2 {
        let m = magnitude
        guard m > 0 else { return .zero }
        return Vec2(x: x / m, y: y / m)
    }

    static func + (lhs: Vec2, rhs: Vec2) -> Vec2 { Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
    static func - (lhs: Vec2, rhs: Vec2) -> Vec2 { Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    static func * (v: Vec2, s: Double) -> Vec2 { Vec2(x: v.x * s, y: v.y * s) }
    static func * (s: Double, v: Vec2) -> Vec2 { v * s }

    static func += (lhs: inout Vec2, rhs: Vec2) { lhs = lhs + rhs }

    static func dot(_ a: Vec2, _ b: Vec2) -> Double { a.x * b.x + a.y * b.y }

    func distance(to other: Vec2) -> Double { (self - other).magnitude }

    var asCGPoint: CGPoint { CGPoint(x: x, y: y) }
    var asCGSize: CGSize { CGSize(width: x, height: y) }

    init(x: Double, y: Double) { self.x = x; self.y = y }
    init(_ x: Double, _ y: Double) { self.x = x; self.y = y }
    init(angle: Double, radius: Double) {
        self.x = cos(angle) * radius
        self.y = sin(angle) * radius
    }
}
