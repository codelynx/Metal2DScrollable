//
//  CanvasViewController.swift
//  Metal2DScroll
//
//  Created by Kaz Yoshikawa on 12/12/16.
//  Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController {

	@IBOutlet weak var renderableView: RenderableView!

	var canvasScene: CanvasScene!

	override func viewDidLoad() {
		assert(renderableView != nil)
		super.viewDidLoad()
		self.canvasScene = CanvasScene(contentSize: CGSize(width: 2048, height: 1024))
		self.renderableView.renderableScene = self.canvasScene
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}
