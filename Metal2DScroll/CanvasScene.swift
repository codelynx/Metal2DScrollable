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

	lazy var brushTexture: MTLTexture = {
		let image = UIImage(named: "Particle.png")!
		let texture = try! self.device.textureLoader.newTexture(with: image.cgImage!, options: nil)
		return texture
	}()

	var brushStrokes = [StrokeRenderable]()
	var touchStrokes = [UITouch: StrokeRenderable]()

	override init?(device: MTLDevice, contentSize: CGSize) {
		super.init(device: device, contentSize: contentSize)
	}

	override func didMove(to view: RenderView) {
		super.didMove(to: view)
	}

	override func draw(in context: CGContext) {

//		image.draw(in: self.bounds)
		context.setFillColor(UIColor.blue.withAlphaComponent(0.25).cgColor)
//		context.fillEllipse(in: self.bounds)
		context.fillEllipse(in: CGRect(x: 0, y: 0, width: 2048, height: 1024))
	}

	override func render(in context: RenderContext) {
		self.imageRenderable?.render(context: context)
//		self.colorRect?.render(context: context)
		self.colorTriangle?.render(context: context)
	}

	func strokeVertex(touch: UITouch, in view: UIView) -> StrokeVertex {
		let point = touch.location(in: view)
		return StrokeVertex(x: Float(point.x), y: Float(point.y), z: 0, force: 1, altitudeAngle: 0, azimuthAngle: 0, velocity: 1, angle: 1)
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
		print("touchesBegan")
		for touch in touches {
			let point = touch.location(in: contentView)
			let vertex = self.strokeVertex(touch: touch, in: contentView)
			let stroke = StrokeRenderable(device: self.device, texture: self.brushTexture, vertices: [vertex])
			touchStrokes[touch] = stroke
			print("\(point)")
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
		print("touchesMoved")
		guard let event = event else { return }
		for touch in touches {
			guard let stroke = self.touchStrokes[touch] else { continue }
			for coalescedTouch in event.coalescedTouches(for: touch) ?? [] {
				let vertex = self.strokeVertex(touch: coalescedTouch, in: contentView)
				
			}
			let point = touch.location(in: contentView)
			print("\(point)")
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
		print("touchesEnded")
		for touch in touches {
			let point = touch.location(in: contentView)
			print("\(point)")
		}
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
		for touch in touches {
			let point = touch.location(in: contentView)
			print("\(point)")
		}
	}
	
}
