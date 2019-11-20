//
//	StrokeRenderable.swift
//	Metal2D
//
//	Created by Kaz Yoshikawa on 1/11/16.
//
//

import Foundation
import CoreGraphics
import MetalKit


struct StrokePoint {
	var x: Float
	var y: Float

	// other UITouch poroperties or color

	var point: Point { return Point(x: x, y: y) }
}


//
//	StrokeRenderable
//

class StrokeRenderable: LineShape, Renderable {

	typealias RendererType = StrokeRenderer
	typealias VertexType = RendererType.VertexType

	var device: MTLDevice
	let renderer: StrokeRenderer
	var texture: MTLTexture

	private (set) lazy var vertexBuffer: VertexBuffer<VertexType> = {
		return VertexBuffer<StrokeVertex>(device: self.device, vertices: self.vertexes, expand: 4096)
	}()
	
	private (set) lazy var indexBuffer: VertexBuffer<UInt16> = {
		return VertexBuffer<UInt16>(device: self.device, vertices: self.indexes, expand: 4096)
	}()

	private (set) lazy var tentativeVertexBuffer: VertexBuffer<VertexType> = {
		let vertexes: [VertexType] = self.tentativeTriangles.flatMap { [$0.0, $0.1, $0.2]  }
		return VertexBuffer<StrokeVertex>(device: self.device, vertices: vertexes, expand: 20)
	}()

	override var vertexes: [StrokeVertex] {
		didSet {
			let subarray = vertexes[oldValue.count ..< vertexes.count]
			self.vertexBuffer.append(subarray.map { $0 })
		}
	}

	override var indexes: [UInt16] {
		didSet {
			let subarray = indexes[oldValue.count ..< indexes.count]
			self.indexBuffer.append(subarray.map { $0 })
		}
	}

	override var tentativeTriangles: [(StrokeVertex, StrokeVertex, StrokeVertex)] {
		didSet {
			let vertexes: [VertexType] = self.tentativeTriangles.flatMap { [$0.0, $0.1, $0.2]  }
			self.tentativeVertexBuffer.set(vertexes)
		}
	}

	// MARK: -

	init(device: MTLDevice, texture: MTLTexture, points: [TouchPoint]) {
		let renderer = StrokeRenderer.strokeRenderer(for: device)
		self.device = device
		self.renderer = renderer
		self.texture = texture
		super.init(points)
	}

	deinit {
	}
	
	func render(context: RenderContext) {
		if indexBuffer.count >= 3 && vertexBuffer.count >= 3 {
			renderer.render(context: context, vertexBuffer: vertexBuffer, indexBuffer: indexBuffer)
		}
		if tentativeVertexBuffer.count >= 3 {
			renderer.render(context: context, vertexBuffer: tentativeVertexBuffer)
		}
	}

	func update() {
		self.vertexBuffer.set(self.vertexes)
		self.indexBuffer.set(self.indexes)
	}

	func draw() {
		let colors: [UIColor] = [.yellow, .cyan, .green, .white, .blue]
		for index in stride(from: 0, to: self.indexes.count, by: 3) {
			let index3 = [index + 0, index + 1, index + 2].map { self.indexes[$0] }
			let vertex3 = index3.map { self.vertexes[Int($0)] }
			colors[(index / 3) % colors.count].withAlphaComponent(0.5).set()
			let b = UIBezierPath()
			b.move(to: vertex3[0].cgPoint)
			b.addLine(to: vertex3[1].cgPoint)
			b.addLine(to: vertex3[2].cgPoint)
			b.close()
			b.stroke()
		}

		UIColor.white.set()
		for triangle in self.tentativeTriangles {
			let b = UIBezierPath()
			b.move(to: triangle.0.cgPoint)
			b.addLine(to: triangle.1.cgPoint)
			b.addLine(to: triangle.2.cgPoint)
			b.close()
			b.stroke()
		}
	}
}


