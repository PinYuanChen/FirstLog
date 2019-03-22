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
    @IBOutlet weak var createButton: UIButton!
    var rightSettingButton:UIBarButtonItem?
    let runDataManager = CoreDataManager<Run>(momdFilename: "ProgramModel", entityName: "Run", sortKey: "id")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = NSLocalizedString("FIRST_TIME_DESCRIPTION", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableviewSetUp()
        navigationSetUp(target: self)
        self.navigationItem.title = "FIRST Log"
        rightSettingButton = UIBarButtonItem(image: UIImage(named: "settingsline"), style: .plain, target: self, action: #selector(rightSettingButtonPressed))
        self.navigationItem.rightBarButtonItem = rightSettingButton
        self.navigationItem.rightBarButtonItem?.isEnabled = !tableview.isHidden
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTableView),
            name: Notification.Name(MAINVIEWRELOADDATA),
            object: nil)
    }
    
    
    func tableviewSetUp() {
        if localDataManager.totalCount() != 0 {
            tableview.isHidden = false
            createButton.isHidden = true
        } else {
            tableview.isHidden = true
            createButton.isHidden = false
            createButton.setTitle("Start", for: .normal)
        }
    }
    
    @IBAction func didTappedCreateButton(_ sender: Any) {
        let paceCalculationViewController = storyboard?.instantiateViewController(withIdentifier: "PaceCalculationNavigationController") as! UINavigationController
        self.present(paceCalculationViewController, animated: true, completion: nil)
    }
    
    @objc func refreshTableView() {
        localDataManager.checkProgramList()
        self.tableview.reloadData()
    }
    
    @objc func rightSettingButtonPressed() {
        let paceResultViewController = storyboard?.instantiateViewController(withIdentifier: "PaceResultNavigationController") as! UINavigationController
        self.present(paceResultViewController, animated: true, completion: nil)
    }
    
    //MARK: - Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgramListCell", for: indexPath) as! ProgramListTableViewCell
        cell.selectionStyle = .none
        cell.weekLabel.text = "Week \(indexPath.row + 1)"
        let completion = getCompleteStatus(week: "Week\(indexPath.row+1)", runManager: runDataManager)
        cell.programStatus.text = "\(completion)%"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let weeklyTrainingViewController = storyboard?.instantiateViewController(withIdentifier: "WeeklyTrainingViewController") as! WeeklyTrainingViewController
        weeklyTrainingViewController.trainingArray = trainigProgram["Week\(indexPath.row + 1)"]
        week = indexPath.row + 1
        self.navigationController?.pushViewController(weeklyTrainingViewController, animated: true)
    }
}

