//
//	Metal2DViewController.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/10/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import GLKit


let MaxBuffers = 3
let ConstantBufferSize = 1024*1024

let vertexData:[Float] =
[
	-1.0, -1.0, 0.0, 1.0,
	-1.0,  1.0, 0.0, 1.0,
	1.0, -1.0, 0.0, 1.0,
	
	1.0, -1.0, 0.0, 1.0,
	-1.0,  1.0, 0.0, 1.0,
	1.0,  1.0, 0.0, 1.0,
	
	-0.0, 0.25, 0.0, 1.0,
	-0.25, -0.25, 0.0, 1.0,
	0.25, -0.25, 0.0, 1.0
]

let vertexColorData:[Float] =
[
	0.0, 0.0, 1.0, 1.0,
	0.0, 0.0, 1.0, 1.0,
	0.0, 0.0, 1.0, 1.0,
	
	0.0, 0.0, 1.0, 1.0,
	0.0, 0.0, 1.0, 1.0,
	0.0, 0.0, 1.0, 1.0,
	
	0.0, 0.0, 1.0, 1.0,
	0.0, 1.0, 0.0, 1.0,
	1.0, 0.0, 0.0, 1.0
]

struct Uniforms {
	var modelViewProjectionMatrix: GLKMatrix4
}

extension CGRect {

	func transform(to rect: CGRect) -> CGAffineTransform {
		var t = CGAffineTransform.identity
		t = t.translatedBy(x: -self.minX, y: -self.minY)
		t = t.scaledBy(x: 1 / self.width, y: 1 / self.height)
		t = t.scaledBy(x: rect.width, y: rect.height)
		t = t.translatedBy(x: rect.minX * self.width / rect.width, y: rect.minY * self.height / rect.height)
		return t
	}

}

extension CGAffineTransform {

	static func * (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
		return lhs.concatenating(rhs)
	}

}




extension GLKMatrix4: CustomDebugStringConvertible {

	init(transform: CATransform3D) {
		self = GLKMatrix4Make(
			Float(transform.m11), Float(transform.m12), Float(transform.m13), Float(transform.m14),
			Float(transform.m21), Float(transform.m22), Float(transform.m23), Float(transform.m24),
			Float(transform.m31), Float(transform.m32), Float(transform.m33), Float(transform.m34),
			Float(transform.m41), Float(transform.m42), Float(transform.m43), Float(transform.m44))
	}

	init(transform: CGAffineTransform) {
		let transform = CATransform3DMakeAffineTransform(transform)
		self.init(transform: transform)
	}

	static func == (lhs: GLKMatrix4, rhs: GLKMatrix4) -> Bool {
		return	lhs.m00 == rhs.m00 && lhs.m01 == rhs.m01 && lhs.m02 == rhs.m02 && lhs.m03 == rhs.m03 &&
				lhs.m10 == rhs.m10 && lhs.m11 == rhs.m11 && lhs.m12 == rhs.m12 && lhs.m13 == rhs.m13 &&
				lhs.m20 == rhs.m20 && lhs.m21 == rhs.m21 && lhs.m22 == rhs.m22 && lhs.m23 == rhs.m23 &&
				lhs.m30 == rhs.m30 && lhs.m31 == rhs.m31 && lhs.m32 == rhs.m32 && lhs.m33 == rhs.m33
	}

	static func * (lhs: GLKMatrix4, rhs: GLKMatrix4) -> GLKMatrix4 {
		return GLKMatrix4Multiply(lhs, rhs)
	}


	public var debugDescription: String {
		return "[ " +
			"\(self.m00) \(self.m01) \(self.m02) \(self.m03) ; " +
			"\(self.m10) \(self.m11) \(self.m12) \(self.m13) ; " +
			"\(self.m20) \(self.m21) \(self.m22) \(self.m23) ; " +
			"\(self.m30) \(self.m31) \(self.m32) \(self.m33) " +
		 "]"
	}
	
}


class Metal2DViewController: UIViewController, MTKViewDelegate, UIScrollViewDelegate {
	
	var device: MTLDevice! = nil
	
	var commandQueue: MTLCommandQueue! = nil
	var pipelineState: MTLRenderPipelineState! = nil
	var vertexBuffer: MTLBuffer! = nil
	var vertexColorBuffer: MTLBuffer! = nil
	var uniformsBuffer: MTLBuffer! = nil
	
	let inflightSemaphore = DispatchSemaphore(value: MaxBuffers)
	var bufferIndex = 0
	
	// offsets used in animation
	var xOffset:[Float] = [ -1.0, 1.0, -1.0 ]
	var yOffset:[Float] = [ 1.0, 0.0, -1.0 ]
	var xDelta:[Float] = [ 0.002, -0.001, 0.003 ]
	var yDelta:[Float] = [ 0.001,  0.002, -0.001 ]

	@IBOutlet weak var mtkView: MTKView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var ovalView: OvalView!
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		device = MTLCreateSystemDefaultDevice()
		guard device != nil else { // Fallback to a blank UIView, an application could also fallback to OpenGL ES here.
			print("Metal is not supported on this device")
			self.view = UIView(frame: self.view.frame)
			return
		}

		// setup view properties
		self.mtkView.device = device
		self.mtkView.delegate = self
		self.scrollView.delegate = self
		
