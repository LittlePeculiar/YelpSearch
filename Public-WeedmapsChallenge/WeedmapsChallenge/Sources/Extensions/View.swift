//
//  View.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/9/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import UIKit

extension UIView {
    
    func addShadow(
        shadowColor: UIColor = .black,
        offSet: CGSize = CGSize(width: 0.5, height: 1),
        opacity: Float = 0.2,
        shadowRadius: CGFloat = 2.0,
        cornerRadius: CGFloat = 20,
        corners: UIRectCorner = .allCorners,
        fillColor: UIColor = .white
    ) {
        
        let shadowLayer = CAShapeLayer()
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath
        shadowLayer.path = cgPath
        shadowLayer.fillColor = fillColor.cgColor
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowPath = cgPath
        shadowLayer.shadowOffset = offSet
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
}
