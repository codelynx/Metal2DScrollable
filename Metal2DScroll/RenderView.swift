//
//	RenderView.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit
import MetalKit
import GLKit


class RenderView: UIView, MTKViewDelegate {

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
		scrollView.delaysContentTouches = false
		scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
		self.addSubviewToFit(scrollView)
		scrollView.addSubview(self.contentView)
		self.contentView.frame = self.bounds
		return scrollView
	}()

	private (set) lazy var drawView: RenderDrawView = {
		let drawView = RenderDrawView(frame: self.bounds)
		drawView.backgroundColor = UIColor.clear
		drawView.renderView = self
		self.addSubviewToFit(drawView)
		return drawView
	}()

	private (set) lazy var contentView: RenderContentView = {
		let renderableContentView = RenderContentView(frame: self.bounds)
		renderableContentView.renderView = self
		renderableContentView.backgroundColor = UIColor.clear
		renderableContentView.translatesAutoresizingMaskIntoConstraints = false
		renderableContentView.isUserInteractionEnabled = true
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
		self.drawView.setNeedsDisplay()

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
		let transform1 = renderableScene.bounds.transform(to: targetRect)
		let transform2 = self.mtkView.bounds.transform(to: CGRect(x: -1.0, y: -1.0, width: 2.0, height: 2.0))
		let transform3 = CGAffineTransform.identity.translatedBy(x: 0, y: +1).scaledBy(x: 1, y: -1).translatedBy(x: 0, y: 1)
		let transform = GLKMatrix4(transform1 * transform2 * transform3)
		let renderContext = RenderContext(commandEncoder: commandEncoder, transform: transform)
		renderableScene.render(in: renderContext)

		commandEncoder.endEncoding()
		
		commandBuffer.present(drawable)
		commandBuffer.commit()
	}
	
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
	}

	// MARK: -
	
	var minimumNumberOfTouchesToScroll: Int {
		get { return self.scrollView.panGestureRecognizer.minimumNumberOfTouches }
		set { self.scrollView.panGestureRecognizer.minimumNumberOfTouches = newValue }
	}
	
	var scrollEnabled: Bool {
		get { return self.scrollView.isScrollEnabled }
		set { self.scrollView.isScrollEnabled = newValue }
	}
	
	var delaysContentTouches: Bool {
		get { return self.scrollView.delaysContentTouches }
		set { self.scrollView.delaysContentTouches = newValue }
	}
}


extension RenderView: UIScrollViewDelegate {

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


