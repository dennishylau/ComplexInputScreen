//
//  UIResponder.swift
//  ComplexInputScreen
//
//  Created by Dennis Lau on 2017-12-12.
//  Copyright © 2017 Dennis Lau. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	func currentFirstResponder() -> UIResponder? {
		if self.isFirstResponder {
			return self
		}
		for view in self.subviews {
			if let responder = view.currentFirstResponder() {
				return responder
			}
		}
		return nil
	}
}
