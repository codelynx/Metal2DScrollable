//
//	UIView+Z.swift
//	ZKit
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import UIKit


extension UIView {

	func transform(to view: UIView) -> CGAffineTransform {
		let targetRect = self.convert(self.bounds, to: view)
		return view.bounds.transform(to: targetRect)
	}

	func addSubviewToFit(_ view: UIView) {
		view.frame = self.bounds
		self.addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		view.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
	}

	func setBorder(color: UIColor?, width: CGFloat) {
		self.layer.borderWidth = width
		self.layer.borderColor = color?.cgColor
	}

}
