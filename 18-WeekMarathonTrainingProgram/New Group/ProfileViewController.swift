//
//  ProfileViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/10.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var downloadUploadStackView: UIStackView!
    @IBOutlet weak var downloadRecordButton: UIButton!
    @IBOutlet weak var uploadRecordButton: UIButton!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var loginFBButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    var isLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetUp(target: self)
        self.navigationItem.title = "Profile"
        // Do any additional setup after loading the view.
        loginStackView.isHidden = isLogin ? true:false
        downloadUploadStackView.isHidden = isLogin ? false:true
    }
    

   
    @IBAction func didTappedLoginWithFBButton(_ sender: UIButton) {
        facebookLogin(sender: sender)
    }
    
    
    @IBAction func didTappedCreateAccountButton(_ sender: Any) {
    }
    
    
    @IBAction func didTappedDownloadRecordButton(_ sender: Any) {
    }
    
    @IBAction func didTappedUploadRecordButton(_ sender: Any) {
    }
    
    //MARK: - FB login
    func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                // TODO: modify this
                // Present the main view
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
            
        }
    }
}
