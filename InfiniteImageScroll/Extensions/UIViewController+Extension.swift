//
//  UIViewController+Extension.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/15/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Shared output handler for displaying a `UserAlert` in the form of a `UIAlertController`.
    var displayAlert: OutputFunction<UserAlert> {
        return { [weak self] alertInfo in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                let alert = UIAlertController(title: alertInfo.title, message: alertInfo.message, preferredStyle: .alert)
                for option in alertInfo.options {
                    let actionStyle: UIAlertAction.Style
                    switch option {
                    case .ok: actionStyle = .default
                    case .cancel: actionStyle = .cancel
                    case .custom: actionStyle = option.isDestructive ? .destructive: .default
                    }
                    
                    alert.addAction(UIAlertAction(title: option.text, style: actionStyle, handler: { _ in option.action?() }))
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /// Shared output handler for dismissing the receiver.
    var dismiss: OutputFunction<Void> {
        return { [weak self] _ in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
