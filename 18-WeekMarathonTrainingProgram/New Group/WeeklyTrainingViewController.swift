//
//  WeeklyTrainingViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/20.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import CoreData

class WeeklyTrainingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableview: UITableView!
    var trainingArray:[[String]]?
    let runDataManager = CoreDataManager<Run>(momdFilename: "ProgramModel", entityName: "Run", sortKey: "id")
    let locationDataManager = CoreDataManager<Location>(momdFilename: "ProgramModel", entityName: "Location", sortKey: "id")
    var idString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self
            , selector: #selector(reloadData), name: Notification.Name("reloadData"), object: nil)
    }
    
    @objc func reloadData() {
       self.tableview.reloadData()
    }
    
    //MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return trainingArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dayTrain(day: section+1)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard trainingArray?.count != 0 else {
            return 0
        }
        return trainingArray![section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyTrainingTableViewCell", for: indexPath) as! WeeklyTrainingTableViewCell
        cell.distanceLabel.text = trainingArray?[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        
        runSection = indexPath.section
        runRow = indexPath.row
        idString = "\(week)\(runSection)\(runRow)"
        
        if localDataManager.checkRunData(runManager: runDataManager, key: idString) == (true,true) {
            cell.checkImageView.image = UIImage(named: "checked")
        } else if localDataManager.checkRunData(runManager: runDataManager, key: idString) == (true,false){
            cell.checkImageView.image = UIImage(named: "close")
        } else {
            cell.checkImageView.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        runningGoal = trainingArray?[indexPath.section][indexPath.row] as! String
        
        runSection = indexPath.section
        runRow = indexPath.row
        idString = "\(week)\(runSection)\(runRow)"
        let (hasRecord,complete) = localDataManager.checkRunData(runManager: runDataManager, key: idString)
        guard (hasRecord,complete) != (false,false) else {
            let newRunViewController = storyboard?.instantiateViewController(withIdentifier: "NewRunNavigationController") as! UINavigationController
            self.present(newRunViewController, animated: true, completion: nil)
            return
        }
        
        guard localDataManager.checkLocationData(locationManager: locationDataManager, key: idString) else {
            return
        }
        
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
            request.predicate = NSPredicate(format: "id == %@", idString)
            let requestRun = try localDataManager.runItem?.managedObjectContext?.fetch(request) as! [Run]
            let newRunViewController = storyboard?.instantiateViewController(withIdentifier: "NewRunViewController") as! NewRunViewController
            newRunViewController.requestRun = requestRun
            newRunViewController.hasRecord = hasRecord
            newRunViewController.complete = complete
            let newRunNavigationController = UINavigationController.init(rootViewController: newRunViewController)
            self.present(newRunNavigationController, animated: true, completion: nil)
        } catch {
            print("There is no existing track.")
        }
    }
    
    func dayTrain(day:Int) -> String {
        let dayString = NSLocalizedString("DAY", comment: "")
        return dayString.replacingOccurrences(of: "{0}", with: "\(day)")
    }

}
