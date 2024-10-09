//
//  Copyright © 2022 Weedmaps, LLC. All rights reserved.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var searchController = UISearchController(searchResultsController: nil)
    private let viewModel = HomeViewModel()
    private var disposeBag = [AnyCancellable]()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        setupBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            await viewModel.getCurrentLocation()
        }
    }
    
    private func registerCells() {
        BusinessCell.registerWith(tableView: tableView)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func setupBinding() {
        viewModel.$businesses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &disposeBag)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.refreshActivityIndicator(isLoading: isLoading)
            }
            .store(in: &disposeBag)
        
        viewModel.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isError in
                self?.showError(isError: isError)
            }
            .store(in: &disposeBag)
    }
    
    private func setupUI() {
        self.view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
    }
    
    private func refreshActivityIndicator(isLoading: Bool) {
        view.bringSubviewToFront(activityIndicator)
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func showError(isError: Bool) {
        if isError {
            // show alert
        }
    }
    
}

// MARK: UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        // IMPLEMENT: Be sure to consider things like network errors
        // and possible rate limiting from the Yelp API. If the user types
        // very quickly, how will you prevent unnecessary requests from firing
        // off?
    }
}

// MARK: UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // IMPLEMENT:
        // Present the user with a UIAlertController (action sheet style) with options
        // to either display the Business's Yelp page in a WebView OR bump the user out to
        // Safari. Both options should display the Business's Yelp page details
    }
}

// MARK: - Table view data source
// note: using tableview instead of collectionview per figma

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.businesses.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
