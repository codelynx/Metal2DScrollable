//
//	Renderable.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//


import Foundation
import MetalKit


protocol Renderable {

	associatedtype RendererType

	func render(context: RenderContext)

}
