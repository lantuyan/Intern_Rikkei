//
//  HomeView.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import UIKit

class HomeView: UIView {
    lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var listVideoTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
}

extension HomeView {
    private func setupView() {
        addSubViews(
            categoriesCollectionView,
            listVideoTableView
        )
    }
    
    private func style() {
    }
    
    private func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoriesCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 30),
            listVideoTableView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 10),
            listVideoTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            listVideoTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            listVideoTableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
}
