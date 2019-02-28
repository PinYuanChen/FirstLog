//
//  WeeklyTrainingViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/20.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import CoreData

class WeeklyTrainingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var trainingArray:[[String]]?
    let runDataManager = CoreDataManager<Run>(momdFilename: "ProgramModel", entityName: "Run", sortKey: "id")
    let locationManager = CoreDataManager<Location>(momdFilename: "ProgramModel", entityName: "Location", sortKey: "id")
    var idString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return trainingArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "DAY\(section+1)"
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
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard localDataManager.checkRunData(runManager: runDataManager, key: idString) != (false,false) else {
            let newRunViewController = storyboard?.instantiateViewController(withIdentifier: "NewRunNavigationController") as! UINavigationController
            self.present(newRunViewController, animated: true, completion: nil)
            return
        }
        
        guard localDataManager.checkLocationData(locationManager: locationManager, key: idString) else {
            return
        }
        
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
            request.predicate = NSPredicate(format: "id == %@", idString)
            let requestRun = try localDataManager.runItem?.managedObjectContext?.fetch(request) as! [Run]
            let newRunViewController = storyboard?.instantiateViewController(withIdentifier: "NewRunViewController") as! NewRunViewController
            newRunViewController.hasRecord = true
            self.navigationController?.pushViewController(newRunViewController, animated: true)
        } catch {
            print("There is no existing track.")
        }
    }

}
