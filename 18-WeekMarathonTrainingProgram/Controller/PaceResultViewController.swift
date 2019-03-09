//
//  PaceResultViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/1/26.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class PaceResultViewController: UIViewController {
    
    @IBOutlet weak var pace400mLabel: UILabel!
    @IBOutlet weak var pace800mLabel: UILabel!
    @IBOutlet weak var pace1200mLabel: UILabel!
    @IBOutlet weak var pace1600mLabel: UILabel!
    @IBOutlet weak var shortTempoRunLabel: UILabel!
    @IBOutlet weak var midTempoRunLabel: UILabel!
    @IBOutlet weak var longTempoRunLabel: UILabel!
    @IBOutlet weak var longRunLabel: UILabel!
    var programName:String?
    @IBOutlet weak var cancelButton: UIButton!
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        navigationSetUp()
    }
    
    func navigationSetUp() {
        
        self.navigationController?.navigationBar.barTintColor = NAVIGATIONBARCOLOR
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
    }
    
    @IBAction func didTappedConfirmBtn(_ sender: UIButton) {
        //create new program item
        if localDataManager.totalCount() != 0 {
            dismiss(animated: true, completion: nil)
            return
        }
    
        editProgram(originalItem: nil) { (success, item) in
            guard success == true else {
                return
            }
            localDataManager.giveValue(toLocalData: item!)
            localDataManager.saveContext(completion: { (success) in
                if success {
                    NSLog("Save!")
                    self.dismiss(animated: true, completion: nil)
                    //send notification to reload data
                    NotificationCenter.default.post(name: Notification.Name(MAINVIEWRELOADDATA), object: nil)
                } else {
                    NSLog("Fail to save!")
                }
            })
        }
    }
    
    @IBAction func didTappedCancelBtn(_ sender: UIButton) {
        if sender.titleLabel?.text == "Delete" {
            if let item = localDataManager.fetchItemAt(index: 0){
                
                localDataManager.deleteItem(item: item)
                localDataManager.saveContext(completion: { (success) in
                    NotificationCenter.default.post(name: Notification.Name(MAINVIEWRELOADDATA), object: nil)
                })
            }
            localDataManager.clearDatabase(entity: "Run")
            localDataManager.clearDatabase(entity: "Location")
            localDataManager.saveContext (completion:nil)
            dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }

    }
    
    func loadData() {
        if localDataManager.totalCount() != 0 {
            giveValueToDetailResult()
            cancelButton.setTitle("Delete", for: .normal)
        }
        pace400mLabel.text = paceRange(fast: fast400m, slow: slow400m)
        pace800mLabel.text = paceRange(fast: fast800m, slow: slow800m)
        pace1200mLabel.text = paceRange(fast: fast1200m, slow: slow1200m)
        pace1600mLabel.text = paceRange(fast: fast1600m, slow: slow1600m)
        shortTempoRunLabel.text = paceRange(fast: shortTempoRun, slow: shortTempoRun)
        midTempoRunLabel.text = paceRange(fast: fastMidTempo, slow: slowMidTempo)
        longTempoRunLabel.text = paceRange(fast: fastLongTempo, slow: slowLongTempo)
        longRunLabel.text = paceRange(fast: fastLongRun, slow: slowLongRun)
    }

    //MARK: - Core Data
    typealias EditDoneHandler = (_ success:Bool,_ resultItem:Program?) -> Void
    func editProgram(originalItem:Program?,completion:@escaping EditDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            finalItem = localDataManager.createItem()
            finalItem?.creationdate = NSDate() as Date
        }
        finalItem?.fast400m = Int32(fast400m)
        finalItem?.slow400m = Int32(slow400m)
        finalItem?.fast800m = Int32(fast800m)
        finalItem?.slow800m = Int32(slow800m)
        finalItem?.fast1200m = Int32(fast1200m)
        finalItem?.slow1200m = Int32(slow1200m)
        finalItem?.fast1600m = Int32(fast1600m)
        finalItem?.slow1600m = Int32(slow1600m)
        finalItem?.slowshorttempo = Int32(shortTempoRun)
        finalItem?.fastmidtempo = Int32(fastMidTempo)
        finalItem?.slowmidtempo = Int32(slowMidTempo)
        finalItem?.fastlongtempo = Int32(fastLongTempo)
        finalItem?.slowlongtempo = Int32(slowLongTempo)
        finalItem?.fastlongrun = Int32(fastLongRun)
        finalItem?.slowlongrun = Int32(slowLongRun)
        
        completion(true,finalItem)
    }
}
