//
//  RoomCollectionViewCell.swift
//  YoutubeApp
//
//  Created by Admin on 30/01/2024.
//

import UIKit

class RoomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var uiViewLabel: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiViewLabel.layer.cornerRadius = 12
    }
    
    func configureCell(_ cell: RoomCollectionViewCell, at indexPath: IndexPath, viewModel: RoomViewModel) {
        let videoItem = viewModel.allRooms[indexPath.row]
        roomLabel.text = "Room: " + String(videoItem.roomId)
    }
}
