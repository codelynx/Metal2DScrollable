//
//  StrokeShape.swift
//  Metal2DScroll
//
//  Created by Kaz Yoshikawa on 12/19/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation

import UIKit
import CoreGraphics



infix operator •
infix operator ⨯
infix operator ×

func angle(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
	return atan2(b.y - a.y, b.x - a.x)
}

func angle(_ a: CPoint, _ b: CPoint) -> CGFloat {
	return atan2(b.y - a.y, b.x - a.x)
}

class CPoint: Hashable {

	var point: CGPoint
	
	var x: CGFloat { return point.x }
	var y: CGFloat { return point.y }
	
	init(_ point: CGPoint) {
		self.point = point
	}
	
	init(x: CGFloat, y: CGFloat) {
		self.point = CGPoint(x: x, y: y)
	}
	
	var hashValue: Int { return self.x.hashValue &- self.y.hashValue }
	
	static func == (lhs: CPoint, rhs: CPoint) -> Bool { // same value points should be different
		return lhs === rhs
	}

	static let zero = CPoint(x: 0, y: 0)
}

extension CPoint {


	static func - (lhs: CPoint, rhs: CPoint) -> CPoint {
		return CPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

	static func + (lhs: CPoint, rhs: CPoint) -> CPoint {
		return CPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func * (lhs: CPoint, rhs: CGFloat) -> CPoint {
		return CPoint(x: lhs.x * rhs, y: lhs.y * rhs)
	}

	static func / (lhs: CPoint, rhs: CGFloat) -> CPoint {
		return CPoint(x: lhs.x / rhs, y: lhs.y / rhs)
	}
	
	static func * (lhs: CPoint, rhs: CPoint) -> CGFloat { // dot product
		return lhs.x * rhs.x + lhs.y * rhs.y
	}

	static func ⨯ (lhs: CPoint, rhs: CPoint) -> CGFloat { // cross product
		return lhs.x * rhs.y - lhs.y * rhs.x
	}

	static func × (lhs: CPoint, rhs: CPoint) -> CGFloat { // cross product
		return lhs.x * rhs.y - lhs.y * rhs.x
	}
	
	var length²: CGFloat {
		return (x * x) + (y * y)
	}

	var length: CGFloat {
		return sqrt(self.length²)
	}

	var normalized: CPoint {
		let length = self.length
		return CPoint(x: x/length, y: y/length)
	}

}

class TouchPoint: CPoint {

	var width: CGFloat

	init(x: CGFloat, y: CGFloat, w: CGFloat) {
		self.width = w
		super.init(CGPoint(x: x, y: y))
	}
}

struct Line {

	var from: CPoint
	var to: CPoint
	
	init(from: CPoint, to: CPoint) {
		self.from = from
		self.to = to
	}
	
	var vector: CPoint { return to - from }
	var length: CGFloat { return (to - from).length }

	static func intersection(_ line1: Line, _ line2: Line, _ segment: Bool) -> CPoint? {
		let v = line2.from - line1.from
		let v1 = line1.to - line1.from
		let v2 = line2.to - line2.from
		let cp = v1 × v2
		if cp == 0 { return nil }

		let cp1 = v × v1 // cross product
		let cp2 = v × v2 // cross product
		
		let t1 = cp2 / cp
		let t2 = cp1 / cp
		let ε = CGFloat(0).nextUp
		if segment {
			if t1 + ε < 0 || t1 - ε > 1 || t2 + ε < 0 || t2 - ε > 1 { return nil }
		}
		return line1.from + v1 * t1
	}

	static func angle(_ line1: Line, _ line2: Line) -> CGFloat {
		let a = line1.to - line1.from
		let b = line2.to - line2.from
		return atan2(b.y - a.y, b.x - a.x)
	}

}

//typealias PointWidth = (point: CPoint, width: CGFloat)

class LineSegment {

	enum Position {
		case from
		case to
	}

	var from: TouchPoint
	var to: TouchPoint
	
	init(from: TouchPoint, to: TouchPoint) {
		self.from = from
		self.to = to
	}
	
	var line: Line {
		return Line(from: from, to: to)
	}
	
	lazy var lineBody: LineBody = {
		return LineBody(p1: self.from, w1: self.from.width, p2: self.to, w2: self.to.width)
	}()

	lazy var fromCap: LineCap = {
		return LineCap(from: self.to, to: self.from, width: self.from.width)
	}()

	lazy var toCap: LineCap = {
		return LineCap(from: self.from, to: self.to, width: self.to.width)
	}()

	func lineCap(_ position: Position) -> LineCap {
		switch position {
		case .from: return self.fromCap
		case .to: return self.toCap
		}
	}
	
	var vector: CPoint {
		return self.to - self.from
	}
}


class LineCap {

	//		    c
	//	   b+---+---+d
	//		|		|
	//	   a+	o	+e
	//		|	|	|
	//		|	|	|

	var a: CPoint
	var b: CPoint
	var c: CPoint
	var d: CPoint
	var e: CPoint

	init(from p1: CPoint, to p2: CPoint, width: CGFloat) {
		let radius = width / 2
		let v = (p2 - p1)
		let halfPi = CGFloat.pi / 2
		let quarterPi = CGFloat.pi / 4
		let sqrt2 = CGFloat(sqrt(2))
		let θ = angle(p1, p2)
		self.a = CPoint(x: cos(θ - halfPi) * radius + p2.x, y: sin(θ - halfPi) * radius + p2.y)
		self.b = CPoint(x: cos(θ - quarterPi) * radius * sqrt2 + p2.x, y: sin(θ - quarterPi) * radius * sqrt2 + p2.y)
		self.c = p2 + v.normalized * radius
		self.d = CPoint(x: cos(θ + quarterPi) * radius * sqrt2 + p2.x, y: sin(θ + quarterPi) * radius * sqrt2 + p2.y)
		self.e = CPoint(x: cos(θ + halfPi) * radius + p2.x, y: sin(θ + halfPi) * radius + p2.y)
	}
}


class LineBody {

	//			p2
	//	   b+---o---+c
	//		|	|	|
	//		|	|	|
	//		|	|	|
	//	   a+---o---+d
	//			p1
	
	var a: CPoint
	var b: CPoint
	var c: CPoint
	var d: CPoint

	init(p1: CPoint, w1: CGFloat, p2: CPoint, w2: CGFloat) {
		let r1 = w1 / 2
		let r2 = w2 / 2
		let halfPi = CGFloat.pi / 2
		let θ = angle(p1, p2)
		self.a = CPoint(x: cos(θ - halfPi) * r1 + p1.x, y: sin(θ - halfPi) * r1 + p1.y)
		self.b = CPoint(x: cos(θ - halfPi) * r2 + p2.x, y: sin(θ - halfPi) * r2 + p2.y)
		self.c = CPoint(x: cos(θ + halfPi) * r2 + p2.x, y: sin(θ + halfPi) * r2 + p2.y)
		self.d = CPoint(x: cos(θ + halfPi) * r1 + p1.x, y: sin(θ + halfPi) * r1 + p1.y)
	}

}


class LineJoint {

    //
    //		+--------------(v)
    //		•p1			p2•	|
    //		+-----------+   |
    //					|	|
    //					|	|
    //					|	|
    //					+-•-+
    //					  p3

	let joint: (left: CPoint?, right: CPoint?)
	let v: CPoint

	init(p1: TouchPoint, p2: TouchPoint, p3: TouchPoint) {
		let line1 = LineSegment(from: p1, to: p2)
		let line2 = LineSegment(from: p3, to: p2)
		let lineBody1 = line1.lineBody
		let lineBody2 = line2.lineBody

		// stoper for narrow angle
		self.v = p2 + (line1.vector + line2.vector).normalized * (p2.width * 0.5)

		let left1 = Line(from: lineBody1.c, to: lineBody1.d)
		let left2 = Line(from: lineBody2.c, to: lineBody2.d)
		let right1 = Line(from: lineBody1.a, to: lineBody1.b)
		let right2 = Line(from: lineBody2.a, to: lineBody2.b)
		let leftJoint = Line.intersection(left1, left2, false)
		let rightJoint = Line.intersection(right1, right2, false)
		self.joint = (left: leftJoint, right: rightJoint)
	}

}


class LineShape {

	var lastTouchPoint: TouchPoint?
	var lastLineSegment: LineSegment?
	var points = [CPoint]()
	var vertexes = [StrokeVertex]()
	var indexes = [UInt16]()
	var endCap = [StrokeVertex]()
	var tentativeTriangles = [(StrokeVertex, StrokeVertex, StrokeVertex)]()


	var leftAnchor = CPoint(x: 0, y: 0)
	var rightAnchor = CPoint(x: 0, y: 0)

	init(_ points: [TouchPoint]) {
		self.append(points)
	}
	
	func append(_ touchPoints: [TouchPoint]) {
		guard touchPoints.count > 0 else { return }

		let touchPoints: [TouchPoint] = [self.lastTouchPoint].flatMap { $0 } + touchPoints
		var lineSegments: [LineSegment] = [self.lastLineSegment].flatMap { $0 }
		lineSegments += touchPoints.pair { (p1, p2) in LineSegment(from: p1, to: p2) }

		var triangles = [(CPoint, CPoint, CPoint)]()
		if let first = lineSegments.first {

			if self.lastLineSegment == nil {
				let cap1a = first.lineCap(.from)

				triangles += [(first.from as CPoint, cap1a.c, cap1a.d)]
				triangles += [(first.from as CPoint, cap1a.d, cap1a.e)]

				triangles += [(first.from as CPoint, cap1a.b, cap1a.c)]
				triangles += [(first.from as CPoint, cap1a.a, cap1a.b)]

				leftAnchor = cap1a.e
				rightAnchor = cap1a.a
			}
		}
		else {
			guard let point = touchPoints.first else { return }
			var tentativeTriangles = [(StrokeVertex, StrokeVertex, StrokeVertex)]()
			let radius = point.width * 0.5
			let (l, t, r, b) = (point.x - radius, point.y - radius, point.x + radius, point.y + radius)
			let (lt, rt, lb, rb) = (CPoint(x: l, y: t), CPoint(x: r, y: t), CPoint(x: l, y: b), CPoint(x: r, y: b))
			tentativeTriangles.append((StrokeVertex(lb), StrokeVertex(lt), StrokeVertex(rt)))
			tentativeTriangles.append((StrokeVertex(lb), StrokeVertex(rt), StrokeVertex(rb)))
			self.tentativeTriangles = tentativeTriangles
		}

		self.lastTouchPoint = touchPoints.last
		self.lastLineSegment = lineSegments.last
		
		lineSegments.pair { (line1, line2) in
			let cap1a = line1.lineCap(.from)
			let cap1b = line1.lineCap(.to)
			let cap2a = line2.lineCap(.from)
			let cap2b = line2.lineCap(.to)

			let leftLines = (Line(from: cap1a.d, to: cap1b.b), Line(from: cap2a.d, to: cap2b.b))
			let rightLines = (Line(from: cap1a.b, to: cap1b.d), Line(from: cap2a.b, to: cap2b.d))

			if let p = Line.intersection(leftLines.0, leftLines.1, true) {
				triangles.append((line1.from, line1.to, p) as (CPoint, CPoint, CPoint))
				triangles.append((line1.from, leftAnchor, p) as (CPoint, CPoint, CPoint))
				leftAnchor = p
			}
			else {
				triangles.append((cap1b.b, cap2a.d, line2.from as CPoint))
				triangles.append((cap1b.b, line1.from as CPoint, leftAnchor))
				triangles.append((cap1b.b, line1.to as CPoint, line1.from as CPoint))
				leftAnchor = cap2a.d
			}

			if let q = Line.intersection(rightLines.0, rightLines.1, true) {
				triangles.append((rightAnchor, line1.from as CPoint, line1.to as CPoint))
				triangles.append((line1.to as CPoint, rightAnchor, q))
				rightAnchor = q
			}
			else {
				triangles.append((line1.from as CPoint, line1.to as CPoint, rightAnchor))
				triangles.append((line1.to as CPoint, cap1b.d, rightAnchor))
				triangles.append((line2.from as CPoint, cap1b.d, cap2a.b))

				rightAnchor = cap2a.b
			}
		}

		// append to vertex and index buffer
		self.append(triangles: triangles)

		// end of the line, but following points may be arrived soon, for now, make it tentative.
		if let last = lineSegments.last {
			var tentativeTriangles = [(StrokeVertex, StrokeVertex, StrokeVertex)]()
			let cap = last.lineCap(.to)
			tentativeTriangles.append((StrokeVertex(last.from), StrokeVertex(self.leftAnchor), StrokeVertex(cap.a)))
			tentativeTriangles.append((StrokeVertex(last.from), StrokeVertex(cap.a), StrokeVertex(last.to)))

			tentativeTriangles.append((StrokeVertex(last.from), StrokeVertex(last.to), StrokeVertex(cap.e)))
			tentativeTriangles.append((StrokeVertex(last.from), StrokeVertex(cap.e), StrokeVertex(self.rightAnchor)))
			self.tentativeTriangles = tentativeTriangles
		}

	}

	private func append(triangles: [(CPoint, CPoint, CPoint)]) {
		guard triangles.count > 0 else { return }
		var points = self.points
		var appendingIndexes = [UInt16]()
		var appendingVertexes = [StrokeVertex]()
		let tentativePoints = triangles.flatMap { [$0.0, $0.1, $0.2] }
		for tentativePoint in tentativePoints {
			if let index = points.index(of: tentativePoint) {
				appendingIndexes.append(UInt16(index))
			}
			else {
				let index = points.count
				points.append(tentativePoint)
				let (x, y) = (Float(tentativePoint.x), Float(tentativePoint.y))
				appendingVertexes.append(StrokeVertex(x: x, y: y, z: 0, w: 1, r: 1, g: 0, b: 0, a: 1))
				appendingIndexes.append(UInt16(index))
			}
		}

		self.points = points
		self.vertexes += appendingVertexes
		self.indexes += appendingIndexes
	}

	func close() {

		if let last = self.lastLineSegment {
			let cap = last.lineCap(.to)

			var triangles = [(CPoint, CPoint, CPoint)]()
			triangles.append((last.from as CPoint, self.leftAnchor, cap.a))
			triangles.append((last.from as CPoint, cap.a, last.to as CPoint))
			triangles.append((last.from as CPoint, last.to as CPoint, cap.e as CPoint))
			triangles.append((last.from as CPoint, cap.e, self.rightAnchor))
//			triangles += [(cap.e, cap.a, cap.b)]
//			triangles += [(cap.e, cap.b, cap.d)]

			self.append(triangles: triangles)
		}

		self.tentativeTriangles = []
	}


}


extension StrokeVertex {

	init(_ touchPoint: TouchPoint) {
		(self.x, self.y) = (Float(touchPoint.x), Float(touchPoint.y))
		(self.z, self.w) = (0, 1)
		(self.r, self.g, self.b, self.a) = (1, 0, 0, 1)
	}

	init(_ point: CPoint) {
		(self.x, self.y) = (Float(point.x), Float(point.y))
		(self.z, self.w) = (0, 1)
		(self.r, self.g, self.b, self.a) = (1, 0, 0, 1)
	}

}

