//
//  String.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/9/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import Foundation

extension String {
    func formatPhoneNumber() -> String {
        let cleanNumber = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        let mask = "+X (XXX) XXX-XXXX"
        
        var result = ""
        var startIndex = cleanNumber.startIndex
        let endIndex = cleanNumber.endIndex
        
        for char in mask where startIndex < endIndex {
            if char == "X" {
                result.append(cleanNumber[startIndex])
                startIndex = cleanNumber.index(after: startIndex)
            } else {
                result.append(char)
            }
        }
        
        return result
    }
}
