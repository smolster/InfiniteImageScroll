//
//  Reusable+NibLoadable.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

protocol NibLoadable: class {
    static var nibName: String { get }
    static var nibBundle: Bundle { get }
}

extension NibLoadable {
    static var nibBundle: Bundle { return Bundle(for: self) }
    
    /// Loads the nib associated with the receiver.
    static func loadNib(withOwner owner: Any?, options: [UINib.OptionsKey: Any]? = nil) -> UIView? {
        guard let loadedNibs = self.nibBundle.loadNibNamed(self.nibName, owner: owner, options: options) else {
            return nil
        }
        return (loadedNibs[0] as! UIView)
    }
}

extension UICollectionView {
    func registerNib<T>(for type: T.Type) where T: UICollectionViewCell & NibLoadable & Reusable {
        self.register(UINib(nibName: T.nibName, bundle: T.nibBundle), forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T>(ofType type: T.Type, for indexPath: IndexPath) -> T where T: UICollectionViewCell & Reusable {
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

extension UITableView {
    func registerNib<T>(for type: T.Type) where T: UITableViewCell & NibLoadable & Reusable {
        self.register(UINib(nibName: T.nibName, bundle: T.nibBundle), forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T>(ofType type: T.Type, for indexPath: IndexPath) -> T where T: UITableViewCell & Reusable {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

