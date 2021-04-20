//
//  ViewController.swift
//  StoreSearch
//
//  Created by Adam Reed on 4/13/21.
//

import UIKit

// MARK: Main - Search View Controller
class SearchViewController: UIViewController {

    // Additional Options for after view loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust UI for tableview on main controller
        tableView.rowHeight = 80
        // Open the searchbar right away
        searchBar.becomeFirstResponder()
        
        // MARK: Custom Cell Nibs
        // Create and register SearchResultCell Nib
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        // Create and register NothingFoundCell Nib
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        // Create and register Loading Cell Nib
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        
        
    }

    // MARK: Variables
    // Variables connected to storyboard
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: Outlets
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
        print("Changed segmented controller to \(sender.selectedSegmentIndex)")
    }
    
    
    
    var dataTask: URLSessionDataTask?
    
    
    // Global Variables for project
    var searchResults = [SearchResult]()
    var userHasSearched = false
    var isLoading = false
    
    // Constants for cell identifiers
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    // MARK: Helper Functions
    func iTunesURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category {
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""
        }
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?term=\(encodedText)&limit=100&entity=\(kind)"
        let url = URL(string: urlString)
        return url!
    }
    
    
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    
    func showNetworkError() {
        let alert = UIAlertController(
            title:"Whoops...",
            message: "There was an error accessing iTunes server" + "\nPlease Try Again",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    

}


// MARK: SearchBar View Controller
extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        if !searchBar.text!.isEmpty {
            // Close text input
            searchBar.resignFirstResponder()
            // Mark if user has searched or not
            userHasSearched = true
            // Cancel any current searches before starting the next one
            dataTask?.cancel()
            // Update is Loading Variable
            isLoading = true
            // Clear the search results array for new searching
            searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            let session = URLSession.shared
            
            // Completion Handler for gathering data
            dataTask = session.dataTask(with: url) {data, response, error in
                if let error = error as NSError?, error.code == -999 {
                    print("Search was cancelled")
                    return
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data {
                        self.searchResults = self.parse(data: data)
                        self.searchResults.sort(by: <)
                        
                        // Use the main thread to update UI
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        
                        return
                    }
                } else {
                    // Update the UI if errors occured
                    DispatchQueue.main.async {
                      self.userHasSearched = false
                      self.isLoading = false
                      self.tableView.reloadData()
                      self.showNetworkError()
                    }
                }
                
            }
            
            dataTask?.resume()
        }
        
        
        
        
        
}
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}


// MARK: Table View Controller
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Update the number of rows in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !userHasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    // Update what the cell inside of a specific row looks like
    func tableView(
      _ tableView: UITableView,
      cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        // If search has no results, display (Nothing Found Cell)
        } else if searchResults.count == 0 {
        return tableView.dequeueReusableCell(
          withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
          for: indexPath)
      } else {
        // Otherwise display results with (Seach Result Cell)
        let cell = tableView.dequeueReusableCell(withIdentifier:
          TableView.CellIdentifiers.searchResultCell,
          for: indexPath) as! SearchResultCell
        
        // Pull up the current searchResult Cell to modify
        let searchResult = searchResults[indexPath.row]
        // Configure current cell with function in SearchResult.Swift
        cell.configure(for: searchResult)
        return cell
      }
    }

    // Update how the tableview will handle selections
    func tableView(
      _ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath
    ) {
      tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(
      _ tableView: UITableView,
      willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
      if searchResults.count == 0 || isLoading {
        return nil
      } else {
        return indexPath
      }
    }

    
    
}
