//
//	GeoUtils.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 1/4/16.
//
//

import Foundation
import CoreGraphics
import QuartzCore
import simd


infix operator •
infix operator ×

protocol FloatCovertible {
	var floatValue: Float { get }
}

extension CGFloat: FloatCovertible {
	var floatValue: Float { return Float(self) }
}

extension Int: FloatCovertible {
	var floatValue: Float { return Float(self) }
}


struct Point: Hashable {

	var x: Float
	var y: Float

	static func - (lhs: Point, rhs: Point) -> Point {
		return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

	static func + (lhs: Point, rhs: Point) -> Point {
		return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func * (lhs: Point, rhs: Float) -> Point {
		return Point(x: lhs.x * rhs, y: lhs.y * rhs)
	}

	static func / (lhs: Point, rhs: Float) -> Point {
		return Point(x: lhs.x / rhs, y: lhs.y / rhs)
	}
	
	static func * (lhs: Point, rhs: Point) -> Float { // dot product
		return lhs.x * rhs.x + lhs.y * rhs.y
	}

	static func × (lhs: Point, rhs: Point) -> Float { // cross product
		return lhs.x * rhs.y - lhs.y * rhs.x
	}
	
	var length²: Float {
		return (x * x) + (y * y)
	}

	var length: Float {
		return sqrt(self.length²)
	}

	var normalized: Point {
		let length = self.length
		return Point(x: x/length, y: y/length)
	}

	func angle(to: Point) -> Float {
		return atan2(to.y - self.y, to.x - self.x)
	}

	func angle(from: Point) -> Float {
		return atan2(self.y - from.y, self.x - from.x)
	}

	static func == (lhs: Point, rhs: Point) -> Bool {
		return lhs.x == rhs.y && lhs.y == rhs.y
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.x)
		hasher.combine(self.y)
	}
}

extension Point {

	init<X: FloatCovertible, Y: FloatCovertible>(_ x: X, _ y: Y) {
		self.x = x.floatValue
		self.y = y.floatValue
	}
	init<X: FloatCovertible, Y: FloatCovertible>(x: X, y: Y) {
		self.x = x.floatValue
		self.y = y.floatValue
	}
}


struct Size {
	var width: Float
	var height: Float

	init<W: FloatCovertible, H: FloatCovertible>(_ width: W, _ height: H) {
		self.width = width.floatValue
		self.height = height.floatValue
	}

	init<W: FloatCovertible, H: FloatCovertible>(width: W, height: H) {
		self.width = width.floatValue
		self.height = height.floatValue
	}
}


struct Rect: CustomStringConvertible {
	var origin: Point
	var size: Size

	init(origin: Point, size: Size) {
		self.origin = origin; self.size = size
	}

	init(_ origin: Point, _ size: Size) {
		self.origin = origin; self.size = size
	}

	init<X: FloatCovertible, Y: FloatCovertible, W: FloatCovertible, H: FloatCovertible>(_ x: X, _ y: Y, _ width: W, _ height: H) {
		self.origin = Point(x: x, y: y)
		self.size = Size(width: width, height: height)
	}

	init<X: FloatCovertible, Y: FloatCovertible, W: FloatCovertible, H: FloatCovertible>(x: X, y: Y, width: W, height: H) {
		self.origin = Point(x: x, y: y)
		self.size = Size(width: width, height: height)
	}

	var minX: Float { return min(origin.x, origin.x + size.width) }
	var maxX: Float { return max(origin.x, origin.x + size.width) }
	var midX: Float { return (origin.x + origin.x + size.width) / 2.0 }
	var minY: Float { return min(origin.y, origin.y + size.height) }
	var maxY: Float { return max(origin.y, origin.y + size.height) }
	var midY: Float { return (origin.y + origin.y + size.height) / 2.0 }

	var cgRectValue: CGRect { return CGRect(x: CGFloat(origin.x), y: CGFloat(origin.y), width: CGFloat(size.width), height: CGFloat(size.height)) }
	var description: String { return "{Rect: (\(origin.x),\(origin.y))-(\(size.width), \(size.height))}" }
}

// MARK: -

// MARK: -

extension CGPoint {

