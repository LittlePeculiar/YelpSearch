//
//  TableViewCell.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var cellId: String {
        String(describing: self)
    }
    
    static func registerWith(tableView: UITableView) {
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
}
