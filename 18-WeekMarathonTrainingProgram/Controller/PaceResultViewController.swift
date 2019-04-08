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
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var shortTempoRunTitile: UILabel!
    @IBOutlet weak var midTempoRunTitle: UILabel!
    @IBOutlet weak var longTempoRunTitle: UILabel!
    @IBOutlet weak var longRunTitle: UILabel!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        navigationSetUp(target: self)
        self.navigationItem.title = NSLocalizedString("PACE_RESULT_TITLE", comment: "")
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
        if sender.titleLabel?.text == NSLocalizedString("DELETE", comment: "") {
            if let item = localDataManager.fetchItemAt(index: 0){
                
                localDataManager.deleteItem(item: item)
                localDataManager.saveContext(completion: { (success) in
                    NotificationCenter.default.post(name: Notification.Name(MAINVIEWRELOADDATA), object: nil)
                })
                localDataManager.clearDatabase(entity: "Run")
                localDataManager.clearDatabase(entity: "Location")
                localDataManager.saveContext (completion:nil)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func loadData() {
        confirmButton.setTitle(NSLocalizedString("CONFIRM", comment: ""), for: .normal)
        cancelButton.setTitle(NSLocalizedString("CANCEL", comment: ""), for: .normal)
        if localDataManager.totalCount() != 0 {
            giveValueToDetailResult()
            cancelButton.setTitle(NSLocalizedString("DELETE", comment: ""), for: .normal)
        }
        //set up pace range
        pace400mLabel.text = paceRange(fast: fast400m, slow: slow400m)
        pace800mLabel.text = paceRange(fast: fast800m, slow: slow800m)
        pace1200mLabel.text = paceRange(fast: fast1200m, slow: slow1200m)
        pace1600mLabel.text = paceRange(fast: fast1600m, slow: slow1600m)
        shortTempoRunLabel.text = paceRange(fast: shortTempoRun, slow: shortTempoRun)
        midTempoRunLabel.text = paceRange(fast: fastMidTempo, slow: slowMidTempo)
        longTempoRunLabel.text = paceRange(fast: fastLongTempo, slow: slowLongTempo)
        longRunLabel.text = paceRange(fast: fastLongRun, slow: slowLongRun)
        
        //set up label title
        shortTempoRunTitile.text = NSLocalizedString("SHORT_TEMPO_RUN", comment: "")
        midTempoRunTitle.text = NSLocalizedString("MID_TEMPO_RUN", comment: "")
        longTempoRunTitle.text = NSLocalizedString("LONG_TEMPO_RUN", comment: "")
        longRunTitle.text = NSLocalizedString("LONG_RUN", comment: "")
    }
}