		loadAssets()
	}
	
	func loadAssets() {
		
		// load any resources required for rendering
		//let view = self.view as! MTKView
		commandQueue = device.makeCommandQueue()
		commandQueue.label = "main command queue"
		
		let defaultLibrary = device.newDefaultLibrary()!
		let fragmentProgram = defaultLibrary.makeFunction(name: "fragment_shader")!
		let vertexProgram = defaultLibrary.makeFunction(name: "vertex_shader")!
		
		let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
		pipelineStateDescriptor.vertexFunction = vertexProgram
		pipelineStateDescriptor.fragmentFunction = fragmentProgram
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat
		pipelineStateDescriptor.sampleCount = self.mtkView.sampleCount
		
		do {
			try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
		} catch let error {
			print("Failed to create pipeline state, error \(error)")
		}
		
		// generate a large enough buffer to allow streaming vertices for 3 semaphore controlled frames
		vertexBuffer = device.makeBuffer(length: ConstantBufferSize, options: [])
		vertexBuffer.label = "vertices"
		
		let vertexColorSize = vertexData.count * MemoryLayout<Float>.size
		vertexColorBuffer = device.makeBuffer(bytes: vertexColorData, length: vertexColorSize, options: [])
		vertexColorBuffer.label = "colors"

		let transform: GLKMatrix4 = GLKMatrix4Identity
		var uniforms = Uniforms(modelViewProjectionMatrix: transform)
		uniformsBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.size, options: [])
		uniformsBuffer.label = "uniforms"
	}
	
	func update() {
		
		// vData is pointer to the MTLBuffer's Float data contents
		let pData = vertexBuffer.contents()
		let vData = (pData + 256 * bufferIndex).bindMemory(to:Float.self, capacity: 256 / MemoryLayout<Float>.stride)
		
		// reset the vertices to default before adding animated offsets
		vData.initialize(from: vertexData)
		
		// Animate triangle offsets
		let lastTriVertex = 24
		let vertexSize = 4
		for j in 0..<3 {
			// update the animation offsets
			xOffset[j] += xDelta[j]
			
			if(xOffset[j] >= 1.0 || xOffset[j] <= -1.0) {
				xDelta[j] = -xDelta[j]
				xOffset[j] += xDelta[j]
			}
			
			yOffset[j] += yDelta[j]
			
			if(yOffset[j] >= 1.0 || yOffset[j] <= -1.0) {
				yDelta[j] = -yDelta[j]
				yOffset[j] += yDelta[j]
			}
			
			// Update last triangle position with updated animated offsets
			let pos = lastTriVertex + j*vertexSize
			vData[pos] = xOffset[j]
			vData[pos+1] = yOffset[j]
		}
	}

	func draw(in view: MTKView) {
		
		// use semaphore to encode 3 frames ahead
		let _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)
		
		self.update()

		let uniformPtr = UnsafeMutablePointer<Uniforms>(OpaquePointer(uniformsBuffer.contents()))

		let method = 1
		switch method {
		case 0:
			// (case1) somehow this code not working -- any idea?
			let targetRect = self.contentView.convert(self.contentView.bounds, to: self.mtkView)
			var t1 = self.mtkView.bounds.transform(to: targetRect)
			uniformPtr.pointee.modelViewProjectionMatrix = GLKMatrix4(transform: t1)
		case 1:
			// (case2) compute transform from UIScrollView's contentOffset and zoomScale -- not quite right
			var transform = CGAffineTransform.identity
			let offsetX = self.scrollView.contentOffset.x / (self.mtkView.bounds.width * 2.0)
			let offsetY = self.scrollView.contentOffset.y / (self.mtkView.bounds.height * 2.0)
			transform = transform.translatedBy(x: -offsetX, y: -offsetY)
			transform = transform.scaledBy(x: self.scrollView.zoomScale, y: self.scrollView.zoomScale)
			uniformPtr.pointee.modelViewProjectionMatrix = GLKMatrix4(transform: transform)
		case 2:
			// (case3) only scaling -- scaling looks OK, but no scrolling
			let scale = scrollView.zoomScale
			let transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
			uniformPtr.pointee.modelViewProjectionMatrix = GLKMatrix4(transform: transform)
		default:
			break
		}

		let commandBuffer = commandQueue.makeCommandBuffer()
		commandBuffer.label = "Frame command buffer"
		
		// use completion handler to signal the semaphore when this frame is completed allowing the encoding of the next frame to proceed
		// use capture list to avoid any retain cycles if the command buffer gets retained anywhere besides this stack frame
		commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
			if let strongSelf = self {
				strongSelf.inflightSemaphore.signal()
			}
			return
		}
		
		if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {
			let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
			renderEncoder.label = "render encoder"
			
			renderEncoder.pushDebugGroup("draw morphing triangle")
			renderEncoder.setRenderPipelineState(pipelineState)
			renderEncoder.setVertexBuffer(vertexBuffer, offset: 256*bufferIndex, at: 0)
			renderEncoder.setVertexBuffer(vertexColorBuffer, offset:0 , at: 1)
			renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 2)
			renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 9, instanceCount: 1)
			
			renderEncoder.popDebugGroup()
			renderEncoder.endEncoding()
				
			commandBuffer.present(currentDrawable)
		}
		
		// bufferIndex matches the current semaphore controled frame index to ensure writing occurs at the correct region in the vertex buffer
		bufferIndex = (bufferIndex + 1) % MaxBuffers
		
		commandBuffer.commit()
	}
	
	
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		
	}

	// MARK: -

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.contentView
	}

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.ovalView.setNeedsDisplay()
		print("zoom=\(self.scrollView.zoomScale), offset=\(self.scrollView.contentOffset), contentSize=\(self.scrollView.contentSize), inset=\(self.scrollView.contentInset)")
	}

	public func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.ovalView.setNeedsDisplay()
	}

}
