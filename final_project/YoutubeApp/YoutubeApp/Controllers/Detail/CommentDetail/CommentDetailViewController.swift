//
//  CommentDetailViewController.swift
//  YoutubeApp
//
//  Created by Admin on 15/01/2024.
//

import UIKit

protocol CommentDetailViewDelegate {
    func didRequestToCloseCommentView()
}

class CommentDetailViewController: UIViewController {
    var expandedcell:IndexSet = []
    let viewModel = CommentDetailViewModel()
    var delegate: CommentDetailViewDelegate?
    @IBOutlet weak var commentTable: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBAction func sendMessageAction(_ sender: Any) {
        sendMessage()
    }
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let myChannel = DataManager.shared().getChannelFromUserDefaults()
        API.shared().downloadImage(with: myChannel?.avatarChannelUrl ?? "") { (image) in
            if let image = image {
                self.avatarImage.image = image
                self.avatarImage.makeRounded()
            }
        }
    }
    
    private func setup(){
        commentTable.delegate = self
        commentTable.dataSource = self
        let nibHomeViewCell = UINib(nibName: "CommentDetailCell", bundle: .main)
        commentTable.register(nibHomeViewCell, forCellReuseIdentifier: "commentDetailCell")
        commentTable.estimatedRowHeight = 120
        commentTable.rowHeight = UITableView.automaticDimension
        
        messageTextField.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (hideKeyboard)))
        NotificationCenter
            .default
            .addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter
            .default
            .addObserver(self, selector: #selector (keyboardWillHide),name:UIResponder.keyboardWillHideNotification,object: nil)
    }
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Comments"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .black
        
        let titleBarItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.leftBarButtonItem = titleBarItem
        
        let closeButton = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(closeButtonTapped))
        closeButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = closeButton
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .white
        
        let navBarBottomLine = UIView()
        navBarBottomLine.backgroundColor = .gray
        navBarBottomLine.translatesAutoresizingMaskIntoConstraints = false
        navigationController?.navigationBar.addSubview(navBarBottomLine)
        
        NSLayoutConstraint.activate([
            navBarBottomLine.leadingAnchor.constraint(equalTo: navigationController!.navigationBar.leadingAnchor),
            navBarBottomLine.trailingAnchor.constraint(equalTo: navigationController!.navigationBar.trailingAnchor),
            navBarBottomLine.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor),
            navBarBottomLine.heightAnchor.constraint(equalToConstant: 0.5) // Set your desired line thickness
        ])
    }
    
    @objc func closeButtonTapped() {
        delegate?.didRequestToCloseCommentView()
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeigh = keyboardFrame.cgRectValue.height
            let bottomSpace = messageTextField.frame.height + 5
            self.view.frame.origin.y =  -keyboardHeigh + bottomSpace
        }
    }
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = messageTextField.frame.height + 5
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func sendMessage() {
        if let text = messageTextField.text, text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
            messageTextField.text = ""
            viewModel.postCommentAPI(textOriginal: "\(text)") { done, msg in
                if done {
                    print("API post comment ok")
                    self.commentTable.reloadData()
                } else {
                    print("API post comment error \(msg)")
                }
            }
        }
    }
}

// MARK: - Control Comment TableView
extension CommentDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentDetailCell", for: indexPath) as? CommentDetailCell else {return UITableViewCell()}
        let comment = viewModel.comments[indexPath.row]
        cell.configureCell(with: comment, isExpanded: expandedcell.contains(indexPath.row), delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension CommentDetailViewController: CommentDetailCellDelegate {
    func didTapReadMoreButton(_ cell: CommentDetailCell) {
        if let indexPath = commentTable.indexPath(for: cell) {
            if expandedcell.contains(indexPath.row) {
                expandedcell.remove(indexPath.row)
            } else {
                expandedcell.insert(indexPath.row)
            }
            commentTable.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func didTapReplyDetail(_ cell: CommentDetailCell, comment: Comment) {
        let replyVC = ReplyViewController()
        replyVC.delegate = self
        replyVC.viewModel.comment = comment
        navigationController?.pushViewController(replyVC, animated: true)
    }
}

extension CommentDetailViewController: ReplyViewDelegate {
    func didRequestToReplyView() {
        delegate?.didRequestToCloseCommentView()
    }
}

extension CommentDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextField.resignFirstResponder()
        return true
    }
}
