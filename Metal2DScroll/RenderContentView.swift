//
//	RenderContentView.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit

class RenderContentView: UIView {

	weak var renderView: RenderView?

	var contentSize: CGSize? {
		return self.renderView?.renderableScene?.contentSize
	}

	override func draw(_ rect: CGRect) {
	}

	override func layoutSubviews() {
		super.layoutSubviews()
	}

	// MARK: -

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		renderView?.renderableScene?.touchesBegan(touches, with: event, contentView: self)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		renderView?.renderableScene?.touchesMoved(touches, with: event, contentView: self)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		renderView?.renderableScene?.touchesEnded(touches, with: event, contentView: self)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		renderView?.renderableScene?.touchesCancelled(touches, with: event, contentView: self)
	}

}
