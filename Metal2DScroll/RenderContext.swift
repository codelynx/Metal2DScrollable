//
//	RenderContext.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import Foundation
import MetalKit
import GLKit


//
//	RenderContext
//

struct RenderContext {
	let commandEncoder: MTLRenderCommandEncoder
	let transform: GLKMatrix4
	var device: MTLDevice { return commandEncoder.device }
}

