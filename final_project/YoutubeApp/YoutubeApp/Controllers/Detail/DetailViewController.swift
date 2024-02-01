//
//  HomeDetailViewController.swift
//  YoutubeApp
//
//  Created by Admin on 12/01/2024.
//

import UIKit
import youtube_ios_player_helper
import FloatingPanel

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    let viewModel = DetailViewModel()
    var fpc: FloatingPanelController!
    
    // MARK: - Outlets
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var disLikeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var disLikeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var streamButton: UIButton!
    @IBOutlet weak var streamLabel: UILabel!
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var subcribeCountLabel: UILabel!
    @IBOutlet weak var subcribeLabel: UILabel!
    @IBOutlet weak var commentTitleLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var topCommentLabel: UILabel!
    @IBOutlet weak var topCommentImageView: UIImageView!
    
    // MARK: - Actions
    @IBAction func likeButtonAction(_ sender: Any) {
        handleRatingButtonAction(with: "like")
    }
    
    @IBAction func disLikeButtonAction(_ sender: Any) {
        handleRatingButtonAction(with: "dislike")
    }
    @IBAction func saveButtonAction(_ sender: Any) {
        handleSaveButtonAction()
    }
    @IBAction func StreamButtonAction(_ sender: Any) {
        AlertManager.shared.showPasswordInputDialog(on: self) { [weak self] enteredPassword in
            guard let enteredPassword = enteredPassword else {
                return
            }
            
            let roomVC = RoomDetailViewController()
            roomVC.viewModel.videoId = self?.viewModel.video?.videoId ?? ""
            roomVC.viewModel.password = enteredPassword
            roomVC.createRoom()
            
            self?.navigationController?.pushViewController(roomVC, animated: true)
        }
    }
    @IBAction func shareButtonAction(_ sender: Any) {
        AlertManager.shared.showAlertMessage(viewController: self)
    }
    
    
    @IBAction func tapViewCommentAction(_ sender: UITapGestureRecognizer) {
        presentCommentDetailViewController()
    }
    
    @IBAction func tapSubcribeAction(_ sender: UITapGestureRecognizer) {
        print("OK")
        handleSubcriptionButton()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        loadAPI()
        layout()
        setupFloatingPanel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Initial Setup
    private func initializeUI() {
        hideAllComponents()
    }
    
    private func hideAllComponents() {
        let components: [UIView] = [
            titleLabel, descriptionLabel, likeLabel, disLikeLabel,
            likeButton, disLikeButton, saveButton, saveLabel,
            shareButton, shareLabel, streamButton, streamLabel,
            channelImageView, channelTitleLabel, subcribeCountLabel,
            subcribeLabel, commentTitleLabel, commentCountLabel,
            topCommentLabel, topCommentImageView
        ]
        
        components.forEach { $0.isHidden = true }
    }
    
    private func setupFloatingPanel() {
        fpc = FloatingPanelController(delegate: self)
        fpc.delegate = self
        fpc.contentMode = .fitToBounds
        fpc.layout = MyFloatingPanelLayout()
        fpc.isRemovalInteractionEnabled = true
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        playerView.delegate = self
    }
    
    // MARK: - API Calls
    private func loadAPI() {
        IndicatorLoader.shared.showActivityIndicator(on: self.view)
        viewModel.loadVideoAPI { [weak self] done, msg in
            guard let self = self else {
                print("Self is nil. Unable to load API.")
                return
            }

            guard done else {
                print("API Load Video Error")
                ErrorMessageManager.shared.showErrorMessage("API Error, can't load this video", on: self.playerView, scrollView: nil)
                return
            }

            print("API load Video ok")

            if let video = self.viewModel.video {
                self.updateUI(with: video)
                self.viewModel.addVideo()
                self.checkSaveButton()

                self.viewModel.loadSubscriptionStatus { done, msg in
                    if done {
                        print("API load Subscription ok")
                        print("Subscribe: ", self.viewModel.isSubcribe)
                        self.updateSubcribeLabel()
                    } else {
                        print("API load Subscription fail")
                    }
                }
            }
        }
        
        viewModel.loadRatingVideoAPI { [weak self] done, msg in
            guard let self = self, done else {
                print("API Load Rating Error")
                return
            }
            print("API load Rating ok")
            print("Rating of video: ", self.viewModel.rating)
            self.updateRatingButtons()
        }
        
        viewModel.loadCommentAPI { [weak self] done, msg in
            guard let self = self else { return }
            if done {
                print("API load comments ok")
                self.setupTopComment()
            } else {
                print("API Load Comments Error")
            }
            IndicatorLoader.shared.hideActivityIndicator()
        }
    }
    
    // MARK: - UI Updates
    private func updateUI(with video: Video) {
        let playerVars = [ "rel" : 0 ]
        playerView.load(withVideoId: video.videoId, playerVars: playerVars)
        titleLabel.text = video.title
        descriptionLabel.attributedText = generateDescription(viewCount: video.viewCount,publishedAt: video.publishedAt,tags: video.tags ?? [])
        likeLabel.text = video.likeCount.formattedCounts()
        disLikeLabel.text = "0"
        channelImageView.image = video.channelImage
        channelTitleLabel.text = video.channel?.title
        subcribeCountLabel.text = video.channel?.subscriberCount.formattedSubcribe()
        commentCountLabel.text = video.commentCount
        
        showAllComponents()
    }
    
    private func showAllComponents() {
        let components: [UIView] = [
            titleLabel, descriptionLabel, likeLabel, disLikeLabel,
            likeButton, disLikeButton, saveButton, saveLabel,
            shareButton, shareLabel, streamButton, streamLabel,
            channelImageView, channelTitleLabel, subcribeCountLabel,
            subcribeLabel, commentTitleLabel, commentCountLabel,
            topCommentLabel, topCommentImageView
        ]
        components.forEach { $0.isHidden = false }
    }
    
    // MARK: - Layout
    private func layout() {
        channelImageView.makeRounded()
        topCommentImageView.makeRounded()
    }
    
}

