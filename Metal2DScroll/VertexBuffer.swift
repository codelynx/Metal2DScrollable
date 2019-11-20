//
//	VertexBuffer.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 1/11/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import MetalKit


//
//	VertexBuffer
//

class VertexBuffer<T> {

	let device: MTLDevice
	var buffer: MTLBuffer
	var count: Int
	var capacity: Int
	var expand: Int


	init(device: MTLDevice, vertices: [T], expand: Int? = nil) {
		self.device = device
		self.count = vertices.count
		self.expand = (expand ?? 4096)
		let length = MemoryLayout<T>.size * (vertices.count + self.expand)
		self.buffer = device.makeBuffer(bytes: vertices, length: length, options: MTLResourceOptions())!
		self.capacity = length
	}

	deinit {
		buffer.setPurgeableState(.empty)
	}

	func append(_ vertices: [T]) {
		if self.count + vertices.count < self.expand {
			let vertexArray = UnsafeMutablePointer<T>(OpaquePointer(self.buffer.contents()))
			for index in 0 ..< vertices.count {
				vertexArray[self.count + index] = vertices[index]
			}
			self.count += vertices.count
		}
		else {
			let length = self.count + vertices.count + self.expand
			let buffer = self.device.makeBuffer(length: length, options: MTLResourceOptions())
			let sourceArray = UnsafeMutablePointer<T>(OpaquePointer(self.buffer.contents()))
			let destinationArray = UnsafeMutablePointer<T>(OpaquePointer(buffer!.contents()))!
			for index in 0 ..< self.count {
				destinationArray[index] = sourceArray[index]
			}
			for index in 0 ..< vertices.count {
				destinationArray[self.count + index] = vertices[index]
			}
			self.count = self.count + vertices.count
			self.capacity = length

			self.buffer.setPurgeableState(.empty)
			self.buffer = buffer!
		}
	}

	func set(_ vertices: [T]) {
		if vertices.count < self.capacity {
			let destinationArray = UnsafeMutablePointer<T>(OpaquePointer(buffer.contents()))
			for index in 0 ..< vertices.count {
				destinationArray[index] = vertices[index]
			}
			self.count = vertices.count
		}
		else {
			let length = MemoryLayout<T>.size * (vertices.count + self.expand)
			let buffer = device.makeBuffer(bytes: vertices, length: length, options: MTLResourceOptions())
			self.count = vertices.count
			self.capacity = length
			
			self.buffer.setPurgeableState(.empty)
			self.buffer = buffer!
		}
	}

	var vertices: [T] {
		let vertexArray = UnsafeMutablePointer<T>(OpaquePointer(self.buffer.contents()))
		return (0 ..< count).map { vertexArray[$0] }
	}

}
