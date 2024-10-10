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
    
    private func registerCells() {
        BusinessCell.registerWith(tableView: tableView)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        
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

// MARK: - Table view data source
// note: using tableview instead of collectionview - better fits figma design

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.businesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                 withIdentifier: "BusinessCell",
                 for: indexPath
              ) as? BusinessCell else { return UITableViewCell() }
        
        cell.delegate = self
        
        let business = viewModel.businesses[indexPath.row]
        cell.configure(api: viewModel.api, business: business)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let business = viewModel.businesses[indexPath.row]
        print("selecting: \(business.name)")
    }
    
    
}

extension HomeViewController: BusinessCellDelegate {
    func calling(number: String) {
        print("todo: calling \(number)")
    }
    
    
}
