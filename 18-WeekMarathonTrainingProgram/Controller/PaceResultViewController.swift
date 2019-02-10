//
//  PaceResultViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/1/26.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class PaceResultViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTappedConfirmBtn(_ sender: UIButton) {
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
        self.present(mainVC, animated: true, completion: nil)
    }
    
    
}
