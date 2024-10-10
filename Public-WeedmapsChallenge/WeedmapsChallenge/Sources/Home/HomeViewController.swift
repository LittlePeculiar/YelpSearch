//
//  Copyright © 2022 Weedmaps, LLC. All rights reserved.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var searchController = UISearchController(searchResultsController: nil)
    private let viewModel = HomeViewModel()
    private var disposeBag = [AnyCancellable]()
    private var isSearching: Bool {
        let text = self.searchController.searchBar.text ?? ""
        return self.searchController.isActive && !text.isEmpty
    }
    private var searchTerm: String {
        let text = self.searchController.searchBar.text ?? ""
        return text
    }
    
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
                guard let self = self else { return }
                
                let searching = self.isSearching
                self.tableView.reloadData()
                
                if businesses.isEmpty {
                    if searching {
                        let message = "No results found\nPlease try your search again"
                        self.showAlert(message: message)
                    }
                }
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
        self.title = "Weedmaps"
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
        // error from api
        if isError {
            let title = "Oops! Something went wrong!"
            let message = viewModel.errorMessage
            showAlert(title: title, message: message)
        }
    }
    
    private func showAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showDetailAlert(business: Business) {
        let alert = UIAlertController(
            title: "Visit Site",
            message: "Please select how you would like to view site details",
            preferredStyle: .actionSheet
        )
        
        // WKWebView
        let inApp = UIAlertAction(title: "Stay In App", style: .default) {  [weak self] (_) in
            self?.loadWebDetails(business: business)
        }
        alert.addAction(inApp)
        
        // Safari.
        let safari = UIAlertAction(title: "Use Safari", style: .default) {  [weak self] (_) in
            self?.openSafari(business: business)
        }
        alert.addAction(safari)
        
        //Cancel
        let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func loadWebDetails(business: Business) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "HomeDetailViewController") as? HomeDetailViewController else { return }
        
        vc.viewModel = HomeDetailViewModel(business: business)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openSafari(business: Business) {
        guard let urlString = business.url, let url = URL(string: urlString) else {
            showAlert(message: "Unable to load website for:\n\(business.name)")
            return
        }
        UIApplication.shared.open(url)
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
        showDetailAlert(business: business)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            viewModel.offset = viewModel.displayBusinesses.count
            print("we hit the bottom at: \(indexPath)")
            
            Task {
                // todo: fix flash when new records are loaded
                self.view.endEditing(true)
                await viewModel.fetch(searchTerm)
            }
        }
    }
    
}

// MARK: UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        // do not want to call api for each char
        // will wait for search button tapped
//        guard let term = searchController.searchBar.text else { return }
    }
}

// MARK: UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.resetDisplayData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchTerm.count > 2 else {
            let message = "Please enter at least 3 chars to begin search"
            showAlert(message: message)
            return
        }
        
        // only do search when search button is tapped
        Task {
            self.view.endEditing(true)
            viewModel.offset = 0
            await viewModel.fetch(searchTerm)
        }
    }
    
    //This is when the user clicks the 'x' button in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.view.endEditing(true)
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
