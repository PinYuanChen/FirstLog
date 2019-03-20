//
//  ProfileViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/10.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var downloadUploadStackView: UIStackView!
    @IBOutlet weak var downloadRecordButton: UIButton!
    @IBOutlet weak var uploadRecordButton: UIButton!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var loginFBButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetUp(target: self)
        self.navigationItem.title = "Profile"
        // Do any additional setup after loading the view.
    }
    

   
    @IBAction func didTappedLoginWithFBButton(_ sender: Any) {
    }
    
    
    @IBAction func didTappedCreateAccountButton(_ sender: Any) {
    }
    
    
    @IBAction func didTappedDownloadRecordButton(_ sender: Any) {
    }
    
    @IBAction func didTappedUploadRecordButton(_ sender: Any) {
    }
    
}
