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
        setupUI()
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
        viewModel.$displayBusinesses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] businesses in
                if businesses.isEmpty {
                    let message = "No results found\nPlease try your search again"
                    self?.showAlert(message: message)
                }
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
        self.title = "Weedmap Challenge"
        self.view.backgroundColor = UIColor.red
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by Term..."
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
            let title = "Oops! Something went wrong!"
            let message = "please try again later"
            showAlert(title: title, message: message)
        }
    }
    
    private func showAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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
        viewModel.displayBusinesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                 withIdentifier: "BusinessCell",
                 for: indexPath
              ) as? BusinessCell else { return UITableViewCell() }
        
        cell.delegate = self
        
        let business = viewModel.displayBusinesses[indexPath.row]
        cell.configure(api: viewModel.api, business: business)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let business = viewModel.displayBusinesses[indexPath.row]
        print("selecting: \(business.name)")
    }
    
    
}

// MARK: UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.resetDisplayData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let term = self.searchController.searchBar.text else { return }
        guard term.count > 2 else {
            let message = "Please enter at least 3 chars to begin search"
            showAlert(title: title, message: message)
            self.showAlert(message: message)
            return
        }
        Task {
            await viewModel.fetch(term)
        }

    }
    
    //This is when the user clicks the 'x' button in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            viewModel.resetDisplayData()
        }
        
    }
    
}

extension HomeViewController: BusinessCellDelegate {
    func calling(number: String) {
        guard let url = URL(string: "tel://\(number)"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
