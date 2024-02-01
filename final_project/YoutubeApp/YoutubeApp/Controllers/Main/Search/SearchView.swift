//
//  SearchView.swift
//  YoutubeApp
//
//  Created by Admin on 11/01/2024.
//

import UIKit

protocol SearchViewDelegate {
    func didChangeSearchText(searchText: String?)
    func hiddenKeyboard()
}

class SearchView: UIView {
    var delegate: SearchViewDelegate?
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search Youtube"
        search.searchBarStyle = .minimal
        search.setImage(UIImage(), for: .search, state: .normal)
        search.delegate = self
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    lazy var micButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mic"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleMicButton), for: .touchUpInside)
        return button
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

extension SearchView {
    private func setupView() {
        addSubViews(
            searchBar,
            listVideoTableView
        )
    }
    
    @objc func handleBackButton() {
    }
    
    @objc func handleMicButton() {
    }
    
    private func style() {
        backgroundColor = .white
    }
    
    private func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            listVideoTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            listVideoTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            listVideoTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            listVideoTableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
}

extension SearchView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.didChangeSearchText(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.hiddenKeyboard()
    }
    
    
}
