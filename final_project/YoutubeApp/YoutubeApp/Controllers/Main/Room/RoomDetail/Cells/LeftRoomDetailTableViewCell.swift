//
//  LeftRoomDetailTableViewCell.swift
//  YoutubeApp
//
//  Created by Admin on 30/01/2024.
//

import UIKit

class LeftRoomDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var uiViewMessage: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupMessageLabel()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(_ cell: LeftRoomDetailTableViewCell, at indexPath: IndexPath, viewModel: RoomDetailViewModel) {
        let item = viewModel.messages[indexPath.row]
        messageLabel.text =  item.message
        avatarImage.makeRounded()
        avatarImage.image = item.avatarImage
        
//        // Calculate the minimum width (0.3 times screen width)
            let minimumWidth = UIScreen.main.bounds.width * 0.3
//            
//            // Set the width constraint for uiViewMessage
//            let widthConstraint = uiViewMessage.widthAnchor.constraint(equalToConstant: max(messageLabel.intrinsicContentSize.width, minimumWidth))
//            widthConstraint.isActive = true
    }
    
    func setupMessageLabel() {
        uiViewMessage.layer.cornerRadius = 12
        let widthConstraint = uiViewMessage.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant: 16)
        widthConstraint.isActive = true
        
        uiViewMessage.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = ""
    }
    
}
