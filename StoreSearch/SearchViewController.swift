//
//  ViewController.swift
//  StoreSearch
//
//  Created by Adam Reed on 4/13/21.
//

import UIKit

class SearchViewController: UIViewController {

    // Additional Options for after view loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // Variables connected to storyboard
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Global Variables for project
    var searchResults = [SearchResult]()
    var userHasSearched = false
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      searchResults = []
        
    if searchBar.text! != "Justin" {
        
    // Fake Search Result to populate queries with data
      for i in 0...2 {
        let searchResult = SearchResult()
        searchResult.name = "Fake search result for \(searchResult.name)"
        searchResult.artistName = "\(searchBar.text!)"
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

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Update the number of rows in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    // Update what the cell inside of a specific row looks like
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
            // Check if cell is empty, if yes then create a default cell to work with
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            }
            // check if data array is empty, and if user has searched yet, display following
            if searchResults.count == 0 && userHasSearched == false {
                cell.detailTextLabel?.text = ""
            // If Data array is empty after search display following
            } else if searchResults.count == 0 {
                cell.textLabel!.text = "Nothing Found"
            // If data array has objects then show me the money!
            } else {
                let searchResult = searchResults[indexPath.row]
                cell.textLabel!.text = searchResult.name
                cell.detailTextLabel?.text = searchResult.artistName
            }
        return cell
    }
    
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
