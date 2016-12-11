//
//  OvalView.swift
//  Metal2DScroll
//
//  Created by Kaz Yoshikawa on 12/11/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit

class OvalView: UIView {

	@IBOutlet weak var contentView: UIView!

	override func layoutSubviews() {
		super.layoutSubviews()
		self.backgroundColor = UIColor.clear
	}

    override func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()!
		context.saveGState()
		
		let targetRect = self.contentView.convert(self.contentView.bounds, to: self)
		let transform = self.bounds.transform(to: targetRect)
		context.concatenate(transform)
		var rect = self.bounds
		let dx = (rect.width / 2) / 4
		let dy = (rect.height / 2) / 4
		for _ in 0 ..< 4 {
			UIColor.white.set()
			UIBezierPath(ovalIn: rect).stroke()
			rect = rect.insetBy(dx: dx, dy: dy)
		}
		
		context.restoreGState()
    }

}
