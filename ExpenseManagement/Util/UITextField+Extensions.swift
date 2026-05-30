//
//  UITextField+Extensions.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 22/02/26.
//

import UIKit

extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = paddingView
        leftViewMode = .always
    }
    
    func setRightPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        rightView = paddingView
        rightViewMode = .always
    }
}
