//
//  UIView+Extension.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import Foundation
import UIKit
extension UIView {
    func pintoEdges (of view: UIView, with constant: CGFloat = 0 ) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant)
        ])
    }
    
    func pintoHeader (of view: UIView, with constant: CGFloat = 0 ) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant)
        ])
    }
    
    func addSubViews(_ views: UIView...) {
        views.forEach{(self.addSubview($0))}
    }
}


class SnackbarView: UIView {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }

    private func configureUI() {
        backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        layer.cornerRadius = 8

        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    func setMessage(_ message: String) {
        label.text = message
    }
}

extension UIView {
    func showToast(message: String, duration: TimeInterval = 3.0) {
        let snackbar = SnackbarView()
        snackbar.setMessage(message)

        addSubview(snackbar)
        snackbar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            snackbar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            snackbar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            snackbar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
            snackbar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16)
        ])

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            snackbar.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseInOut, animations: {
                snackbar.alpha = 0.0
            }, completion: { _ in
                snackbar.removeFromSuperview()
            })
        })
    }
}

