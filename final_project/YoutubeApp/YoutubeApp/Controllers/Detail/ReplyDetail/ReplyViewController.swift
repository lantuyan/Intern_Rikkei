//
//  ReplyViewController.swift
//  YoutubeApp
//
//  Created by Admin on 18/01/2024.
//

import UIKit
protocol ReplyViewDelegate {
    func didRequestToReplyView()
}
class ReplyViewController: UIViewController {
    
    var expandedcell:IndexSet = []
    let viewModel = ReplyViewModel()
    var delegate: ReplyViewDelegate?
    @IBOutlet weak var replyTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setup()
    }
    
    private func setup(){
        replyTable.delegate = self
        replyTable.dataSource = self
        let nibHomeViewCell = UINib(nibName: "CommentDetailCell", bundle: .main)
        replyTable.register(nibHomeViewCell, forCellReuseIdentifier: "commentDetailCell")
        replyTable.estimatedRowHeight = 120
        replyTable.rowHeight = UITableView.automaticDimension
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Reply"
        let closeButton = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(closeButtonTapped))
        closeButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = closeButton
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .white // Set your desired color
        // Add a bottom border to the navigation bar
        let navBarBottomLine = UIView()
        navBarBottomLine.backgroundColor = .gray // Set your desired line color
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
        delegate?.didRequestToReplyView()
    }
}

extension ReplyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.comment.replies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentDetailCell", for: indexPath) as? CommentDetailCell else {return UITableViewCell()}
        if let comment = viewModel.comment.replies?[indexPath.row] {
            cell.configureCellForReply(with: comment, isExpanded: expandedcell.contains(indexPath.row), delegate: self)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ReplyViewController: CommentDetailCellDelegate {
    func didTapReadMoreButton(_ cell: CommentDetailCell) {
        if let indexPath = replyTable.indexPath(for: cell) {
            if expandedcell.contains(indexPath.row) {
                expandedcell.remove(indexPath.row)
            } else {
                expandedcell.insert(indexPath.row)
            }
            replyTable.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func didTapReplyDetail(_ cell: CommentDetailCell, comment: Comment) {
    }
}
