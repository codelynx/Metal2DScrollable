//
//	SolidRenderer.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 11/12/16.
//
//

import Foundation
import MetalKit
import GLKit


class ColorRenderer: Renderer {

	typealias VertexType = Vertex

	// TODO: needs refactoring

	private static var deviceRendererTable = NSMapTable<MTLDevice, ColorRenderer>.weakToStrongObjects() // TODO: consider weak-to-weak?

	class func colorRenderer(for device: MTLDevice) -> ColorRenderer {
		if let renderer = ColorRenderer.deviceRendererTable.object(forKey: device) {
			return renderer
		}
		let renderer = ColorRenderer(device: device)
		ColorRenderer.deviceRendererTable.setObject(renderer, forKey: device)
		return renderer
	}

	// MARK: -

	var device: MTLDevice
	var pixelFormat: MTLPixelFormat = .bgra8Unorm

	// MARK: -

	init(device: MTLDevice) {
		self.device = device
	}
	
	deinit {
	}

	struct Vertex {
		var x, y, z, w, r, g, b, a: Float
	}

	struct Uniforms {
		var transform: GLKMatrix4
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = .float2
		vertexDescriptor.attributes[0].bufferIndex = 0

		vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 4
		vertexDescriptor.attributes[1].format = .float4
		vertexDescriptor.attributes[1].bufferIndex = 0
		
		vertexDescriptor.layouts[0].stepFunction = .perVertex
		vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.size
		return vertexDescriptor
	}

	lazy var library: MTLLibrary = {
		return self.device.newDefaultLibrary()!
	}()

	lazy var renderPipelineState: MTLRenderPipelineState = {
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = self.library.makeFunction(name: "color_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.makeFunction(name: "color_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = self.pixelFormat
		renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
		
		let renderPipelineState = try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
		return renderPipelineState
	}()

	lazy var colorSamplerState: MTLSamplerState = {
		let samplerDescriptor = MTLSamplerDescriptor()
		samplerDescriptor.minFilter = .nearest
		samplerDescriptor.magFilter = .linear
		samplerDescriptor.sAddressMode = .repeat
		samplerDescriptor.tAddressMode = .repeat
		return self.device.makeSamplerState(descriptor: samplerDescriptor)
	}()

	func render(context: RenderContext, vertexBuffer: VertexBuffer<Vertex>) {
		var uniforms = Uniforms(transform: context.transform)
		let uniformsBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.size, options: MTLResourceOptions())

		let commandEncoder = context.commandEncoder
		commandEncoder.setRenderPipelineState(self.renderPipelineState)
		commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, at: 0)
		commandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 1)
		
		commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexBuffer.count)
	}

	func vertexBuffer(for vertices: [Vertex]) -> VertexBuffer<Vertex>? {
		return VertexBuffer<Vertex>(device: device, vertices: vertices)
	}

	func vertices(for rect: Rect, color: UIColor) -> [Vertex] {
		let l = rect.minX, r = rect.maxX, t = rect.minY, b = rect.maxY
		let rgba = color.rgba
		let (_r, _g, _b, _a) = (Float(rgba.r), Float(rgba.g), Float(rgba.b), Float(rgba.a))
		return [
			Vertex(x: l, y: t, z: 0, w: 1, r: _r, g: _g, b: _b, a: _a),
			Vertex(x: l, y: b, z: 0, w: 1, r: _r, g: _g, b: _b, a: _a),
			Vertex(x: r, y: b, z: 0, w: 1, r: _r, g: _g, b: _b, a: _a),
			Vertex(x: l, y: t, z: 0, w: 1, r: _r, g: _g, b: _b, a: _a),
			Vertex(x: r, y: b, z: 0, w: 1, r: _r, g: _g, b: _b, a: _a),
			Vertex(x: r, y: t, z: 0, w: 1, r: _r, g: _g, b: _b, a: _a),
		]
	}
}

