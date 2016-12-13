//
//  RenderableView.swift
//  Metal2DScroll
//
//  Created by Kaz Yoshikawa on 12/12/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit
import MetalKit
import GLKit


class RenderableView: UIView, MTKViewDelegate {

	var renderableScene: RenderableScene? {
		didSet {
			if renderableScene !== oldValue {
				if let renderableScene = renderableScene {
					self.mtkView.device = renderableScene.device
					self.commandQueue = renderableScene.device.makeCommandQueue()
					renderableScene.didMove(to: self)
				}
				self.setNeedsLayout()
			}
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.sendSubview(toBack: self.mtkView)
		self.bringSubview(toFront: self.drawView)
		self.bringSubview(toFront: self.scrollView)

		if let renderableScene = self.renderableScene {
			let contentSize = renderableScene.contentSize
			self.scrollView.contentSize = contentSize
			self.contentView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
		}
		else {
			self.scrollView.contentSize = self.bounds.size
			self.contentView.frame = self.bounds
		}
		self.contentView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
		self.contentView.layer.borderColor = UIColor.brown.cgColor
		self.contentView.layer.borderWidth = 1
		print("self.contentView=\(self.contentView)")
		self.setNeedsDisplay()
	}

	private (set) lazy var mtkView: MTKView = {
		let mtkView = MTKView(frame: self.bounds)
		mtkView.device = MTLCreateSystemDefaultDevice()!
		mtkView.delegate = self
		self.addSubviewToFit(mtkView)
		return mtkView
	}()

	private (set) lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView(frame: self.bounds)
		scrollView.delegate = self
		scrollView.backgroundColor = UIColor.clear
		scrollView.maximumZoomScale = 4.0
		scrollView.minimumZoomScale = 1.0
		scrollView.autoresizesSubviews = false
		self.addSubviewToFit(scrollView)
		scrollView.addSubview(self.contentView)
		self.contentView.frame = self.bounds
		return scrollView
	}()

	private (set) lazy var drawView: RenderableDrawView = {
		let drawView = RenderableDrawView(frame: self.bounds)
		drawView.backgroundColor = UIColor.clear
		drawView.renderableView = self
		self.addSubviewToFit(drawView)
		return drawView
	}()

	private (set) lazy var contentView: RenderableContentView = {
		let renderableContentView = RenderableContentView(frame: self.bounds)
		//renderableContentView.image = UIImage(named: "BlueMarble.png")
		renderableContentView.backgroundColor = UIColor.clear
		renderableContentView.translatesAutoresizingMaskIntoConstraints = false
		return renderableContentView
	}()

	var device: MTLDevice {
		return self.mtkView.device!
	}

	private var commandQueue: MTLCommandQueue?

	// MARK: -

	override func setNeedsDisplay() {
		super.setNeedsDisplay()
		self.mtkView.setNeedsDisplay()
		self.drawView.setNeedsDisplay()
	}


	// MARK: -

	func draw(in view: MTKView) {
		print("draw...begin")
		guard let drawable = self.mtkView.currentDrawable else { return }
		guard let renderPassDescriptor = self.mtkView.currentRenderPassDescriptor else { return }
		guard let renderableScene = self.renderableScene else { return }
		guard let commandQueue = self.commandQueue else { return }

		renderPassDescriptor.colorAttachments[0].texture = drawable.texture // error on simulator target
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.9, 0.9, 0.9, 1)
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.colorAttachments[0].storeAction = .store

		let commandBuffer = commandQueue.makeCommandBuffer()
		let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
	
		let targetRect = contentView.convert(self.contentView.bounds, to: self.mtkView)
		let transform0 = CGAffineTransform.identity.translatedBy(x: 0, y: contentView.bounds.height).scaledBy(x: 1, y: -1)
//		let transform0 = CGAffineTransform.identity
		let transform1 = renderableScene.bounds.transform(to: targetRect)
		let transform2 = self.mtkView.bounds.transform(to: CGRect(x: -1.0, y: -1.0, width: 2.0, height: 2.0))
//		let transform2 = self.mtkView.bounds.transform(to: CGRect(x: 1.0, y: 1.0, width: -2.0, height: -2.0))
//		let transform3 = CGAffineTransform.identity.translatedBy(x: 0, y: 2.0) //.scaledBy(x: 1, y: -1)
		let transform3 = CGAffineTransform.identity
		let transform = GLKMatrix4(transform0 * transform1 * transform2 * transform3)
//		let transform = GLKMatrix4Identity
		let renderContext = RenderContext(commandEncoder: commandEncoder, transform: transform)
		renderableScene.render(in: renderContext)

		commandEncoder.endEncoding()
		
		commandBuffer.present(drawable)
		commandBuffer.commit()
		print("draw...end")
	}
	
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
	}

	// MARK: -

	func drawOverlay(_ overlayView: OvalView) {
	}
}


extension RenderableView: UIScrollViewDelegate {

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.contentView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.setNeedsDisplay()
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.setNeedsDisplay()
	}
	
}


