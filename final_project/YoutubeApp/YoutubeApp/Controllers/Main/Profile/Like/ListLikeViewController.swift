//
//  ListLikeViewController.swift
//  YoutubeApp
//
//  Created by Admin on 25/01/2024.
//

import UIKit

class ListLikeViewController: UIViewController {
    private var viewModel = ListLikeViewModel()
    @IBOutlet weak var likeTableView: UITableView!
    private var previousContentOffsetX: CGFloat = 0
    private var previousContentOffsetY: CGFloat = 0
    private var isLoadingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        loadAPI()
        likeTableView.reloadData()
    }
    
    private func setup() {
        likeTableView.delegate = self
        likeTableView.dataSource = self
        let nibListLikeViewCell = UINib(nibName: "ListLikeTableViewCell", bundle: .main)
        likeTableView.register(nibListLikeViewCell, forCellReuseIdentifier: "likeCell")
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(listChange), name: .listLikeAndDisLikeChanged, object: nil)
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem()
        backButton.title = "Like"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    func loadAPI() {
        viewModel.loadAPI{ done, msg in
            if done {
                print("API load ok")
                self.likeTableView.reloadData()
                print("nextPage token: ", self.viewModel.nextPageToken)
            } else {
                print("API Load Error")
            }
        }
    }
    
    @objc private func listChange(notification: Notification) {
        print("LOAD API")
        viewModel.dataVideos.removeAll()
        loadAPI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .subscriptionStatusChanged, object: nil)
    }
}

// MARK: - Control VideoTableView
extension ListLikeViewController: UITableViewDelegate, UITableViewDataSource {
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
        cell.titleChannelLabel.text = item.channelTitle
        cell.viewDescriptionLabel.text = item.viewCount.formattedCounts() + " views"
        cell.thumbnailImageView.image = item.thumbnailImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

extension ListLikeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Control ScrollView
extension ListLikeViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollingHorizontally = abs(scrollView.contentOffset.x - previousContentOffsetX) > abs(scrollView.contentOffset.y - previousContentOffsetY)
        // Đang cuộn ngang
        if isScrollingHorizontally {
        }
        // Cuộn dọc
        else {
            checkAndLoadMoreContent(scrollView: scrollView)
        }
    }
    
    private func checkAndLoadMoreContent(scrollView: UIScrollView) {
        let isNearBottom = scrollView.contentOffset.y > scrollView.contentSize.height * 0.4
        if isNearBottom && !isLoadingMore {
            loadMoreContent()
        }
    }
    
    private func loadMoreContent() {
        isLoadingMore = true
        print("LOAD MORE API")
        viewModel.loadMoreAPI() { [weak self] success, _ in
            guard let self = self else { return }
            self.isLoadingMore = false
            if success {
                likeTableView.reloadData()
                //
            }
        }
    }
    
}
