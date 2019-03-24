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
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginFBButton: UIButton!
    var isLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetUp(target: self)
        self.navigationItem.title = "Profile"
        // Do any additional setup after loading the view.
        reloadData()
    }
    
    func fetchProfile() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "email, first_name, last_name, id, gender, picture.type(large)"])
            .start(completionHandler:  {
                (connection, result, error) in
                
                guard
                    let result = result as? NSDictionary,
                    let picture = result["picture"]  as? NSDictionary,
                    let data = picture["data"] as? NSDictionary,
                    let picURL = data["url"] as? String
                    else {
                        return
                }
                if let userImageURL = URL(string: picURL) {
                    if let userImageData = NSData(contentsOf: userImageURL) as Data? {
                        self.isLogin = true
                        self.avatarImageView.image = UIImage(data: userImageData)
                        self.avatarImageView.layer.cornerRadius = 50
                        self.avatarImageView.layer.masksToBounds = true
                        self.loginStackView.isHidden = self.isLogin
                        self.downloadUploadStackView.isHidden = !self.isLogin
                    }
                }
            })
    }

   
    @IBAction func didTappedLoginWithFBButton(_ sender: UIButton) {
        facebookLogin(sender: sender)
    }
    
    @IBAction func didTappedLogoutButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            FBSDKLoginManager().logOut()
            self.isLogin = false
            self.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func didTappedDownloadRecordButton(_ sender: Any) {
    }
    
    @IBAction func didTappedUploadRecordButton(_ sender: Any) {
    }
    
    func reloadData () {
        loginStackView.isHidden = isLogin
        downloadUploadStackView.isHidden = !isLogin
        
        if FBSDKAccessToken.current() != nil {
            fetchProfile()
        }else{
            avatarImageView.image = UIImage(named: "avatarPlaceholder")
        }
    }
    
    //MARK: - FB login
    func facebookLogin(sender: UIButton) {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            
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
                DispatchQueue.main.async {
                    self.isLogin = true
                    self.reloadData()
                }
            })
            
        }
    }
}
