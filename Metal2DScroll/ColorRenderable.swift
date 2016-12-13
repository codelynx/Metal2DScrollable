//
//  ColorRenderable.swift
//  Metal2DScroll
//
//  Created by Kaz Yoshikawa on 12/13/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import MetalKit
import GLKit

typealias ColorVertex = ColorRenderer.Vertex

class ColorRectRenderable: Renderable {

	let device: MTLDevice
	let renderer: ColorRenderer
	let vertexBuffer: VertexBuffer<ColorVertex>
	var frame: Rect
	var color: XColor
	
	init?(device: MTLDevice, frame: Rect, color: XColor) {
		self.device = device
		self.frame = frame
		self.color = color
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		color.getRed(&r, green: &g, blue: &b, alpha: &a)
		let renderer = ColorRenderer.colorRenderer(for: device)
		let vertices = renderer.vertices(for: frame, color: color)
		guard let vertexBuffer = renderer.vertexBuffer(for: vertices) else { return nil }
		self.renderer = renderer
		self.vertexBuffer = vertexBuffer
	}

	func render(context: RenderContext) {
		self.renderer.render(context: context, vertexBuffer: vertexBuffer)
	}

}


class ColorTriangleRenderable: Renderable {

	let device: MTLDevice
	let renderer: ColorRenderer
	let vertexBuffer: VertexBuffer<ColorVertex>
	var point1: ColorVertex
	var point2: ColorVertex
	var point3: ColorVertex
	
	init?(device: MTLDevice, point1: ColorVertex, point2: ColorVertex, point3: ColorVertex) {
		self.device = device
		self.point1 = point1
		self.point2 = point2
		self.point3 = point3
		let renderer = ColorRenderer.colorRenderer(for: device)
		let vertices: [ColorVertex] = [ point1, point2, point3 ]
		guard let vertexBuffer = renderer.vertexBuffer(for: vertices) else { return nil }
		self.renderer = renderer
		self.vertexBuffer = vertexBuffer
	}

	func render(context: RenderContext) {
		self.renderer.render(context: context, vertexBuffer: vertexBuffer)
	}

}
