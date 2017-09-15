//
//  LandingVC.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 9/14/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class LandingVC: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.signUpButton.layer.cornerRadius = 3
        self.signUpButton.layer.borderWidth = 1
        self.signUpButton.layer.borderColor = Constants.UI.WhiteColor
        self.logInButton.layer.cornerRadius = 3
        self.logInButton.layer.borderWidth = 1
        self.logInButton.layer.borderColor = Constants.UI.WhiteColor
        
    }

}
