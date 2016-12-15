//
//	CanvasViewController.swift
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController {

	@IBOutlet weak var renderView: RenderView!

	var canvasScene: CanvasScene?

	override func viewDidLoad() {
		assert(renderView != nil)
		super.viewDidLoad()
		let device = self.renderView.device
		self.canvasScene = CanvasScene(device: device, contentSize: CGSize(width: 2048, height: 1024))
		self.renderView.renderableScene = self.canvasScene
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}
