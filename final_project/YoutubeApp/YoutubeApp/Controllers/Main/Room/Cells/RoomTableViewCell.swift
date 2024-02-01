//
//  RoomTableViewCell.swift
//  YoutubeApp
//
//  Created by Admin on 29/01/2024.
//

import UIKit

class RoomTableViewCell: UITableViewCell {

    @IBOutlet weak var roomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(_ cell: RoomTableViewCell, at indexPath: IndexPath, viewModel: RoomViewModel) {
        let videoItem = viewModel.allRooms[indexPath.row]
        roomLabel.text = "Room: " + String(videoItem.roomId)
    }
}
