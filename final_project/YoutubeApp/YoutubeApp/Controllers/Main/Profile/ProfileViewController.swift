//
//  ProfileViewController.swift
//  YoutubeApp
//
//  Created by Admin on 16/01/2024.
//

import UIKit
import GoogleSignIn
class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    let imageAvartarView = UIImageView()
    @IBOutlet weak var channelSubscribeCollectionView: UICollectionView!
    @IBOutlet weak var recentCollectionView: UICollectionView!
    
    @IBAction func tapLikeViewAction(_ sender: Any) {
        let profileSaveVC = ListSaveViewController()
        navigationController?.pushViewController(profileSaveVC, animated: true)
    }
    
    @IBAction func tapListLikeViewAction(_ sender: Any) {
        let profileLikeVC = ListLikeViewController()
        navigationController?.pushViewController(profileLikeVC, animated: true)
    }
    @IBAction func tapListDisLikeViewAction(_ sender: Any) {
        let profileDisLikeVC = ListDisLikeViewController()
        navigationController?.pushViewController(profileDisLikeVC, animated: true)
    }
    
    @IBAction func tapDownLoadViewAction(_ sender: Any) {
        AlertManager.shared.showAlertMessage(viewController: self)
    }
    
    @IBAction func tapWatch2GetherView(_ sender: Any) {
        AlertManager.shared.showAlertMessage(viewController: self)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        if let scene = UIApplication.shared.connectedScenes.first,
           let sd = (scene.delegate as? SceneDelegate) {
            sd.changeScreen(type: .login)
        }
    }
    
    // MARK: - life cycle
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupAvartarImage()
        loadRealmData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setup()
        loadAPI()
    }
    
    private func setup(){
        channelSubscribeCollectionView.delegate = self
        channelSubscribeCollectionView.dataSource = self
        let nibchannelSubscribeCollectionViewCell = UINib(nibName: "ChannelSubscribeCollectionViewCell", bundle: .main)
        channelSubscribeCollectionView.register(nibchannelSubscribeCollectionViewCell, forCellWithReuseIdentifier: "channelSubscribeCell")
        
        recentCollectionView.delegate = self
        recentCollectionView.dataSource = self
        let nibRecentCollectionViewCell = UINib(nibName: "RecentCollectionViewCell", bundle: .main)
        recentCollectionView.register(nibRecentCollectionViewCell, forCellWithReuseIdentifier: "recentCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionStatusDidChange), name: .subscriptionStatusChanged, object: nil)
    }
    
    func setupNavigationBar() {
        let profileBarButton = createBarButtonItem(with: imageAvartarView, selector: #selector(profileBarButtonTapped))
        self.navigationItem.rightBarButtonItems = [profileBarButton]
        self.navigationItem.leftBarButtonItem = createNavigationBarLogoItem(imageName: "logo_Youtube", width: Constants.barButtonImageSize, height: Constants.imageViewSize)
    }
    
    func createNavigationBarLogoItem(imageName: String, width: CGFloat, height: CGFloat) -> UIBarButtonItem {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        return UIBarButtonItem(customView: imageView)
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
    }
    
    @objc private func subscriptionStatusDidChange(notification: Notification) {
        print("LOAD API")
        viewModel.subscriptions.removeAll()
        loadAPI()
    }
    //    deinit {
    //        NotificationCenter.default.removeObserver(self, name: .subscriptionStatusChanged, object: nil)
    //    }
}

// MARK: - Load API - Data
extension ProfileViewController {
    private func loadAPI() {
        IndicatorLoader.shared.showActivityIndicator(on: self.channelSubscribeCollectionView)
        viewModel.getAllSubscription{ done, msg in
            if done {
                print("API load Subscribe ok")
                self.channelSubscribeCollectionView.reloadData()
                IndicatorLoader.shared.hideActivityIndicator()
            } else {
                print("API Load Subscribe Error")
            }
        }
    }
    
    private func loadRealmData() {
        viewModel.getAllVideosFromRealm()
        recentCollectionView.reloadData()
    }
}

// MARK: - Control CategoriesCollectionView
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case channelSubscribeCollectionView:
            return viewModel.subscriptions.count
        case recentCollectionView:
            return viewModel.dataVideos.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case channelSubscribeCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channelSubscribeCell", for: indexPath) as? ChannelSubscribeCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(indexPath: indexPath, viewModel: viewModel)
            return cell
        case recentCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentCell", for: indexPath) as? RecentCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(indexPath: indexPath, viewModel: viewModel)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case channelSubscribeCollectionView:
            return
        case recentCollectionView:
            let selectedVideo = viewModel.dataVideos[indexPath.row]
            let homeDetailVC = DetailViewController()
            homeDetailVC.viewModel.id = selectedVideo.videoId
            homeDetailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(homeDetailVC, animated: true)
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        switch collectionView {
        case channelSubscribeCollectionView:
            return CGSize(width: 65, height: 90)
        case recentCollectionView:
            return CGSize(width: screenWidth / 2.1, height: 160)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case channelSubscribeCollectionView:
            return 8
        case recentCollectionView:
            return 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case channelSubscribeCollectionView:
            return 5
        case recentCollectionView:
            return 0
        default:
            return 0
        }
    }
}