// MARK: - Handle Action
extension DetailViewController {
    private func handleSaveButtonAction() {
        viewModel.saveVideo { isSave in
            if isSave {
                self.checkSaveButton()
                print("Save/DIdsave OK")
            } else {
                print("Save/DIdsave error")
            }
        }
    }
    
    private func handleRatingButtonAction(with rating: String) {
        guard viewModel.rating != rating else {
            handleNoneRatingButtonAction()
            return
        }
        viewModel.sendRatingVideoAPI(rating: rating) { done, msg in
            if done {
                print("\(rating.capitalized) video success")
                self.updateRatingButtons()
                NotificationCenter.default.post(name: .listLikeAndDisLikeChanged, object: nil)
            } else {
                print("\(rating.capitalized) video fail")
            }
        }
    }
    
    private func handleNoneRatingButtonAction() {
        viewModel.sendRatingVideoAPI(rating: "none") { done, msg in
            if done {
                print("None video success")
                self.updateRatingButtons()
                NotificationCenter.default.post(name: .listLikeAndDisLikeChanged, object: nil)
            } else {
                print("None video fail")
            }
        }
    }
    
    private func handleSubcriptionButton() {
        if viewModel.isSubcribe {
            print("DELETE subcribe video")
            viewModel.deleteSubcriptionAPI(subcriptionId: viewModel.subcription?.id ?? "") { done, msg in
                if done {
                    print("UnSubcribe video success")
                    self.updateSubcribeLabel()
                    NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
                } else {
                    print("UnSubcribe video fail")
                }
            }
        } else {
            viewModel.postSubcriptionAPI(channelId: viewModel.video?.channelId ?? "") { done, msg in
                if done {
                    print("Subcribe video success")
                    self.updateSubcribeLabel()
                    NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
                } else {
                    print("Subcribe video fail")
                }
            }
        }
    }
    
    private func presentCommentDetailViewController() {
        let commentDetailVC = CommentDetailViewController()
        commentDetailVC.delegate = self
        let navController = UINavigationController(rootViewController: commentDetailVC)
        commentDetailVC.viewModel.comments = viewModel.comments
        commentDetailVC.viewModel.videoId = viewModel.id
        fpc.set(contentViewController: navController)
        self.present(fpc, animated: true, completion: nil)
    }
}

