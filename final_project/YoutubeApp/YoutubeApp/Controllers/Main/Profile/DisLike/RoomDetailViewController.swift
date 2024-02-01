//
//  RoomViewController.swift
//  YoutubeApp
//
//  Created by Admin on 26/01/2024.
//

import UIKit
import youtube_ios_player_helper
import FirebaseDatabase

class RoomDetailViewController: UIViewController {
    let viewModel = RoomDetailViewModel()
    let user = DataManager.shared().getChannelFromUserDefaults()
    let ref = Database.database().reference()
    var frameViewY: CGFloat?
    
    @IBOutlet weak var videoPlayer: YTPlayerView!
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var countMemberLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageTextField: UITextField!
    
    
    @IBAction func sendMessageAction(_ sender: Any) {
        createMessage()
        messageTextField.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        videoPlayer.stopVideo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deleteUser()
        viewModel.messages.removeAll()
    }
    
    // MARK: - Setup Methods
    private func setup() {
        roomLabel.text = "Room: \(viewModel.room)"
        setupVideoPlayer()
        setupMessagesTable()
        setupTextField()
        setupAvatarImage()
        setupGestureRecognizer()
        setupNotifications()
        createUser()
        updateUser()
        updateRoom()
        updateMessage()
    }
    
    private func setupVideoPlayer() {
        videoPlayer.delegate = self
        videoPlayer.load(withVideoId: viewModel.videoId)
    }
    
    private func setupMessagesTable() {
        messagesTable.delegate = self
        messagesTable.dataSource = self
        messagesTable.register(UINib(nibName: "LeftRoomDetailTableViewCell", bundle: .main),
                               forCellReuseIdentifier: "roomDetailCell")
    }
    
    private func setupTextField() {
        messageTextField.delegate = self
    }
    
    private func setupAvatarImage() {
        if let avatarURL = user?.avatarChannelUrl {
            API.shared().downloadImage(with: avatarURL) { [weak self] image in
                DispatchQueue.main.async {
                    self?.profileImage.image = image
                    self?.profileImage.makeRounded()
                }
            }
        }
    }
    
    private func setupGestureRecognizer() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        frameViewY = view.frame.origin.y
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
        
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeigh = keyboardFrame.cgRectValue.height
            self.view.frame.origin.y =  -keyboardHeigh
        }
    }
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = frameViewY ?? 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func createRoom() {
        viewModel.createRoom() { room in
            if let room = room {
                print("Create room succes \(room)")
            } else {
                print("Error: Room creation failed.")
            }
        }
    }
    
    func updateRoom() {
        viewModel.updateRoom() { isPlaying, duration in
                DispatchQueue.main.async { [weak self] in
                    self?.videoPlayer.delegate = nil // null
                    if isPlaying {
                        print("PLAYYYYYy")
                        self?.videoPlayer.seek(toSeconds: Float(duration), allowSeekAhead: true)
                        self?.videoPlayer.playVideo()
                    } else {
                        print("STopppppp")
                        self?.videoPlayer.seek(toSeconds: Float(duration), allowSeekAhead: true)
                        self?.videoPlayer.pauseVideo()
                    }
                    self?.videoPlayer.delegate = self
                }
        
        }
    }
    
    func createUser() {
        viewModel.createUser() { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Create user succes")
            }
        }
    }
    
    func updateUser(){
        viewModel.updateUser { username, url, type in
            if type == "add" {
                self.view.showToast(message: "\(username) join the room.")
                
            } else if type == "remove" {
                self.view.showToast(message: "\(username) out the room.")
            }
            self.countMemberLabel.text = "Member: \(self.viewModel.countMembers)"
        }
    }
    
    func deleteUser() {
        viewModel.deleteUser() { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("DElete user success")
            }
        }
    }
    
    func createMessage() {
        if let text = messageTextField.text, text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
            viewModel.createMessage(message: text) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Create message success")
                }
            }
        }
    }
    
    func readMessage() {
        viewModel.readMessagesFirstTime { messages, error in
            if let error = error {
                print(" Error update message")
            } else {
                print("Read message success")
                self.messagesTable.reloadData()
            }
        }
    }
    
    func updateMessage(){
        viewModel.updateMessage { [self] message, error in
            if let error = error {
                print(" Error update message \(error)")
            } else {
                print("Update message success")
                messagesTable.beginUpdates()
                messagesTable.insertRows(at: [IndexPath.init(row: viewModel.messages.count - 1 , section: 0)], with: .fade)
                messagesTable.endUpdates()
                messagesTable.scrollToRow(at: IndexPath(row: viewModel.messages.count - 1, section: 0), at: .top, animated: true)
                messagesTable.reloadData()
            }
        }
    }
}

// MARK: - Control YoutubePlayer
extension RoomDetailViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        let room = String(viewModel.room)
        switch state {
        case .buffering:
            handleBufferingState(playerView: playerView, room: room)
        case .unstarted:
            print("UNStarted")
        case .ended:
            print("Ended")
        case .playing:
            print("Playing")
        case .paused:
            handlePausedState(playerView: playerView, room: room)
        case .cued:
            print("Cued")
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
    }
    
    private func handleBufferingState(playerView: YTPlayerView, room: String) {
        if viewModel.role == "user" {
            playerView.currentTime { time, done in
                let duration = time.magnitude
                let updateValues: [String: Any] = [
                    "play": true,
                    "duration": duration,
                    "videoId": self.viewModel.videoId,
                    "password": self.viewModel.password
                ]
                print("Updating room \(room) with values: \(updateValues)")
                self.ref.child("ActionRoom").child("\(room)").updateChildValues(updateValues)
            }
        }
        print("Buffering")
    }
    
    private func handlePausedState(playerView: YTPlayerView, room: String) {
        if viewModel.role == "user" {
            playerView.currentTime { time, done in
                let duration = time.magnitude
                let updateValues: [String: Any] = [
                    "play": false,
                    "duration": duration,
                    "videoId": self.viewModel.videoId,
                    "password": self.viewModel.password
                ]
                print("Updating room \(room) with values: \(updateValues)")
                self.ref.child("ActionRoom").child("\(room)").updateChildValues(updateValues)
            }
            print("Paused")
        }
    }
}

// MARK: - Control TableMessage
extension RoomDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "roomDetailCell", for: indexPath) as? LeftRoomDetailTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(cell, at: indexPath, viewModel: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
}

extension RoomDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextField.resignFirstResponder()
        return true
    }
}

extension RoomDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
