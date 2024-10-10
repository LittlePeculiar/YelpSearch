//
//  Copyright © 2022 Weedmaps, LLC. All rights reserved.
//

import UIKit
import WebKit


class HomeDetailViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet private weak var webView: WKWebView!
    
    var viewModel: HomeDetailViewModel?
    
    // MARK: Control
    
    func configure(with business: Business) {
        // IMPLEMENT
    }
}
