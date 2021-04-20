//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Adam Reed on 4/14/21.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    // MARK: Variables
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    var downloadTask: URLSessionDownloadTask? = nil

    // MARK: Customize Cell
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
        selectedBackgroundView = selectedView
    }
    
    // MARK: Functions
    // Configure the cell when loaded into the table view
    func configure(for result: SearchResult) {
        nameLabel.text = result.name
        
        if result.artist.isEmpty {
            artistNameLabel.text = ""
        } else {
            artistNameLabel.text = "\(result.artist), (\(result.type))"
        }
        
        artworkImageView.image = UIImage(systemName: "square")
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        print("Cancelled Image Download")
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
    
}
