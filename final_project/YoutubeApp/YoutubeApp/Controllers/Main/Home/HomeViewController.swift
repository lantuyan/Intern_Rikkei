//
//  HomeViewController.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import UIKit
import Alamofire
import FirebaseDatabase
protocol HomeViewControllerDelegate {
    func switchToProfileTab()
    func switchToSearchTab()
}

class HomeViewController: UIViewController {
    // MARK: - Properties
    private var viewModel = HomeViewModel()
    private let homeView = HomeView()
    private var isLoadingMore = false
    private var categoriesCollectionViewHeightConstraint: NSLayoutConstraint!
    private var selectedIndexPath: IndexPath?
    var previousContentOffsetX: CGFloat = 0
    var previousContentOffsetY: CGFloat = 0
    var categoryID: String = "0"
    var isLoaded: Bool = true
    var delegate: HomeViewControllerDelegate?
    let imageAvartarView = UIImageView()
    
    // MARK: - Life cylce
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupAvartarImage()
        checkInternet()
    }
}

// MARK: - Setup
extension HomeViewController {
    func setupView() {
        setupTableViewAndCollectionView()
        setupNavigationBar()
        layoutViews()
    }
    
    func setupTableViewAndCollectionView() {
        homeView.listVideoTableView.delegate = self
        homeView.listVideoTableView.dataSource = self
        let nibHomeViewCell = UINib(nibName: "HomeViewCell", bundle: .main)
        homeView.listVideoTableView.register(nibHomeViewCell, forCellReuseIdentifier: "homeCell")
        
        homeView.categoriesCollectionView.delegate = self
        homeView.categoriesCollectionView.dataSource = self
        homeView.categoriesCollectionView.register(CategoryViewCell.self, forCellWithReuseIdentifier: "categoryCell")
        
        categoriesCollectionViewHeightConstraint = homeView.categoriesCollectionView.heightAnchor.constraint(equalToConstant: 30)
        categoriesCollectionViewHeightConstraint.isActive = true
    }
    
    func setupNavigationBar() {
        let profileBarButton = createBarButtonItem(with: imageAvartarView, selector: #selector(profileBarButtonTapped))
        self.navigationItem.rightBarButtonItems = [profileBarButton]
        self.navigationItem.leftBarButtonItem = createNavigationBarLogoItem(imageName: "logo_Youtube", width: Constants.barButtonImageSize, height: Constants.imageViewSize)
    }
    
    func createBarButtonItem(with customView: UIView, selector: Selector) -> UIBarButtonItem {
        customView.contentMode = .scaleAspectFit
        customView.widthAnchor.constraint(equalToConstant: Constants.imageViewSize).isActive = true
        customView.heightAnchor.constraint(equalToConstant: Constants.imageViewSize).isActive = true
        customView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: selector)
        customView.addGestureRecognizer(tapGesture)
        
        return UIBarButtonItem(customView: customView)
    }
    
    func createNavigationBarLogoItem(imageName: String, width: CGFloat, height: CGFloat) -> UIBarButtonItem {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        return UIBarButtonItem(customView: imageView)
    }
    
    func createSearchImageView() -> UIImageView {
        let searchImageView = UIImageView()
        searchImageView.image = UIImage(named: "search-search_symbol")
        searchImageView.makeRounded()
        searchImageView.tintColor = Constants.tintColor
        searchImageView.contentMode = .scaleAspectFit
        searchImageView.widthAnchor.constraint(equalToConstant: Constants.imageViewSize).isActive = true
        searchImageView.heightAnchor.constraint(equalToConstant: Constants.imageViewSize).isActive = true
        searchImageView.isUserInteractionEnabled = true
        let tapGestureSearchBarButton = UITapGestureRecognizer(target: self, action: #selector(profileBarButtonTapped))
        searchImageView.addGestureRecognizer(tapGestureSearchBarButton)
        
        return searchImageView
    }
    
    func setupAvartarImage(){
        let myChannel = DataManager.shared().getChannelFromUserDefaults()
        API.shared().downloadImage(with: myChannel?.avatarChannelUrl ?? "") { (image) in
            if let image = image {
                self.imageAvartarView.image = image
                self.imageAvartarView.makeRounded()
            }
        }
    }
    
    @objc private func profileBarButtonTapped() {
        print("Profile")
        delegate?.switchToProfileTab()
    }
    @objc private func searchBarButtonTapped() {
        print("Search")
        delegate?.switchToSearchTab()
    }
    
    func layoutViews() {
        view.backgroundColor = .white
        view.addSubViews(homeView)
        homeView.pintoEdges(of: view)
    }
    
    private func checkInternet() {
        if NetworkMonitor.shared.isConected {
            AlertManager.shared.hideAlertMessage(viewController: self)
            print("You're connteced")
        } else {
            AlertManager.shared.showAlertMessage(title: "Alert", message: "No Internet, please connect wifi or 4g", viewController: self)
            print("Don't have internet")
        }
    }
}

// MARK: - API Calls
extension HomeViewController {
    func loadAPI() {
        IndicatorLoader.shared.showActivityIndicator(on: self.view)
        viewModel.loadAPI{ done, msg in
            if done {
                print("API load ok")
                self.homeView.listVideoTableView.reloadData()
                print("nextPage token: ", self.viewModel.nextPageToken)
                IndicatorLoader.shared.hideActivityIndicator()
            } else {
                print("API Load Error")
            }
        }
        viewModel.loadCategory { done, msg in
            if done {
                print("load category ok")
                self.homeView.categoriesCollectionView.reloadData()
            } else {
                print("Load category Error \(msg)")
            }
        }
    }
    
