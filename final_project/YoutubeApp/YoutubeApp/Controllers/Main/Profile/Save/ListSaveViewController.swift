//
//  ListLikeViewController.swift
//  YoutubeApp
//
//  Created by Admin on 17/01/2024.
//

import UIKit

class ListSaveViewController: UIViewController {
    private var viewModel = ListSaveViewModel()
    @IBOutlet weak var likeTableView: UITableView!
      
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        viewModel.getAllVideosFromRealm()
        likeTableView.reloadData()
    }
    
    private func setup() {
        likeTableView.delegate = self
        likeTableView.dataSource = self
        let nibListLikeViewCell = UINib(nibName: "ListLikeTableViewCell", bundle: .main)
        likeTableView.register(nibListLikeViewCell, forCellReuseIdentifier: "likeCell")
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem()
        backButton.title = "Save"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.navigationController?.navigationBar.tintColor = .black
    }
}

// MARK: - Control VideoTableView
extension ListSaveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataVideos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVideo = viewModel.dataVideos[indexPath.row]
        let homeDetailVC = DetailViewController()
        homeDetailVC.viewModel.id = selectedVideo.videoId
        homeDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(homeDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "likeCell", for: indexPath) as! ListLikeTableViewCell
        let item = viewModel.dataVideos[indexPath.row]
        
        
        cell.titleLabel.text = item.title
        cell.viewDescriptionLabel.text = item.viewCount.formattedCounts() + " views"
        cell.titleChannelLabel.text = item.channelTitle
        if let thumbnailImageData = item.thumbnailImageData {
            cell.thumbnailImageView.image = UIImage(data: thumbnailImageData)
        } else {
            cell.thumbnailImageView.image = UIImage(named: "defaultImage")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

extension ListSaveViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
