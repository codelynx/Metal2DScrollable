//
//	PointsRenderable.swift
//	Metal2D
//
//	Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import MetalKit
import GLKit


//
//	PointsRenderable
//

class PointsRenderable: Renderable {

	typealias RendererType = PointsRenderer

	let device: MTLDevice
	let renderer: PointsRenderer
	var texture: MTLTexture
	var vertices: [PointVertex]
	var vertexBuffer: VertexBuffer<PointVertex>

	init?(device: MTLDevice, texture: MTLTexture, vertices: [PointVertex]) {
		let renderer = PointsRenderer.pointRenderer(for: device)
		let vertexBuffer = renderer.vertexBuffer(for: vertices, capacity: 4096)
		self.device = device
		self.renderer = renderer
		self.texture = texture
		self.vertices = vertices
		self.vertexBuffer = vertexBuffer
	}
	
	func render(context: RenderContext) {
		renderer.renderStroke(context: context, texture: texture, vertexBuffer: vertexBuffer)
	}
	
	func append(_ vertices: [PointVertex]) {
		self.vertices += vertices
		if self.vertices.count < vertexBuffer.count {
			self.vertexBuffer.append(vertices)
		}
		else {
			let vertexBuffer = renderer.vertexBuffer(for: self.vertices, capacity: self.vertices.count + 4096)
			self.vertexBuffer = vertexBuffer
		}
	}
}
