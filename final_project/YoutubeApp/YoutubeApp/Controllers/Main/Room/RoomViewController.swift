//
//  RoomViewController.swift
//  YoutubeApp
//
//  Created by Admin on 29/01/2024.
//

import UIKit

class RoomViewController: UIViewController {
    private var viewModel = RoomViewModel()
    
    @IBOutlet weak var roomCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAPI()
    }
    
    private func setup() {
        roomCollectionView.delegate = self
        roomCollectionView.dataSource = self
        let nibRoomViewCell = UINib(nibName: "RoomCollectionViewCell", bundle: .main) 
        roomCollectionView.register(nibRoomViewCell, forCellWithReuseIdentifier: "roomCell")
    }
    
    func setupNavigationBar() {
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
    
    private func loadAPI() {
        IndicatorLoader.shared.showActivityIndicator(on: self.view)
        viewModel.readAllRooms { done in
            if done {
                ErrorMessageManager.shared.hideErrorMessage()
                print(self.viewModel.allRooms)
                IndicatorLoader.shared.hideActivityIndicator()
                self.roomCollectionView.reloadData()
            } else {
                ErrorMessageManager.shared.showErrorMessage("Don't have any room", on: self.roomCollectionView, scrollView: self.roomCollectionView)
                IndicatorLoader.shared.hideActivityIndicator()
            }
        }
    }
}

// MARK: - Control RoomCollectionView
extension RoomViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.allRooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomCell", for: indexPath) as? RoomCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(cell, at: indexPath, viewModel: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let itemWidth = (collectionViewWidth - 10) / 2
        let itemHeight: CGFloat = 50
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.allRooms[indexPath.item]
        let roomDetailVC = RoomDetailViewController()
        roomDetailVC.hidesBottomBarWhenPushed = true
        roomDetailVC.viewModel.room = item.roomId
        roomDetailVC.viewModel.videoId = item.videoId
        AlertManager.shared.showPasswordInputDialog(on: self) { [weak self] enteredPassword in
            guard let enteredPassword = enteredPassword else {
                return
            }
            roomDetailVC.viewModel.checkPasswordRoom(enteredPassword: enteredPassword) { log in
                if log {
                    self?.navigationController?.pushViewController(roomDetailVC, animated: true)
                } else {
                    AlertManager.shared.showAlertMessage(message: "Password not correct", viewController: self!)
                }
            }
        }
    }
}
