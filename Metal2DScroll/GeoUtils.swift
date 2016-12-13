//
//  GeoUtils.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/4/16.
//
//

import Foundation
import CoreGraphics
import QuartzCore
import GLKit

struct Point {
	var x: Float
	var y: Float
	init(_ x: Float, _ y: Float) {
		self.x = x; self.y = y
	}
	init(_ x: CGFloat, _ y: CGFloat) {
		self.x = Float(x); self.y = Float(y)
	}
	init(_ x: Int, _ y: Int) {
		self.x = Float(x); self.y = Float(y)
	}
}

struct Size {
	var width: Float
	var height: Float
	init(_ width: Float, _ height: Float) {
		self.width = width; self.height = height
	}
	init(_ width: CGFloat, _ height: CGFloat) {
		self.width = Float(width); self.height = Float(height)
	}
	init(_ width: Int, _ height: Int) {
		self.width = Float(width); self.height = Float(height)
	}
}

struct Rect {
	var origin: Point
	var size: Size
	init(_ origin: Point, _ size: Size) {
		self.origin = origin; self.size = size
	}
	init(_ x: Float, _ y: Float, _ width: Float, _ height: Float) {
		self.origin = Point(x, y); self.size = Size(width, height)
	}
	init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
		self.origin = Point(x, y); self.size = Size(width, height)
	}
	init(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
		self.origin = Point(x, y); self.size = Size(width, height)
	}
	var minX: Float { return min(origin.x, origin.x + size.width) }
	var maxX: Float { return max(origin.x, origin.x + size.width) }
	var midX: Float { return (origin.x + origin.x + size.width) / 2.0 }
	var minY: Float { return min(origin.y, origin.y + size.height) }
	var maxY: Float { return max(origin.y, origin.y + size.height) }
	var midY: Float { return (origin.y + origin.y + size.height) / 2.0 }

	var CGRectValue: CGRect { return CGRect(x: CGFloat(origin.x), y: CGFloat(origin.y), width: CGFloat(size.width), height: CGFloat(size.height)) }
}

extension CGPoint {
	init(_ point: Point) {
		self.init(x: CGFloat(point.x), y: CGFloat(point.y))
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

extension GLKMatrix4 {
	init(_ transform: CGAffineTransform) {
		let t = CATransform3DMakeAffineTransform(transform)
		self.init(m: (
				Float(t.m11), Float(t.m12), Float(t.m13), Float(t.m14),
				Float(t.m21), Float(t.m22), Float(t.m23), Float(t.m24),
				Float(t.m31), Float(t.m32), Float(t.m33), Float(t.m34),
				Float(t.m41), Float(t.m42), Float(t.m43), Float(t.m44)))
	}
	var scaleFactor : Float {
		return sqrt(m00 * m00 + m01 * m01 + m02 * m02)
	}
	var invert: GLKMatrix4 {
		var invertible: Bool = true
		let t = GLKMatrix4Invert(self, &invertible)
		if !invertible { print("not invertible") }
		return t
	}
	var description: String {
		return	"[ \(self.m00), \(self.m01), \(self.m02), \(self.m03) ;" +
				" \(self.m10), \(self.m11), \(self.m12), \(self.m13) ;" +
				" \(self.m20), \(self.m21), \(self.m22), \(self.m23) ;" +
				" \(self.m30), \(self.m31), \(self.m32), \(self.m33) ]"
	}
}

extension GLKVector2 {
	init(_ point: CGPoint) {
		self.init(v: (Float(point.x), Float(point.y)))
	}
	var description: String {
		return	"[ \(self.x), \(self.y) ]"
	}
}

extension GLKVector4 {
	var description: String {
		return	"[ \(self.x), \(self.y), \(self.z), \(self.w) ]"
	}
}

func * (l: GLKMatrix4, r: GLKMatrix4) -> GLKMatrix4 {
	return GLKMatrix4Multiply(l, r)
}

func + (l: GLKVector2, r: GLKVector2) -> GLKVector2 {
	return GLKVector2Add(l, r)
}

func * (l: GLKMatrix4, r: GLKVector2) -> GLKVector2 {
	let vector4 = GLKMatrix4MultiplyVector4(l, GLKVector4Make(r.x, r.y, 0.0, 1.0))
	return GLKVector2Make(vector4.x, vector4.y)
}


