//
//  RecentCollectionViewCell.swift
//  YoutubeApp
//
//  Created by Admin on 16/01/2024.
//

import UIKit

class RecentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var recentImageView: UIImageView!
    @IBOutlet weak var recentTitleLabel: UILabel!
    @IBOutlet weak var recentDurationLabel: UILabel!
    @IBOutlet weak var recentChannelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(indexPath: IndexPath, viewModel: ProfileViewModel) {
        let item = viewModel.dataVideos[indexPath.row]
        
        recentTitleLabel.text = item.title
        recentChannelLabel.text = item.channelTitle
        
        if let thumbnailImageData = item.thumbnailImageData {
            recentImageView.image = UIImage(data: thumbnailImageData)
        } else {
            recentImageView.image = UIImage(named: "defaultImage")
        }
    }
}