	init(_ point: Point) {
		self.init(x: CGFloat(point.x), y: CGFloat(point.y))
	}

	static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

	static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
	}

	static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
	}
	
	static func * (lhs: CGPoint, rhs: CGPoint) -> CGFloat { // dot product
		return lhs.x * rhs.x + lhs.y * rhs.y
	}

	static func ⨯ (lhs: CGPoint, rhs: CGPoint) -> CGFloat { // cross product
		return lhs.x * rhs.y - lhs.y * rhs.x
	}

	static func × (lhs: CGPoint, rhs: CGPoint) -> CGFloat { // cross product
		return lhs.x * rhs.y - lhs.y * rhs.x
	}
	
	var length²: CGFloat {
		return (x * x) + (y * y)
	}

	var length: CGFloat {
		return sqrt(self.length²)
	}

	var normalized: CGPoint {
		let length = self.length
		return CGPoint(x: x/length, y: y/length)
	}

}


extension CGSize {
	init(_ size: Size) {
		self.init(width: CGFloat(size.width), height: CGFloat(size.height))
	}
}


extension CGRect {
	init(_ rect: Rect) {
		self.init(origin: CGPoint(rect.origin), size: CGSize(rect.size))
	}
}


func CGRectMakeAspectFill(_ imageSize: CGSize, _ bounds: CGRect) -> CGRect {
	let result: CGRect
	let margin: CGFloat
	let horizontalRatioToFit = bounds.size.width / imageSize.width
	let verticalRatioToFit = bounds.size.height / imageSize.height
	let imageHeightWhenItFitsHorizontally = horizontalRatioToFit * imageSize.height
	let imageWidthWhenItFitsVertically = verticalRatioToFit * imageSize.width
	let minX = bounds.minX
	let minY = bounds.minY

	if (imageHeightWhenItFitsHorizontally > bounds.size.height) {
		margin = (imageHeightWhenItFitsHorizontally - bounds.size.height) * 0.5
		result = CGRect(x: minX, y: minY - margin, width: imageSize.width * horizontalRatioToFit, height: imageSize.height * horizontalRatioToFit)
	}
	else {
		margin = (imageWidthWhenItFitsVertically - bounds.size.width) * 0.5
		result = CGRect(x: minX - margin, y: minY, width: imageSize.width * verticalRatioToFit, height: imageSize.height * verticalRatioToFit)
	}
	return result;
}

func CGRectMakeAspectFit(_ imageSize: CGSize, _ bounds: CGRect) -> CGRect {
	let minX = bounds.minX
	let minY = bounds.minY
	let widthRatio = bounds.size.width / imageSize.width
	let heightRatio = bounds.size.height / imageSize.height
	let ratio = min(widthRatio, heightRatio)
	let width = imageSize.width * ratio
	let height = imageSize.height * ratio
	let xmargin = (bounds.size.width - width) / 2.0
	let ymargin = (bounds.size.height - height) / 2.0
	return CGRect(x: minX + xmargin, y: minY + ymargin, width: width, height: height)
}

func CGSizeMakeAspectFit(_ imageSize: CGSize, frameSize: CGSize) -> CGSize {
	let widthRatio = frameSize.width / imageSize.width
	let heightRatio = frameSize.height / imageSize.height
	let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
	let width = imageSize.width * ratio
	let height = imageSize.height * ratio
	return CGSize(width: width, height: height)
}


extension simd_float4x4 {
	init(_ transform: CGAffineTransform) {
		let t = CATransform3DMakeAffineTransform(transform)
		self = simd_float4x4([
			[Float(t.m11), Float(t.m12), Float(t.m13), Float(t.m14)],
			[Float(t.m21), Float(t.m22), Float(t.m23), Float(t.m24)],
			[Float(t.m31), Float(t.m32), Float(t.m33), Float(t.m34)],
			[Float(t.m41), Float(t.m42), Float(t.m43), Float(t.m44)]
		])
	}
}