// MARK: -  Setup Content
extension DetailViewController {
    private func checkSaveButton(){
        viewModel.saveCheck { [weak self] isSave in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let likeImage = isSave ? UIImage(named: "bookmark-bookmark_fill1_symbol") : UIImage(named: "bookmark-bookmark_symbol")
                self.saveButton.setImage(likeImage, for: .normal)
            }
        }
    }
    
    private func updateRatingButtons() {
        var likeImageName: String
        var dislikeImageName: String
        
        switch viewModel.rating {
        case "like":
            likeImageName = "thumb_up-thumb_up_fill1_symbol"
            dislikeImageName = "thumb_down-thumb_down_symbol"
            if let currentLikeCount = Int(likeLabel.text ?? "") {
                likeLabel.text = "\(currentLikeCount + 1)".formattedCounts()
            }
        case "dislike":
            likeImageName = "thumb_up-thumb_up_symbol"
            dislikeImageName = "thumb_down-thumb_down_fill1_symbol"
            if let currentLikeCount = Int(disLikeLabel.text ?? "") {
                disLikeLabel.text = "\(currentLikeCount + 1)".formattedCounts()
            }
        case "none":
            likeImageName = "thumb_up-thumb_up_symbol"
            dislikeImageName = "thumb_down-thumb_down_symbol"
            likeLabel.text = viewModel.video?.likeCount.formattedCounts()
            disLikeLabel.text = "0"
        default:
            return
        }
        setButtonImage(likeButton, imageName: likeImageName)
        setButtonImage(disLikeButton, imageName: dislikeImageName)
    }
    
    private func updateSubcribeLabel() {
        if viewModel.isSubcribe {
            subcribeLabel.text = "UNSUBCRIBE"
            subcribeLabel.textColor = .blackdarkColor1
        } else {
            subcribeLabel.text = "SUBCRIBE"
            subcribeLabel.textColor = .red
        }
    }
    
    private func updateRatingCount() {
        if let currentLikeCount = Int(likeLabel.text ?? ""), let currentDislikeCount = Int(disLikeLabel.text ?? "") {
            likeLabel.text = "\(currentLikeCount + 1)"
            // Dislike count remains the same
            disLikeLabel.text = "\(currentDislikeCount)"
        }
    }
    
    private func setupTopComment() {
        topCommentLabel.text = viewModel.comments.first?.textOriginal
        setThumbnail(for: topCommentImageView, with: viewModel.comments.first?.authorProfileImageUrl ?? "") { [weak self] image in
            guard let self = self, let image = image else { return }
            self.topCommentImageView.image = image
            self.viewModel.comments[0].firstAvatarImageView = image
        }
    }
    
    private func setButtonImage(_ button: UIButton, imageName: String) {
        let image = UIImage(named: imageName)
        button.setImage(image, for: .normal)
    }
    
    private func generateDescription(viewCount: String, publishedAt: String, tags: [String] ) -> NSAttributedString {
        let viewCount = String(viewCount).formattedViews()
        let timeAgo = publishedAt.timeAgoSinceDate()
        var tagsString = ""
        let numberOfTags = 4
        
        for index in 0..<min(numberOfTags, tags.count) {
            let formattedTag = tags[index].replacingOccurrences(of: " ", with: "")
            tagsString.append(" #\(formattedTag)")
        }
        
        let tags = NSMutableAttributedString().normal(tagsString)
        let attributedString = NSMutableAttributedString(string: "\(viewCount) • \(timeAgo) •")
        attributedString.append(tags)
        
        return attributedString
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
}

// MARK: - Control YoutubePlayer
extension DetailViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("DID become ready")
        //        playerView.seek(toSeconds: 15.551, allowSeekAhead: true)
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .buffering:
            playerView.currentTime { time, done in
                print(time)
            }
            print("buffering")
        case .unstarted:
            print("UNStated")
        case .ended:
            print("ended")
        case .playing:
            playerView.currentTime { time, done in
                print(time)
            }
            print("playing")
        case .paused:
            playerView.currentTime { time, done in
                print(time)
            }
            print("paused")
        case .cued:
            print("cued")
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        
    }
    
    
}

// MARK: - Delegate of CommentDetailViewDelegate
extension DetailViewController: CommentDetailViewDelegate{
    func didRequestToCloseCommentView() {
        // Code to remove the floating panel
        fpc.dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
// MARK: - Control FloatingPanelControllerDelegate
extension DetailViewController: FloatingPanelControllerDelegate {
    
}

// MARK: - Layout for FloatingPanel
class MyFloatingPanelLayout: FloatingPanelLayout{
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.72, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(fractionalInset: 0.72, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}


