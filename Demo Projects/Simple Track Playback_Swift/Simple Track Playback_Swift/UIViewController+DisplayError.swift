//
//  UIViewController+DisplayError.swift
//  Spotify Demo
//
//  Created by adam.wienconek on 24.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

struct Message {
    let title: String?
    let message: String?
}

extension UIViewController {
    func displayErrorMessage(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func displayMessage(_ message: Message, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: message.title, message: message.message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            completion?()
        }))
        present(alertController, animated: true, completion: nil)
    }
}
