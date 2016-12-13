//
//  ImageNode.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import MetalKit
import GLKit


#if os(macOS)
typealias XColor = NSColor
typealias XImage = NSImage
#elseif os(iOS)
typealias XColor = UIColor
typealias XImage = UIImage
#endif


extension MTLDevice {

	var textureLoader: MTKTextureLoader {
		return MTKTextureLoader(device: self)
	}

}


//
//	ImageNode
//

class ImageRenderable: Renderable {

	let device: MTLDevice
	var transform = GLKMatrix4Identity

	var image: XImage
	var frame: Rect
	fileprivate var _vertexBuffer: VertexBuffer<ImageVertex>?
	fileprivate var _texture: MTLTexture?

	init(device: MTLDevice, image: XImage, frame: Rect) {
		self.device = device
		self.image = image
		self.frame = frame
	}

	var texture: MTLTexture? {
		if _texture == nil {
			if let image = self.image.cgImage {
				do { _texture = try self.device.textureLoader.newTexture(with: image, options: nil) }
				catch let error { print("\(error)") }
			}
		}
		return _texture
	}

	var imageRenderer: ImageRenderer {
		return ImageRenderer.imageRenderer(for: self.device)
	}

	var vertexBuffer: VertexBuffer<ImageVertex>? {
		if _vertexBuffer == nil {
			let renderer = self.imageRenderer
			_vertexBuffer = renderer.vertexBuffer(for: self.frame)
		}
		return _vertexBuffer
	}


	func render(_ context: RenderContext) {
		let renderer = self.imageRenderer
		if let texture = self.texture, let vertexBuffer = self.vertexBuffer {
			renderer.renderImage(context: context, texture: texture, vertexBuffer: vertexBuffer)
		}
	}
	
}

