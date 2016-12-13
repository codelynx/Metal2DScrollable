//
//  CanvasScene.swift
//  Metal2DScroll
//
//  Created by Kaz Yoshikawa on 12/12/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit


class CanvasScene: RenderableScene {

	var image = UIImage(named: "BlueMarble.png")!

	override func draw(in context: CGContext) {
		UIGraphicsPushContext(context)
		image.draw(in: self.bounds)
//		context.draw(self.image.cgImage!, in: self.bounds)
		context.setFillColor(UIColor.blue.withAlphaComponent(0.25).cgColor)
		context.fillEllipse(in: self.bounds)
		UIGraphicsPopContext()
	}
	
}
