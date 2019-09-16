//
//  LoadingOverlay.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit

/// A semi-transparent loading overlay.
final class LoadingOverlay: UIView {
    
    /// Enumerates the available configurations of the view.
    enum Configuration {
        /// An animating activity indicator with a text label, side-by-side.
        case loadingWithText(String)
        
        /// Just a text label.
        case justText(String)
    }
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        guard let nib = LoadingOverlay.loadNib(withOwner: self) else { fatalError() }
        self.addSubview(nib)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        self.backgroundColor = .clear
        self.contentView.layer.cornerRadius = 5.0
    }
    
    /// Configures the receiver with the provided `configuration`.
    func configure(as configuration: Configuration) {
        switch configuration {
        case .loadingWithText(let text):
            self.activityIndicator.isHidden = false
            self.textLabel.text = text
            self.activityIndicator.startAnimating()
        case .justText(let text):
            self.activityIndicator.isHidden = true
            self.textLabel.text = text
        }
    }
}

extension LoadingOverlay: NibLoadable {
    static var nibName: String { return "LoadingOverlay" }
}
