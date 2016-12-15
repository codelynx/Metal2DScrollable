//
//	PointsRenderer.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import CoreGraphics
import QuartzCore
import GLKit

typealias PointVertex = PointsRenderer.Vertex

//
//	PointsRenderer
//

class PointsRenderer: Renderer {

	typealias VertexType = Vertex

	// TODO: needs refactoring

	private static var deviceRendererTable = NSMapTable<MTLDevice, PointsRenderer>.weakToStrongObjects() // TODO: consider weak-to-weak?

	class func pointRenderer(for device: MTLDevice) -> PointsRenderer {
		if let renderer = PointsRenderer.deviceRendererTable.object(forKey: device) {
			return renderer
		}
		let renderer = PointsRenderer(device: device)
		PointsRenderer.deviceRendererTable.setObject(renderer, forKey: device)
		return renderer
	}

	struct Vertex {
		var x: Float
		var y: Float
	}

	struct Uniforms {
		var transform: GLKMatrix4
	}

	let device: MTLDevice


	// MARK: -

	init(device: MTLDevice) {
		self.device = device
	}

	var library: MTLLibrary {
		return self.device.newDefaultLibrary()!
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = .float2
		vertexDescriptor.attributes[0].bufferIndex = 0

		vertexDescriptor.layouts[0].stepFunction = .perVertex
		vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.size
		return vertexDescriptor
	}

	lazy var renderPipelineState: MTLRenderPipelineState = {
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = self.library.makeFunction(name: "points_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.makeFunction(name: "points_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha


		return try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
	}()

	lazy var colorSamplerState: MTLSamplerState = {
		let samplerDescriptor = MTLSamplerDescriptor()
		samplerDescriptor.minFilter = .nearest
		samplerDescriptor.magFilter = .linear
		samplerDescriptor.sAddressMode = .repeat
		samplerDescriptor.tAddressMode = .repeat
		return self.device.makeSamplerState(descriptor: samplerDescriptor)
	}()
	
	func vertexBuffer(for vertices: [Vertex], capacity: Int) -> VertexBuffer<Vertex> {
		return VertexBuffer<Vertex>(device: self.device, vertices: vertices, capacity: capacity)
	}

	func renderStroke(context: RenderContext, texture: MTLTexture, vertexBuffer: VertexBuffer<Vertex>) {
		let transform = context.transform
		var uniforms = Uniforms(transform: transform)
		let uniformsBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.size, options: MTLResourceOptions())

		let commandEncoder = context.commandEncoder
		commandEncoder.setRenderPipelineState(self.renderPipelineState)

		commandEncoder.setFrontFacing(.clockwise)
		commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, at: 0)
		commandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 1)

		commandEncoder.setFragmentTexture(texture, at: 0)
		commandEncoder.setFragmentSamplerState(self.colorSamplerState, at: 0)

		commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertexBuffer.count)
	}
}
