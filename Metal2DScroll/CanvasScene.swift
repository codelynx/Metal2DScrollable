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

	lazy var imageRenderable: ImageRenderable? = {
		return ImageRenderable(device: self.device, image: self.image, frame: Rect(0, 0, 2048, 1024))
	}()

	lazy var colorRect: ColorRectRenderable? = {
		let rect = Rect(Float(0), 0, 2048, 1024)
		return ColorRectRenderable(device: self.device, frame: rect, color: UIColor.red.withAlphaComponent(0.25))
	}()

	lazy var colorTriangle: ColorTriangleRenderable? = {
		let pt1 = ColorRenderer.Vertex(x: 0, y: 0, z: 0, w: 1, r: 1, g: 0, b: 0, a: 0.25)
		let pt2 = ColorRenderer.Vertex(x: 0, y: 1024, z: 0, w: 1, r: 0, g: 1, b: 0, a: 0.25)
		let pt3 = ColorRenderer.Vertex(x: 2048, y: 0, z: 0, w: 1, r: 0, g: 0, b: 1, a: 0.25)
		return ColorTriangleRenderable(device: self.device, point1: pt1, point2: pt2, point3: pt3)
	}()

	override init?(device: MTLDevice, contentSize: CGSize) {
		super.init(device: device, contentSize: contentSize)
	}

	override func didMove(to view: RenderableView) {
		super.didMove(to: view)
	}

	override func draw(in context: CGContext) {

//		image.draw(in: self.bounds)
//		context.setFillColor(UIColor.blue.withAlphaComponent(0.25).cgColor)
//		context.fillEllipse(in: self.bounds)
//		context.fillEllipse(in: CGRect(x: 0, y: 512, width: 1024, height: 512))
	}

	override func render(in context: RenderContext) {
		self.imageRenderable?.render(context: context)
		self.colorRect?.render(context: context)
		self.colorTriangle?.render(context: context)
	}
	
}
