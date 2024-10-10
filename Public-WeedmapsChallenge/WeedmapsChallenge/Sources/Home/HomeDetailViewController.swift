//
//  Copyright © 2022 Weedmaps, LLC. All rights reserved.
//

import UIKit
import WebKit
import Combine


class HomeDetailViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: HomeDetailViewModel?
    private var disposeBag = [AnyCancellable]()
    private var isLoading: Bool = false {
        didSet {
            refreshActivityIndicator()
        }
    }
    
    // MARK: Control
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBinding()
        setupUI()
    }
    
    private func setupBinding() {
        guard let vm = viewModel else { return }
        self.isLoading = true
        vm.$business
            .receive(on: DispatchQueue.main)
            .sink { [weak self] business in
                guard let self = self else { return }
                self.openWebKit(business: business)
            }
            .store(in: &disposeBag)
    }
    
    private func setupUI() {
        self.title = viewModel?.business.name ?? "Business Details"
        self.view.backgroundColor = UIColor.red
        webView.isHidden = true
    }
    
    private func openWebKit(business: Business) {
        guard let urlString = business.url, let url = URL(string: urlString) else {
            showAlert(message: "Unable to load website for:\n\(business.name)")
            return
        }
        print("opening web: \(url)")
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        self.webView.load(URLRequest(url: url))
    }
    
    private func refreshActivityIndicator() {
        view.bringSubviewToFront(activityIndicator)
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func showAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        webView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        let title = "Oops! Something went wrong!"
        showAlert(title: title, message: error.localizedDescription)
    }
}
