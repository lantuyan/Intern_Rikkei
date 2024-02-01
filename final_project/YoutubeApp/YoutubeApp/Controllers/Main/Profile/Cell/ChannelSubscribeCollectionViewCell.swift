//
//  ChannelSubscribeCollectionViewCell.swift
//  YoutubeApp
//
//  Created by Admin on 16/01/2024.
//

import UIKit

class ChannelSubscribeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarChannelImage: UIImageView!
    @IBOutlet weak var titleChannelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarChannelImage.makeRounded()
    }
    
    func configureCell(indexPath: IndexPath, viewModel: ProfileViewModel) {
        let item = viewModel.subscriptions[indexPath.row]
        titleChannelLabel.text = item.title
        avatarChannelImage.image = item.thumbnailImage
    }
}
