//
//  MainViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/10.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    var roundButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = NSLocalizedString("FIRST_TIME_DESCRIPTION", comment: "")
        tableviewSetUp()
        navigationSetUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createFloatingButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if roundButton.superview != nil {
            DispatchQueue.main.async {
                self.roundButton.removeFromSuperview()
            }
        }
    }
    
    func tableviewSetUp() {
//        if localDataManager.totalCount() != 0 {
            tableview.separatorColor = .clear
//        } else {
//            tableview.isHidden = true
//        }
    
    }
    
    func navigationSetUp() {
        
        self.navigationController?.navigationBar.barTintColor = NAVIGATIONBARCOLOR
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.title = "FIRST Log"
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
        
    }
    
    func createFloatingButton() {
        
        roundButton = UIButton(type: .custom)
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        roundButton.backgroundColor = NAVIGATIONBARCOLOR
        roundButton.addTarget(self, action: #selector(didTappedAddButton), for: UIControl.Event.touchUpInside)
        
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.addSubview(self.roundButton)
                NSLayoutConstraint.activate([
                    keyWindow.trailingAnchor.constraint(equalTo: self.roundButton.trailingAnchor, constant: 15),
                    keyWindow.bottomAnchor.constraint(equalTo: self.roundButton.bottomAnchor, constant: self.view.safeAreaInsets.bottom + 20.0),
                    self.roundButton.widthAnchor.constraint(equalToConstant: 64),
                    self.roundButton.heightAnchor.constraint(equalToConstant: 64)])
            }
            
            self.roundButton.layer.cornerRadius = 37.5
            self.roundButton.layer.shadowColor = UIColor.black.cgColor
            self.roundButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
            self.roundButton.layer.masksToBounds = false
            self.roundButton.layer.shadowRadius = 2.0
            self.roundButton.layer.shadowOpacity = 0.5
            self.roundButton.setImage(UIImage(named: "plus"), for: .normal)

        }
        
    }
    
    //MARK: - Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localDataManager.totalCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgramListCell", for: indexPath) as! ProgramListTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    @objc func didTappedAddButton() {
        let paceCalculationViewController = storyboard?.instantiateViewController(withIdentifier: "PaceCalculationNavigationController") as! UINavigationController
        self.present(paceCalculationViewController, animated: true, completion: nil)
    }
}

