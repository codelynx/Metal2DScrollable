//
//	ImageRenderable.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 1/11/16.
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

	typealias RendererType = ImageRenderer

	let device: MTLDevice
	var transform = GLKMatrix4Identity

	var image: XImage
	var frame: Rect
	let texture: MTLTexture
	let renderer: ImageRenderer
	var vertexBuffer: VertexBuffer<ImageVertex>

	init?(device: MTLDevice, image: XImage, frame: Rect) {
		guard let cgImage = image.cgImage else { return nil }
        var options: [MTKTextureLoader.Option : NSObject] = [MTKTextureLoader.Option.SRGB: false as NSNumber]
		if #available(iOS 10.0, *) {
            options[MTKTextureLoader.Option.origin] = true as NSNumber
		}
        guard let texture = try? device.textureLoader.newTexture(cgImage: cgImage, options: options) else { return nil }
		let renderer = ImageRenderer.imageRenderer(for: device)
		let vertices = renderer.vertices(for: frame)
		guard let vertexBuffer = renderer.vertexBuffer(for: vertices) else { return nil }

		self.device = device
		self.image = image
		self.frame = frame
		self.texture = texture
		self.renderer = renderer
		self.vertexBuffer = vertexBuffer
	}

	func render(context: RenderContext) {
		self.renderer.renderImage(context: context, texture: texture, vertexBuffer: vertexBuffer)
	}
	
}

