//
//  StrokeRenderer.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import CoreGraphics
import QuartzCore
import GLKit

typealias StrokeVertex = StrokeRenderer.Vertex

//
//	StrokeRenderer
//

class StrokeRenderer: Renderer {

	typealias VertexType = Vertex

	// TODO: needs refactoring

	private static var deviceRendererTable = NSMapTable<MTLDevice, StrokeRenderer>.weakToStrongObjects() // TODO: consider weak-to-weak?

	class func strokeRenderer(for device: MTLDevice) -> StrokeRenderer {
		if let renderer = StrokeRenderer.deviceRendererTable.object(forKey: device) {
			return renderer
		}
		let renderer = StrokeRenderer(device: device)
		StrokeRenderer.deviceRendererTable.setObject(renderer, forKey: device)
		return renderer
	}

	struct Vertex {
		var x: Float
		var y: Float
		var z: Float
		var force: Float

		var altitudeAngle: Float
		var azimuthAngle: Float
		var velocity: Float
		var angle: Float
		init(x: Float, y: Float, z: Float, force: Float, altitudeAngle: Float, azimuthAngle: Float, velocity: Float, angle: Float) {
			self.x = x; self.y = y; self.z = z; self.force = force
			self.altitudeAngle = altitudeAngle; self.azimuthAngle = azimuthAngle; self.velocity = velocity; self.angle = angle
		}
		init() {
			self.x = 0; self.y = 0; self.z = 0; self.force = 0
			self.altitudeAngle = 0; self.azimuthAngle = 0; self.velocity = 0; self.angle = 0
		}
	}

	struct Uniforms {
		var transform: GLKMatrix4
	}

	let device: MTLDevice

	var colorSamplerState: MTLSamplerState!

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
		renderPipelineDescriptor.vertexFunction = self.library.makeFunction(name: "stroke_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.makeFunction(name: "stroke_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
		renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

		let samplerDescriptor = MTLSamplerDescriptor()
		samplerDescriptor.minFilter = .nearest
		samplerDescriptor.magFilter = .linear
		samplerDescriptor.sAddressMode = .repeat
		samplerDescriptor.tAddressMode = .repeat
		self.colorSamplerState = self.device.makeSamplerState(descriptor: samplerDescriptor)

		return try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
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

		commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, at: 0)
		commandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 1)

		commandEncoder.setFragmentTexture(texture, at: 0)
		commandEncoder.setFragmentSamplerState(self.colorSamplerState, at: 0)

		commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertexBuffer.count)
//		commandEncoder.drawPrimitives(.LineStrip, vertexStart: 0, vertexCount: vertexBuffer.count)
	}
}
