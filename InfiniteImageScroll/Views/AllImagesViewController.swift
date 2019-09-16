//
//  AllImagesViewController.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/12/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit

final class AllImagesViewController: UICollectionViewController {
    
    /// Our view model!
    private let viewModel: AllImagesViewModelType
    
    /// The total number of items in the collection view.
    private var totalCellCount: Int = 0
    
    /// Loading overlay, displayed in response to long pressing to copy an image.
    private let loadingOverlay = LoadingOverlay()

    init(viewModel: AllImagesViewModelType, itemsPerRow: Int = 4, spacingBetweenItems: CGFloat = 2.0) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: .regularGrid(totalWidth: UIScreen.main.bounds.width, itemsPerRow: itemsPerRow, spacing: spacingBetweenItems))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Basic View Configuration
        self.title = "Images"
        self.loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loadingOverlay)
        NSLayoutConstraint.activate([
            self.collectionView.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            self.collectionView.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
        self.loadingOverlay.isHidden = true
        
        self.collectionView.backgroundColor = .white
        self.collectionView.registerNib(for: SingleImageCollectionViewCell.self)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsButtonTapped(_:)))
        
        // - MARK: Output Handlers.
        
        self.viewModel.outputs.displayImageAtIndexIfInView = { [weak self] item in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                // Check if cell is being displayed.
                if let cell = self.collectionView.cellForItem(at: IndexPath(row: item.index, section: 0)) as? SingleImageCollectionViewCell {
                    cell.configure(as: .showingImage(item.image, longPressAction: { [weak self] in
                        self?.viewModel.inputs.userLongPressedOnItem(at: item.index)
                    }))
                }
            }
        }
        
        self.viewModel.outputs.increaseTotalItemsByIncrement = incrementItemsInSingleSectionCollectionView(self, backingModelKeyPath: \.totalCellCount)
        
        self.viewModel.outputs.decreaseTotalItemsToZero = { [weak self] _ in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                self.totalCellCount = 0
                self.collectionView.reloadData()
            }
        }
        
        self.viewModel.outputs.updateLoadingOverlayState = { [weak self] overlayState in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                switch overlayState {
                case .loading(let activity):
                    self.loadingOverlay.isHidden = false
                    self.collectionView.isUserInteractionEnabled = false
                    let text: String
                    switch activity {
                    case .copying: text = "Copying image..."
                    case .loadingImages: text = "Loading images..."
                    }
                    self.loadingOverlay.configure(as: .loadingWithText(text))
                case .finished(let activity, let wasSuccess):
                    self.loadingOverlay.isHidden = false
                    self.collectionView.isUserInteractionEnabled = true
                    let text: String
                    switch activity {
                    case .copying: text = wasSuccess ? "Copied image!" : "Couldn't copy image."
                    case .loadingImages: text = wasSuccess ? "Images loaded." : "Image load failed."
                    }
                    self.loadingOverlay.configure(as: .justText(text))
                    // Now, hide.
                    UIView.animate(
                        withDuration: 0.5,
                        delay: activity == .copying ? 0.5 : 0.0,
                        animations: {
                            self.loadingOverlay.alpha = 0.0
                        },
                        completion: { _ in
                            self.loadingOverlay.isHidden = true
                            self.loadingOverlay.alpha = 1.0
                    })
                }
            }
        }
        
        self.viewModel.outputs.showFullScreenImageViewWithViewModel = { [weak self] singleImageVM in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                let singleImageVC = FullScreenImageViewController(viewModel: singleImageVM)
                singleImageVC.modalTransitionStyle = .crossDissolve
                singleImageVC.modalPresentationStyle = .fullScreen
                self.present(singleImageVC, animated: true, completion: nil)
            }
        }
        
        self.viewModel.outputs.showSettingsScreenWithViewModel = { [weak self] settingsVM in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                let settingsVC = SettingsViewController(viewModel: settingsVM)
                self.present(UINavigationController(rootViewController: settingsVC), animated: true, completion: nil)
            }
        }
        
        self.viewModel.outputs.displayAlert = self.displayAlert
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.inputs.viewWillAppear()
    }
    
    // MARK: - Selector Methods
    @objc private func settingsButtonTapped(_ button: UIBarButtonItem) {
        self.viewModel.inputs.userTappedSettingsButton()
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
        cell.configure(as: .blank)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.inputs.userTappedItem(at: indexPath.row)
    }
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewModel.inputs.indicesWillComeIntoView([indexPath.row])
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewModel.inputs.indicesDidGoOutOfView([indexPath.row])
    }
    
    // MARK: Infinite Scrolling Logic
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // This code calls the view model input if we are within one full screen of the bottom of the collection view.
        if scrollView.contentSize.height - scrollView.contentOffset.y < scrollView.frame.size.height * 2.0 {
            self.viewModel.inputs.userNearingBottomOfPage()
        }
    }
    
    // MARK: - Private Functions
}
