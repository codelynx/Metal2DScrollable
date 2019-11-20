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
import simd

//
//	RenderContext
//

struct RenderContext {
	let commandEncoder: MTLRenderCommandEncoder
	let transform: simd_float4x4
	var device: MTLDevice { return commandEncoder.device }
}

