//
//  FullScreenImageViewController.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit

final class FullScreenImageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    /// Our view model.
    private let viewModel: FullScreenImageViewModelType
    
    /// The total number of items in the collection view.
    private var totalCellCount: Int = 0
    
    /// Loading overlay, used for displaying copy confirmation.
    private let loadingOverlay = LoadingOverlay()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(viewModel: FullScreenImageViewModelType) {
        self.viewModel = viewModel
        self.totalCellCount = viewModel.outputs.initialTotalCellCount
        
        // Configuring the flow layout.
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        super.init(collectionViewLayout: flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // A bit of configuration of the collection view.
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .black
        self.collectionView.isPagingEnabled = true
        self.collectionView.registerNib(for: SingleImageCollectionViewCell.self)
        
        // Add gesture recognizer.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapScreen(_:))))
        
        // Add and hide loading overlay.
        self.view.addSubview(loadingOverlay)
        self.loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loadingOverlay.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loadingOverlay.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        self.loadingOverlay.isHidden = true
        
        // MARK: - Output Handlers
        
        self.viewModel.outputs.displayImageStateAtIndexIfInView = { [weak self] stateAndIndex in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                let (state, index) = stateAndIndex
                if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) {
                    let cellConfiguration: SingleImageCollectionViewCell.Configuration
                    switch state {
                    case .loading: cellConfiguration = .loading(.whiteLarge)
                    case .error: cellConfiguration = .showingError
                    case .displaying(let image): cellConfiguration = .showingImage(image, longPressAction: { [weak self] in
                        self?.viewModel.inputs.userLongPressedOnItem(at: index, image: image)
                    })
                    }
                    (cell as! SingleImageCollectionViewCell).configure(as: cellConfiguration)
                }
            }
        }
        
        self.viewModel.outputs.increasePageSizeByIncrement = incrementItemsInSingleSectionCollectionView(self, backingModelKeyPath: \.totalCellCount)
        
        self.viewModel.outputs.scrollImmediatelyToItemAtIndex = { [weak self] index in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
        
        self.viewModel.outputs.showBriefConfirmationOverlayForSuccessfulCopy = { [weak self] _ in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                self.loadingOverlay.configure(as: .justText("Image copied!"))
                self.loadingOverlay.isHidden = false
                // Animate hiding.
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0.5,
                    animations: {
                        self.loadingOverlay.alpha = 0.0
                    },
                    completion: { _  in
                        self.loadingOverlay.isHidden = true
                        self.loadingOverlay.alpha = 1.0
                    }
                )
            }
           
        }
        
        self.viewModel.outputs.dismiss = self.dismiss
        
        self.viewModel.outputs.displayAlert = self.displayAlert
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    @objc private func userDidTapScreen(_ gesture: UITapGestureRecognizer) {
        self.viewModel.inputs.userTappedScreen()
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.totalCellCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: SingleImageCollectionViewCell.self, for: indexPath)
        cell.configure(as: .loading(.whiteLarge))
        cell.imageViewContentMode = .scaleAspectFit
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewModel.inputs.indicesWillComeIntoView([indexPath.row])
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewModel.inputs.indicesDidGoOutOfView([indexPath.row])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let sectionInsets = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.top + (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.bottom
        
        let contentInsets = collectionView.contentInset.top + collectionView.contentInset.bottom
        
        let maxHeight = collectionView.frame.height - sectionInsets - contentInsets
        
        return CGSize(width: collectionView.frame.width, height: maxHeight)
    }
}
