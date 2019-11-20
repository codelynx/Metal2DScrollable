//
//	RenderableContent.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import MetalKit


class RenderableScene {

	let device: MTLDevice
	var contentSize: CGSize

	var bounds: CGRect {
		return CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
	}
	
	init?(device: MTLDevice, contentSize: CGSize) {
		self.device = device
		self.contentSize = contentSize
	}

	func didMove(to view: RenderView) {
	}

	func draw(in context: CGContext) {
		
	}

	func render(in context: RenderContext) {
	}

	// MARK: -

	func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
	}
	
	func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
	}
	
	func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
	}
	
	func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
	}
}
