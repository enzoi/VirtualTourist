//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 2/20/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit

// MARK - LoginVC (AlertController)

extension UIViewController {
    
    func showAlertWithError(title: String, error: Error) {
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithMessage(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
