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
		self.contentView.layer.borderWidth = 8
		print("self.contentView=\(self.contentView)")
		self.setNeedsDisplay()
	}

	lazy var device: MTLDevice = {
		return MTLCreateSystemDefaultDevice()!
	}()

	private (set) lazy var mtkView: MTKView = {
		let mtkView = MTKView(frame: self.bounds)
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
		drawView.backgroundColor = UIColor.white
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

	// MARK: -

	override func setNeedsDisplay() {
		super.setNeedsDisplay()
		self.mtkView.setNeedsDisplay()
		self.drawView.setNeedsDisplay()
	}


	// MARK: -

	func draw(in view: MTKView) {
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


