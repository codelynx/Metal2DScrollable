//
//  StrokeNode.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import MetalKit
import GLKit


//
//	StrokeNode
//

class StrokeRenderable: Renderable {

	let device: MTLDevice
	let renderer: StrokeRenderer
	var texture: MTLTexture
	var vertices: [StrokeVertex]
	var vertexBuffer: VertexBuffer<StrokeVertex>

	init?(device: MTLDevice, texture: MTLTexture, vertices: [StrokeVertex]) {
		let renderer = StrokeRenderer.strokeRenderer(for: device)
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
	
	func append(_ vertices: [StrokeVertex]) {
		self.vertices += vertices
		if self.vertices.count > vertexBuffer.count {
			let vertexBuffer = renderer.vertexBuffer(for: vertices, capacity: vertices.count + 4096)
			self.vertexBuffer = vertexBuffer
		}
		else {
			self.vertexBuffer.append(vertices)
		}
	}
}
