//
//  RenderableContentView.swift
//  Metal2DScroll
//
//  Created by Kaz Yoshikawa on 12/12/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit

class RenderableContentView: UIView {

	weak var renderableView: RenderableView?

	var contentSize: CGSize? {
		return self.renderableView?.renderableScene?.contentSize
	}

	override func draw(_ rect: CGRect) {
//		UIColor.orange.withAlphaComponent(0.25).set()
//		UIBezierPath(ovalIn: self.bounds).fill()
	}

/*
	override var frame: CGRect {
		get { return super.frame }
		set { super.frame = newValue }
	}
*/

	/*
	lazy var widthConstraint: NSLayoutConstraint = {
		return self.widthAnchor.constraint(equalToConstant: self.bounds.width)
	}()

	lazy var heightConstraint: NSLayoutConstraint = {
		return self.widthAnchor.constraint(equalToConstant: self.bounds.height)
	}()
	*/

	override func layoutSubviews() {
		print("RenderableContentView: \(self.bounds)")
		super.layoutSubviews()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		renderableView?.renderableScene?.touchesBegan(touches, with: event, contentView: self)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		renderableView?.renderableScene?.touchesMoved(touches, with: event, contentView: self)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		renderableView?.renderableScene?.touchesEnded(touches, with: event, contentView: self)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		renderableView?.renderableScene?.touchesCancelled(touches, with: event, contentView: self)
	}

}
