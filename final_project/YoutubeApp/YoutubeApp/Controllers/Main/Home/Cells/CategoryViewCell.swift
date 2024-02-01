//
//  CategoryViewCell.swift
//  YoutubeApp
//
//  Created by Admin on 09/01/2024.
//

import UIKit

class CategoryViewCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let selectedCellColor = UIColor.blackdarkColor1
    private let unselectedCellColor = UIColor.blackdarkColor4
    
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

extension CategoryViewCell {
    private func setupView() {
        self.addSubview(titleLabel)
    }
    
    private func style() {
        self.backgroundColor  = .lightGray
        self.layer.cornerRadius = 12
        
    }
    
    private func layout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: 0)
        ])
    }
}

extension CategoryViewCell {
    func configureCell(with item: Category, isSelected: Bool) {
        titleLabel.text = item.title
        backgroundColor = isSelected ? selectedCellColor : unselectedCellColor
        titleLabel.textColor = isSelected ? UIColor.white : UIColor.black
    }
    
    func setSelectedState(_ isSelected: Bool) {
        backgroundColor = isSelected ? selectedCellColor : unselectedCellColor
        titleLabel.textColor = isSelected ? UIColor.white : UIColor.black
    }
}


