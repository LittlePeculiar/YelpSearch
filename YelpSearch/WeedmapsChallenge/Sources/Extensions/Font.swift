//
//  Font.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import UIKit

extension UIFont {
    static func preferredFont(
        forTextStyle style: TextStyle,
        weight: Weight,
        maxSize: CGFloat? = nil
    ) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: style)
        let size = maxSize != nil ? min(font.pointSize, maxSize!) : font.pointSize
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
