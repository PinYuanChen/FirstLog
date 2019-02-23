//
//  WeeklyTrainingViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/20.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class WeeklyTrainingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var trainingArray:[[String]]?

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
        return cell
    }

}
