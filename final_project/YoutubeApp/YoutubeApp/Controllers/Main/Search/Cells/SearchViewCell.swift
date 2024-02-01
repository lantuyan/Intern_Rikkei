//
//  SearchViewCell.swift
//  YoutubeApp
//
//  Created by Admin on 11/01/2024.
//

import UIKit

class SearchViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var avatarChannelImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarChannelImageView.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(_ cell: SearchViewCell, at indexPath: IndexPath, viewModel: SearchViewModel) {
        var videoItem = viewModel.videos[indexPath.row]
        
        let channelTitle = videoItem.channelTitle
        let time = videoItem.publishedAt.timeAgoSinceDate()
        let description = "\(channelTitle) • \(time)"
        
        cell.titleLabel.text = videoItem.title
        cell.descriptionLabel.text = description
        cell.thumbnailImageView.image = videoItem.thumbnailImage
        cell.avatarChannelImageView.image = videoItem.channelImage
    }
}

// MARK: - Helper setup TableviewCell Content
extension SearchViewCell {
}
