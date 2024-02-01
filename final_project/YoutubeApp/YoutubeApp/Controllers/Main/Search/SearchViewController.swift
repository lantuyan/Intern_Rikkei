//
//  SearchViewController.swift
//  YoutubeApp
//
//  Created by Admin on 09/01/2024.
//

import UIKit

class SearchViewController: UIViewController {
    // MARK: - Propeties
    var searchTimer: Timer?
    private var viewModel = SearchViewModel()
    private let searchView = SearchView()
    private var previousContentOffsetX: CGFloat = 0
    private var previousContentOffsetY: CGFloat = 0
    private var isLoadingMore = false
    var searchTextType: String = ""
    var isLoaded: Bool = true
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setup() {
        searchView.listVideoTableView.delegate = self
        searchView.listVideoTableView.dataSource = self
        let nibSearchViewCell = UINib(nibName: "SearchViewCell", bundle: .main)
        searchView.listVideoTableView.register(nibSearchViewCell, forCellReuseIdentifier: "searchCell")
        searchView.delegate = self
    }
    
    private func layout() {
        view.addSubViews(searchView)
        searchView.pintoEdges(of: view)
    }
    
    private func loadAPI(query: String) {
        IndicatorLoader.shared.showActivityIndicator(on: self.view)
        viewModel.loadAPIByQuery(query: query){ done, msg in
            if done {
                self.isLoaded = true
                print("API Search video load ok")
                self.searchView.listVideoTableView.reloadData()
                IndicatorLoader.shared.hideActivityIndicator()
                self.view.endEditing(true)
            } else {
                self.isLoaded = true
                print("API Load Error")
                self.view.endEditing(true)
            }
        }
    }
}

// MARK: - Control VideoTableView
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.videos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLoaded {
            let selectedVideo = viewModel.videos[indexPath.row]
            let detailVC = DetailViewController()
            detailVC.viewModel.id = selectedVideo.videoId
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchViewCell
        cell.configureCell(cell, at: indexPath, viewModel: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
}

// MARK: - Control Searchbar
extension SearchViewController: SearchViewDelegate {
    func hiddenKeyboard() {
        view.endEditing(true)
    }
    
    func didChangeSearchText(searchText: String?) {
        searchTimer?.invalidate()
        guard let searchText = searchText, !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        isLoaded = false
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.loadAPI(query: searchText)
            self?.searchTextType = searchText
            print("Search Text \(searchText)")
        })
        
    }
}

// MARK: - Control ScrollView
extension SearchViewController {
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
        let isNearBottom = scrollView.contentOffset.y > scrollView.contentSize.height * 0.5
        if isNearBottom && !isLoadingMore {
            loadMoreContent()
        }
    }
    
    private func loadMoreContent() {
        isLoadingMore = true
        print("LOAD MORE API")
        viewModel.loadMoreAPI(query: searchTextType) { [weak self] success, _ in
            guard let self = self else { return }
            self.isLoadingMore = false
            if success {
                searchView.listVideoTableView.reloadData()
                //
            }
        }
    }
    
}


