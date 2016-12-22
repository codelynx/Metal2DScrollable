//
//	StrokeRenderable.swift
//	Metal2D
//
//	Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import CoreGraphics
import MetalKit
import GLKit



struct StrokePoint {
	var x: Float
	var y: Float

	// other UITouch poroperties

	var point: Point { return Point(x: x, y: y) }
}


//
//	StrokeRenderable
//

class StrokeRenderable: Renderable {

	typealias RendererType = StrokeRenderer
	typealias VertexType = RendererType.VertexType

	var device: MTLDevice
	var points: [TouchPoint]
	var shape: LineShape
	let renderer: StrokeRenderer
	var texture: MTLTexture
	var vertexBuffer: VertexBuffer<VertexType>
	var indexBuffer: VertexBuffer<UInt16>

	init(device: MTLDevice, texture: MTLTexture, points: [TouchPoint]) {
		let renderer = StrokeRenderer.strokeRenderer(for: device)
		self.device = device
		self.points = points
		self.renderer = renderer
		self.texture = texture
		if let shape = LineShape(points: points) {
		}
		self.vertexBuffer = VertexBuffer<StrokeVertex>(device: device, vertices: shape.vertexArray, expand: 8)
		self.indexBuffer = VertexBuffer<UInt16>(device: device, vertices: shape.indexArray, expand: 8)
	}
	
	func render(context: RenderContext) {
		renderer.render(context: context, vertexBuffer: vertexBuffer, indexBuffer: indexBuffer)
	}

	func append(_ points: [TouchPoint]) {
		self.points += points
		self.shape = LineShape(points: self.points)!
		self.vertexBuffer = VertexBuffer<StrokeVertex>(device: device, vertices: shape.vertexArray, expand: 8)
		self.indexBuffer = VertexBuffer<UInt16>(device: device, vertices: shape.indexArray, expand: 8)
	}
}


class StrokeTriangleRenderable: Renderable {

	typealias RendererType = StrokeRenderer

	let device: MTLDevice
	let renderer: StrokeRenderer
	let vertexBuffer: VertexBuffer<StrokeVertex>
	var indexBuffer: VertexBuffer<UInt16>
	var point1: StrokeVertex
	var point2: StrokeVertex
	var point3: StrokeVertex
	
	init?(device: MTLDevice, point1: StrokeVertex, point2: StrokeVertex, point3: StrokeVertex) {
		self.device = device
		self.point1 = point1
		self.point2 = point2
		self.point3 = point3
		let renderer = StrokeRenderer.strokeRenderer(for: device)
		let vertexBuffer = VertexBuffer<StrokeVertex>(device: device, vertices: [point1, point2, point3])
		let indexBuffer = VertexBuffer<UInt16>(device: device, vertices: [0, 1, 2])
		self.renderer = renderer
		self.vertexBuffer = vertexBuffer
		self.indexBuffer = indexBuffer
	}

	func render(context: RenderContext) {
		renderer.render(context: context, vertexBuffer: vertexBuffer, indexBuffer: indexBuffer)
	}

}
