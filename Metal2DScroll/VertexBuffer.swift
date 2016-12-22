//
//	VertexBuffer.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 1/11/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import MetalKit
import GLKit

//
//	VertexBuffer
//

class VertexBuffer<T> {

	let device: MTLDevice
	var buffer: MTLBuffer
	var count: Int
	var expand: Int

	init(device: MTLDevice, vertices: [T], expand: Int? = nil) {
		self.device = device
		self.count = vertices.count
		self.expand = (expand ?? 4096)
		let length = MemoryLayout<T>.size * (vertices.count + self.expand)
		self.buffer = device.makeBuffer(bytes: vertices, length: length, options: MTLResourceOptions())
		/*
		let vertexArray = UnsafeMutablePointer<T>(self.buffer.contents())
		for index in 0 ..< verticies.count {
			let vertex1 = vertexArray[index]
			let vertex2 = verticies[index]
		}
		*/
	}

	func append(_ vertices: [T]) {
		if self.count + vertices.count < self.expand {
			let vertexArray = UnsafeMutablePointer<T>(OpaquePointer(self.buffer.contents()))
			for index in 0 ..< vertices.count {
				vertexArray[self.count + index] = vertices[index]
			}
			self.count += vertices.count
		}
		else { fatalError("buffer overflow - to do: extend buffer") }
	}

	var vertices: [T] {
		let vertexArray = UnsafeMutablePointer<T>(OpaquePointer(self.buffer.contents()))
		return (0 ..< count).map { vertexArray[$0] }
	}

}
