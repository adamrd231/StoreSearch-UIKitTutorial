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
        
        // Create and register SearchResultCell Nib
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        // Create and register NothingFoundCell Nib
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        // Adjust UI for tableview on main controller
        tableView.rowHeight = 80
        // Open the searchbar right away
        searchBar.becomeFirstResponder()
    }

    //: MARK: Variables
    // Variables connected to storyboard
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Global Variables for project
    var searchResults = [SearchResult]()
    var userHasSearched = false
    
    // Constants for cell identifiers
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }
    
}


// MARK: SearchBar View Controller
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      searchResults = []
        
    if searchBar.text! != "Justin" {
    // Fake Search Result to populate queries with data
      for i in 0...2 {
        let searchResult = SearchResult()
        searchResult.name = "Fake search result for \(i)"
        searchResult.artistName = "Search bar result: \(searchBar.text!)"
        searchResults.append(searchResult)
      }
    }
        userHasSearched = true
        tableView.reloadData()
        searchBar.resignFirstResponder()
}
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}


// MARK: Table View Controller
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Update the number of rows in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !userHasSearched {
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
      if searchResults.count == 0 {
        return tableView.dequeueReusableCell(
          withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
          for: indexPath)
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier:
          TableView.CellIdentifiers.searchResultCell,
          for: indexPath) as! SearchResultCell

        let searchResult = searchResults[indexPath.row]
        cell.nameLabel.text = searchResult.name
        cell.artistNameLabel.text = searchResult.artistName
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
      if searchResults.count == 0 {
        return nil
      } else {
        return indexPath
      }
    }

    
    
}
