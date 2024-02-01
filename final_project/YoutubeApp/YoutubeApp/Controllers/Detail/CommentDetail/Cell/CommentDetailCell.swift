//
//  CommentDetailCell.swift
//  YoutubeApp
//
//  Created by Admin on 15/01/2024.
//

import UIKit
protocol CommentDetailCellDelegate: AnyObject {
    func didTapReadMoreButton(_ cell: CommentDetailCell)
    func didTapReplyDetail(_ cell: CommentDetailCell, comment: Comment)
}
class CommentDetailCell: UITableViewCell {
    
    weak var delegate: CommentDetailCellDelegate?
    var buttonReadMoreClicked: (() -> (Void))!
    var ReplyDetailCliked: (() -> (Void))!
    var expandedcell:IndexSet = []
    
    @IBOutlet weak var avatarAuthorImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var authorCommentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var totalReplyLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var replyAreaView: UIView!
    
    @IBAction func readMoreAction(_ sender: Any) {
        buttonReadMoreClicked()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarAuthorImageView.makeRounded()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapReplyAreaAction(_:)))
        replyAreaView.addGestureRecognizer(tapGesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
    @objc func tapReplyAreaAction(_ gesture: UITapGestureRecognizer) {
        print("OK")
        ReplyDetailCliked()
    }
}

extension CommentDetailCell {
    func configureCell(with comment: Comment, isExpanded: Bool, delegate: CommentDetailCellDelegate?) {
        authorNameLabel.text = comment.authorDisplayName + " ⦁ " + comment.publishedAt.timeAgoSinceDate()
        authorCommentLabel.text = comment.textOriginal
        likeCountLabel.text = String(comment.likeCount)
        
        if comment.totalReplyCount != 0 {
            totalReplyLabel.isHidden = false
            totalReplyLabel.text = String(comment.totalReplyCount) + " replies"
        } else {
            totalReplyLabel.isHidden = true
        }
        
        setThumbnail(for: avatarAuthorImageView, with: comment.authorProfileImageUrl) { image in
            if let image = image {
                self.avatarAuthorImageView.image = image
            }
        }
        
        if isExpanded {
            authorCommentLabel.numberOfLines = 0
            readMoreButton.isHidden = true
        } else {
            authorCommentLabel.numberOfLines = 3
            readMoreButton.isHidden = !isTextLongerThanThreeLines(text: comment.textOriginal, label: authorCommentLabel)
        }
        
        buttonReadMoreClicked = {
            delegate?.didTapReadMoreButton(self)
        }
        
        if comment.totalReplyCount > 0 {
            replyAreaView.isHidden = false
            totalReplyLabel.text = String(comment.totalReplyCount) + " replies"
            ReplyDetailCliked = {
                delegate?.didTapReplyDetail(self, comment: comment)
            }
        } else {
            replyAreaView.isHidden = true
        }
    }
    
    func configureCellForReply(with comment: Reply, isExpanded: Bool, delegate: CommentDetailCellDelegate?) {
        authorNameLabel.text = comment.authorDisplayName + " ⦁ " + comment.publishedAt.timeAgoSinceDate()
        authorCommentLabel.text = comment.textDisplay
        likeCountLabel.text = String(comment.likeCount)
        
        replyAreaView.isHidden = true
        
        setThumbnail(for: avatarAuthorImageView, with: comment.authorProfileImageUrl) { image in
            if let image = image {
                self.avatarAuthorImageView.image = image
            }
        }
        
        if isExpanded {
            authorCommentLabel.numberOfLines = 0
            readMoreButton.isHidden = true
        } else {
            authorCommentLabel.numberOfLines = 3
            readMoreButton.isHidden = !isTextLongerThanThreeLines(text: comment.textDisplay, label: authorCommentLabel)
        }
        
        buttonReadMoreClicked = {
            delegate?.didTapReadMoreButton(self)
        }
        
    }
    private func setThumbnail(for imageView: UIImageView, with url: String, completion: @escaping (UIImage?) -> Void) {
        var cachedImage: UIImage?
        if let existingImage = cachedImage {
            imageView.image = existingImage
            completion(existingImage)
        } else {
            imageView.image = nil
            API.shared().downloadImage(with: url) { (image) in
                if let image = image {
                    imageView.image = image
                    cachedImage = image
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func isTextLongerThanThreeLines(text: String, label: UILabel) -> Bool {
        let size = CGSize(width: label.bounds.width, height: CGFloat.infinity)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let attributes = [NSAttributedString.Key.font: label.font!]
        let textRect = text.boundingRect(with: size, options: options, attributes: attributes, context: nil)
        let lineHeight = label.font.lineHeight
        return textRect.height > lineHeight * 3
    }
}
