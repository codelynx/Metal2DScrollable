//
//	CoreGraphics+Z.swift
//	ZKit
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import CoreGraphics


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
