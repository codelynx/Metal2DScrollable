//
//	StrokeRenderer.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 1/11/16.
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

	// MARK: -

	var device: MTLDevice
	var pixelFormat: MTLPixelFormat = .bgra8Unorm

	// MARK: -

	init(device: MTLDevice) {
		self.device = device
	}
	
	deinit {
		print("\(#function)")
	}

	struct Vertex {
		var x, y, z, w, r, g, b, a: Float
		var point: Point { return Point(x: x, y: y) }
		var cgPoint: CGPoint { return CGPoint(x: CGFloat(x), y: CGFloat(y)) }
	}

	struct Uniforms {
		var transform: GLKMatrix4
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = .float4
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
		renderPipelineDescriptor.vertexFunction = self.library.makeFunction(name: "stroke_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.makeFunction(name: "stroke_fragment")!

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

	func render(context: RenderContext, vertexBuffer: VertexBuffer<Vertex>, indexBuffer: VertexBuffer<UInt16>) {
		var uniforms = Uniforms(transform: context.transform)
		let uniformsBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.size, options: MTLResourceOptions())

		let commandEncoder = context.commandEncoder
		commandEncoder.setRenderPipelineState(self.renderPipelineState)
		commandEncoder.setFrontFacing(.counterClockwise)
//		commandEncoder.setFrontFacing(.clockwise)
		commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, at: 0)
		commandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 1)
		
		commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indexBuffer.count, indexType: .uint16, indexBuffer: indexBuffer.buffer, indexBufferOffset: 0)
	}

	func render(context: RenderContext, vertexBuffer: VertexBuffer<Vertex>) {
		var uniforms = Uniforms(transform: context.transform)
		let uniformsBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.size, options: MTLResourceOptions())

		let commandEncoder = context.commandEncoder
		commandEncoder.setRenderPipelineState(self.renderPipelineState)
		commandEncoder.setFrontFacing(.counterClockwise)
//		commandEncoder.setFrontFacing(.clockwise)
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


