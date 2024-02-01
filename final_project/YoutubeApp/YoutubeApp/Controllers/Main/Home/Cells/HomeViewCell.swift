//
//  HomeViewCell.swift
//  YoutubeApp
//
//  Created by Admin on 05/01/2024.
//

import UIKit

class HomeViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var avatarChannelImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        avatarChannelImageView.makeRounded()
    }
    
    func configureCell(indexPath: IndexPath, viewModel: HomeViewModel) {
        var item = viewModel.videos[indexPath.row]
        titleLabel.text = item.title
        descriptionLabel.text = generateDescription(for: item)
        timeLabel.text = item.duration.getYoutubeFormattedDuration()
        thumbnailImageView.image = item.thumbnailImage
        avatarChannelImageView.image = item.channelImage
    }
}

// MARK: - Helper method TableViewCell Content
extension HomeViewCell {
    private func generateDescription(for video: Video) -> String {
        let channelTitle = video.channelTitle
        let viewCount = String(video.viewCount).formattedViews()
        let timeAgo = video.publishedAt.timeAgoSinceDate()
        return "\(channelTitle) • \(viewCount) • \(timeAgo)"
    }
    
}
