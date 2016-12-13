//
//  RenderableDrawView.swift
//  Metal2DScroll
//
//  Created by Kaz Yoshikawa on 12/12/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit

class RenderableDrawView: UIView {

	var renderableView: RenderableView?
	
	var contentView: RenderableContentView? {
		return self.renderableView?.contentView
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		assert(renderableView != nil)
	}

	override func draw(_ layer: CALayer, in context: CGContext) {
		if let contentView = contentView, let renderableScene = renderableView?.renderableScene  {
			let targetRect = contentView.convert(contentView.bounds, to: self)
			let transform = renderableScene.bounds.transform(to: targetRect)
			context.concatenate(transform)

			context.saveGState()
			UIGraphicsPushContext(context)
			renderableScene.draw(in: context)
			UIGraphicsPopContext()
			context.restoreGState()
		}
	}

	override func setNeedsDisplay() {
		self.layer.setNeedsDisplay()
		super.setNeedsDisplay()
	}

}
