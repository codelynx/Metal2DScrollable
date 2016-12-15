//
//	CanvasScene.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
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
		let pt1 = ColorRenderer.Vertex(x: 1024, y: 0, z: 0, w: 1, r: 1, g: 0, b: 0, a: 0.5)
		let pt2 = ColorRenderer.Vertex(x: 2048, y: 512, z: 0, w: 1, r: 0, g: 1, b: 0, a: 0.5)
		let pt3 = ColorRenderer.Vertex(x: 2048, y: 0, z: 0, w: 1, r: 0, g: 0, b: 1, a: 0.5)
		return ColorTriangleRenderable(device: self.device, point1: pt1, point2: pt2, point3: pt3)
	}()

	lazy var brushTexture: MTLTexture = {
		let image = UIImage(named: "PointsParticle.png")!
		let texture = try! self.device.textureLoader.newTexture(with: image.cgImage!, options: nil)
		return texture
	}()

	private lazy var pointsStrokes = [PointsRenderable]()

	var sampleStroke: PointsRenderable {
		let points: [(Float, Float)] = [
			(342.0, 611.5), (328.0, 616.0), (319.0, 616.0), (307.5, 617.5), (293.5, 619.5), (278.5, 620.5), (262.0, 621.5), (246.5, 621.5), (230.5, 621.5),
			(212.0, 619.5), (195.0, 615.5), (179.5, 610.0), (165.0, 603.0), (151.0, 595.0), (138.0, 585.5), (127.0, 575.0), (117.0, 564.0), (109.0, 552.0),
			(103.0, 539.5), (100.0, 526.5), (99.5, 511.0), (100.0, 492.5), (107.0, 474.5), (118.5, 453.5), (132.0, 434.0), (149.0, 415.5), (169.5, 396.5),
			(194.0, 378.0), (221.5, 361.5), (251.0, 348.5), (280.0, 339.5), (307.5, 333.5), (336.0, 332.5), (365.0, 333.0), (393.5, 340.0), (418.5, 352.0),
			(442.0, 367.0), (463.0, 384.0), (481.0, 402.5), (495.5, 422.5), (506.5, 443.0), (513.5, 464.0), (517.0, 483.0), (518.5, 503.0), (518.5, 522.5),
			(513.0, 541.0), (502.0, 560.0), (488.0, 576.0), (470.5, 591.0), (451.5, 604.5), (429.5, 616.0), (405.5, 625.0), (381.0, 632.5), (357.0, 638.5),
			(333.0, 642.5), (308.5, 644.0), (286.5, 644.5), (263.5, 644.5), (241.5, 642.5), (221.5, 637.0), (204.5, 631.5), (191.5, 625.5), (181.5, 621.0),
			(174.5, 614.5)
		]
		let vertices = points.map { PointVertex(x: $0.0, y: $0.1) }
		return PointsRenderable(device: self.device, texture: self.brushTexture, vertices: vertices)!
	}

	private lazy var textAttributes: [String: AnyObject] = {
		var paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		paragraphStyle.alignment = .center
		return [
			NSFontAttributeName: UIFont.boldSystemFont(ofSize: 32),
			NSForegroundColorAttributeName: UIColor.white,
			NSParagraphStyleAttributeName: paragraphStyle
		]
	}()

	var touchStrokesMap = [UITouch: PointsRenderable]()

	override init?(device: MTLDevice, contentSize: CGSize) {
		super.init(device: device, contentSize: contentSize)
	}

	override func didMove(to view: RenderView) {
		super.didMove(to: view)

		self.pointsStrokes = [self.sampleStroke]

	}

	override func draw(in context: CGContext) {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm:ss"
		(formatter.string(from: Date()) as NSString).draw(at: CGPoint(x: 758, y: 320), withAttributes: self.textAttributes)
	}

	override func render(in context: RenderContext) {
		self.imageRenderable?.render(context: context)
		self.colorTriangle?.render(context: context)
		for stroke in self.pointsStrokes {
			stroke.render(context: context)
		}
		for (_, stroke) in touchStrokesMap {
			stroke.render(context: context)
		}
	}

	func pointVertex(touch: UITouch, in view: UIView) -> PointVertex {
		let point = touch.location(in: view)
		return PointVertex(x: Float(point.x), y: Float(point.y))
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
		print("touchesBegan")
		for touch in touches {
			let point = touch.location(in: contentView)
			let vertex = self.pointVertex(touch: touch, in: contentView)
			let stroke = PointsRenderable(device: self.device, texture: self.brushTexture, vertices: [vertex])
			touchStrokesMap[touch] = stroke
			print("\(point)")
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
		print("touchesMoved")
		guard let event = event else { return }
		for touch in touches {
			guard let stroke = self.touchStrokesMap[touch] else { continue }
			for coalescedTouch in event.coalescedTouches(for: touch) ?? [] {
				let vertex = self.pointVertex(touch: coalescedTouch, in: contentView)
				stroke.append([vertex])
			}
			let point = touch.location(in: contentView)
			print("\(point)")
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
		print("touchesEnded")
		for touch in touches {
			guard let stroke = self.touchStrokesMap[touch] else { continue }
			self.pointsStrokes.append(stroke)
			if self.pointsStrokes.count > 3 {
				self.pointsStrokes.removeFirst()
			}
			self.touchStrokesMap[touch] = nil
		}
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, contentView: UIView) {
		for touch in touches {
			let point = touch.location(in: contentView)
			print("\(point)")
			self.touchStrokesMap[touch] = nil
		}
	}
	
}
