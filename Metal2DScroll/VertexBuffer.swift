//
//  VertexBuffer.swift
//  Metal2D
//
//  Created by Kaz Yoshikawa on 1/11/16.
//
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
	var capacity: Int

	init(device: MTLDevice, vertices: [T], capacity: Int? = nil) {
		self.device = device
		self.count = vertices.count
		self.capacity = capacity ?? vertices.count
		let length = MemoryLayout<T>.size * self.capacity
		self.buffer = device.makeBuffer(bytes: vertices, length: length, options: MTLResourceOptions())
		assert(self.count <= self.capacity)
		/*
		let vertexArray = UnsafeMutablePointer<T>(self.buffer.contents())
		for index in 0 ..< verticies.count {
			let vertex1 = vertexArray[index]
			let vertex2 = verticies[index]
		}
		*/
	}

	func append(_ verticies: [T]) {
		if self.count + verticies.count < self.capacity {
			let vertexArray = UnsafeMutablePointer<T>(OpaquePointer(self.buffer.contents()))
			for index in 0 ..< verticies.count {
				vertexArray[self.count + index] = verticies[index]
			}
			self.count += verticies.count
		}
		else { fatalError("buffer overflow - to do: extend buffer")
		}
	}

}
