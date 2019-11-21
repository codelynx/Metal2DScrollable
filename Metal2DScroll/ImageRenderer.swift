//
//	ImageRenderer.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/22/15.
//
//

import Foundation
import Metal
import simd

typealias ImageVertex = ImageRenderer.Vertex

//
//	ImageRenderer
//

class ImageRenderer: Renderer {

	typealias VertexType = Vertex

	private static var deviceRendererTable = NSMapTable<MTLDevice, ImageRenderer>.weakToStrongObjects()
	
	class func imageRenderer(for device: MTLDevice) -> ImageRenderer {
		if let renderer = ImageRenderer.deviceRendererTable.object(forKey: device) {
			return renderer
		}
		let renderer = ImageRenderer(device: device)
		ImageRenderer.deviceRendererTable.setObject(renderer, forKey: device)
		return renderer
	}

	// MARK: -

	struct Vertex {
		var x, y, z, w, u, v: Float
	}

	struct Uniforms {
		var transform: simd_float4x4
	}


	let device: MTLDevice
	

	init(device: MTLDevice) {
		self.device = device
	}

	func vertices(for rect: Rect) -> [Vertex] {
		let (l, r, t, b) = (rect.minX, rect.maxX, rect.maxY, rect.minY)

		//	vertex	(y)		texture	(v)
		//	1---4	(1) 		a---d 	(0)
		//	|	|			|	|
		//	2---3 	(0)		b---c 	(1)
		//

		return [
			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 0),		// 1, a
			Vertex(x: l, y: b, z: 0, w: 1, u: 0, v: 1),		// 2, b
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 1),		// 3, c

			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 0),		// 1, a
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 1),		// 3, c
			Vertex(x: r, y: t, z: 0, w: 1, u: 1, v: 0),		// 4, d
		]
	}

	var library: MTLLibrary {
		return self.device.makeDefaultLibrary()!
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.layouts[0].stepFunction = .perVertex
		vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.size
		return vertexDescriptor
	}

	lazy var renderPipelineState: MTLRenderPipelineState = {
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = self.library.makeFunction(name: "image_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.makeFunction(name: "image_fragment")!

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
		return self.device.makeSamplerState(descriptor: samplerDescriptor)!
	}()


	func vertexBuffer(for vertices: [Vertex]) -> VertexBuffer<Vertex>? {
		return VertexBuffer<Vertex>(device: device, vertices: vertices)
	}

	func renderImage(context: RenderContext, texture: MTLTexture, vertexBuffer: VertexBuffer<Vertex>) {
		let transform = context.transform
		var uniforms = Uniforms(transform: transform)
		let uniformsBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.size, options: MTLResourceOptions())
		
		let commandEncoder = context.commandEncoder
		commandEncoder.setRenderPipelineState(self.renderPipelineState)

		commandEncoder.setFrontFacing(.clockwise)
//		commandEncoder.setCullMode(.back)
		commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
		commandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
		
		commandEncoder.setFragmentTexture(texture, index: 0)
		commandEncoder.setFragmentSamplerState(self.colorSamplerState, index: 0)

		commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexBuffer.count)
	}
}

