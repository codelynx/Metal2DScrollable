//
//  ImageRenderer.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 12/22/15.
//
//

import Foundation
import Metal
import GLKit

typealias ImageVertex = ImageRenderer.Vertex

//
//	ImageRenderer
//

class ImageRenderer: Renderer {

	typealias VertexType = Vertex

	static var deviceRendererTable = NSMapTable<MTLDevice, ImageRenderer>.weakToStrongObjects()
	
	class func imageRenderer(for device: MTLDevice) -> ImageRenderer {
		if let renderer = ImageRenderer.deviceRendererTable.object(forKey: device) {
			return renderer
		}
		let renderer = ImageRenderer(device: device)
		ImageRenderer.deviceRendererTable.setObject(renderer, forKey: device)
		return renderer
	}


	struct Vertex {
		var x, y, z, w, u, v: Float
	}

	struct Uniforms {
		var modelViewProjectionMatrix: GLKMatrix4
	}


	let device: MTLDevice
	
	var colorSamplerState: MTLSamplerState!

	init(device: MTLDevice) {
		self.device = device
	}

	func verticesForRect(_ rect: Rect) -> [Vertex] {
		let l = rect.minX
		let r = rect.maxX
		let t = rect.minY
		let b = rect.maxY
		return [
			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 1),
			Vertex(x: l, y: b, z: 0, w: 1, u: 0, v: 0),
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 0),
			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 1),
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 0),
			Vertex(x: r, y: t, z: 0, w: 1, u: 1, v: 1),
		]
	}

	var library: MTLLibrary {
		return self.device.newDefaultLibrary()!
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = .float4
		vertexDescriptor.attributes[0].bufferIndex = 0

		vertexDescriptor.attributes[1].offset = 0
		vertexDescriptor.attributes[1].format = .float2
		vertexDescriptor.attributes[1].bufferIndex = 0
		
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

		let samplerDescriptor = MTLSamplerDescriptor()
		samplerDescriptor.minFilter = .nearest
		samplerDescriptor.magFilter = .linear
		samplerDescriptor.sAddressMode = .repeat
		samplerDescriptor.tAddressMode = .repeat
		self.colorSamplerState = self.device.makeSamplerState(descriptor: samplerDescriptor)

		return try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
	}()

	func vertexBuffer(for rect: Rect) -> VertexBuffer<Vertex>? {
		let verticies = self.verticesForRect(rect)
		return VertexBuffer<Vertex>(device: device, verticies: verticies)
	}

	func renderImage(context: RenderContext, texture: MTLTexture, vertexBuffer: VertexBuffer<Vertex>) {
		let transform = context.transform
		var uniforms = Uniforms(modelViewProjectionMatrix: transform)
		let uniformsBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.size, options: MTLResourceOptions())
		
		
		let commandEncoder = context.commandEncoder
		commandEncoder.setRenderPipelineState(self.renderPipelineState)

		commandEncoder.setFrontFacing(.counterClockwise)
		commandEncoder.setCullMode(.back)
		commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, at: 0)
		commandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 1)

		commandEncoder.setFragmentTexture(texture, at: 0)
		commandEncoder.setFragmentSamplerState(self.colorSamplerState, at: 0)

		commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexBuffer.count)
	}
}