    func loadAPIbyCategory(categoryID: String) {
        //        viewModel.videos.removeAll()
        IndicatorLoader.shared.showActivityIndicator(on: self.view)
        homeView.listVideoTableView.isScrollEnabled = false
        viewModel.loadAPIByCategory(categoryID: categoryID){ done, msg in
            if done {
                ErrorMessageManager.shared.hideErrorMessage()
                print("API load ok")
                self.homeView.listVideoTableView.reloadData()
                self.homeView.listVideoTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                IndicatorLoader.shared.hideActivityIndicator()
                self.homeView.listVideoTableView.isScrollEnabled = true
                self.isLoaded = true
            } else {
                print("API Load Error")
                self.homeView.listVideoTableView.reloadData()
                ErrorMessageManager.shared.showErrorMessage("No Item in this category", on: self.homeView.listVideoTableView, scrollView: self.homeView.listVideoTableView)
                IndicatorLoader.shared.hideActivityIndicator()
                self.homeView.listVideoTableView.isScrollEnabled = true
                self.isLoaded = true
            }
        }
    }
}

// MARK: - Control Video TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.videos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVideo = viewModel.videos[indexPath.row]
        let homeDetailVC = DetailViewController()
        homeDetailVC.viewModel.id = selectedVideo.videoId
        homeDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(homeDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as? HomeViewCell else {
            return UITableViewCell()
        }
        if !viewModel.videos.isEmpty {
            cell.configureCell(indexPath: indexPath, viewModel: viewModel)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
}

// MARK: - Control CategoriesCollectionView
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as? CategoryViewCell else {
            return UICollectionViewCell()
        }
        let item = viewModel.categories[indexPath.row]
        let isSelected = indexPath == selectedIndexPath
        cell.configureCell(with: item, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isLoaded {
            isLoaded = false
            deselectPreviouslySelectedCell(in: collectionView)
            selectCell(at: indexPath, in: collectionView)
            handleSelectionForCategory(at: indexPath)
        }
        
        print("CALL API CATEGORY")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let market = self.viewModel.categories[indexPath.row].title
        let label = UILabel(frame: CGRect.zero)
        label.text =  market as String
        label.sizeToFit()
        return CGSize(width: label.frame.width, height: 30)
    }
}

// MARK: - Helper method CategoriesCollectionView Content
extension HomeViewController {
    private func deselectPreviouslySelectedCell(in collectionView: UICollectionView) {
        if let selectedIndexPath = self.selectedIndexPath,
           let cell = collectionView.cellForItem(at: selectedIndexPath) as? CategoryViewCell {
            cell.setSelectedState(false)
        }
    }
    
    private func selectCell(at indexPath: IndexPath, in collectionView: UICollectionView) {
        selectedIndexPath = indexPath
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryViewCell {
            cell.setSelectedState(true)
        }
    }
    
    private func handleSelectionForCategory(at indexPath: IndexPath) {
        let selectedCategoryId = viewModel.categories[indexPath.row].categoryId
        categoryID = selectedCategoryId
        loadAPIbyCategory(categoryID: selectedCategoryId)
    }
}

// MARK: - Control ScrollView
extension HomeViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollingHorizontally = abs(scrollView.contentOffset.x - previousContentOffsetX) > abs(scrollView.contentOffset.y - previousContentOffsetY)
        // Đang cuộn ngang
        if isScrollingHorizontally {
        }
        // Cuộn dọc
        else {
            updateNavigationBarVisibility(scrollView: scrollView)
            checkAndLoadMoreContent(scrollView: scrollView)
        }
    }
    
    private func updateNavigationBarVisibility(scrollView: UIScrollView) {
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 80
        let isScrollingUp = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0
        let shouldHideNavigationBar = scrollView.contentOffset.y > navigationBarHeight && isScrollingUp
        
        // Perform update only if there's a change in visibility status
        if shouldHideNavigationBar != homeView.categoriesCollectionView.isHidden {
            navigationController?.setNavigationBarHidden(shouldHideNavigationBar, animated: false)
            homeView.categoriesCollectionView.isHidden = shouldHideNavigationBar
            adjustLayoutForCollectionView(isHidden: shouldHideNavigationBar)
        }
    }
    
    private func adjustLayoutForCollectionView(isHidden: Bool) {
        categoriesCollectionViewHeightConstraint.constant = isHidden ? 0 : 30
    }
    
    private func checkAndLoadMoreContent(scrollView: UIScrollView) {
        let isNearBottom = scrollView.contentOffset.y > scrollView.contentSize.height * 0.5 - scrollView.frame.size.height
        if isNearBottom && !isLoadingMore {
            loadMoreContent()
        }
    }
    
    private func loadMoreContent() {
        isLoadingMore = true
        print("LOAD MORE API")
        viewModel.loadMoreAPI(categoryId: categoryID) { [weak self] success, _ in
            guard let self = self else { return }
            self.isLoadingMore = false
            if success {
                homeView.listVideoTableView.reloadData()
                //
            }
        }
    }
    
    // Error function --
    private func addDataToTable(from startIndex: Int, to endIndex: Int) {
        guard case homeView.listVideoTableView = homeView.listVideoTableView else {
            return
        }
        let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        homeView.listVideoTableView.performBatchUpdates({
            viewModel.videos.append(contentsOf: viewModel.newDataVideos) // Add the new data to your data source
            homeView.listVideoTableView.insertRows(at: indexPaths, with: .automatic) // Insert rows for the new data
        }, completion: nil)
    }
}

