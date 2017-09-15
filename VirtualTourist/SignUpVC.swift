//
//  SignUpVC.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 9/14/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import Foundation
import FirebaseCore
import FirebaseAuth
import FacebookCore
import FacebookLogin

class SignUpVC: UIViewController {
    
    // MARK: Properties
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var alertController: UIAlertController?
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
        
        setupActivityIndicator()
        
        /*
         // Facebook Login Button Setup
         let FBloginButton = LoginButton(readPermissions: [ .publicProfile ])
         // FBloginButton.center = view.center
         FBloginButton.frame = CGRect(x: 16, y: view.frame.height-55, width: view.frame.width-32, height: 30)
         view.addSubview(FBloginButton)
         
         FBloginButton.delegate = self
         
         // If Facebook access token exists, navigate to LocationMapVC right away
         if AccessToken.current != nil {
         
         self.activityIndicator.startAnimating()
         
         UdacityClient.sharedInstance().postSessionWithFB(self) { (success, error) in
         performUIUpdatesOnMain {
         if (success != nil) {
         self.activityIndicator.stopAnimating()
         self.completeLogin()
         } else {
         self.getAlertView(title: "Login Error", error: error! as! String)
         }
         }
         }
         }
         */
    }
    
    func setupActivityIndicator() {
        
        // Activity Indicator Setup
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.lightGray
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextField.text = ""
        passwordTextField.text = ""
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Signup
    @IBAction func signUpPressed(_ sender: Any) {
        
        userDidTapView(self)
        self.activityIndicator.startAnimating()
        
        guard let username = usernameTextField.text, let password = passwordTextField.text, let confirmedPassword = confirmPasswordTextField.text else {
            self.activityIndicator.stopAnimating()
            self.getAlertView(title: "Sign up Failed", error: "User Name or Password is empty!!!")
            return
        }
        
        
        if password == confirmedPassword {
            
            Auth.auth().createUser(withEmail: username, password: password) { (user, error) in
                
                performUIUpdatesOnMain {
                    if (user != nil) {
                        self.activityIndicator.stopAnimating()
                        self.completeSignup()
                    } else {
                        print(error!)
                        self.getAlertView(title: "Sign up Error", error: error as! String)
                    }
                }
            }
        } else {
            self.activityIndicator.stopAnimating()
            self.getAlertView(title: "Sign up Failed", error: "Passwords not matched!!!")
        }
    }

    
    func completeSignup() {
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
}

// MARK: - SignUpVC: UITextFieldDelegate

extension SignUpVC: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification) - 80
            // logoImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0
            // logoImageView.isHidden = false
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    
}

// MARK: - SignUpVC (Configure UI)

extension SignUpVC {
    
    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        signUpButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            signUpButton.alpha = 1.0
        } else {
            signUpButton.alpha = 0.5
        }
    }
    
    func configureUI() {
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }
    
    func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

// MARK: - SignUpVC (Notifications)

private extension SignUpVC {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

