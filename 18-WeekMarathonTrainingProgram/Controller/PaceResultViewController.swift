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
    var detailResult = paceDetail()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTappedConfirmBtn(_ sender: UIButton) {
        //create new program item
        editProgram(originalItem: nil) { (success, item) in
            guard success == true else {
                return
            }
            localDataManager.saveContext(completion: { (success) in
                if success {
                    NSLog("Save!")
                } else {
                    NSLog("Fail to save!")
                }
            })
        }
        //edit existing item
    }
    
    func loadData() {
        pace400mLabel.text = paceRange(fast: detailResult.fast400m, slow: detailResult.slow400m)
        pace800mLabel.text = paceRange(fast: detailResult.fast800m, slow: detailResult.slow800m)
        pace1200mLabel.text = paceRange(fast: detailResult.fast1200m, slow: detailResult.slow1200m)
        pace1600mLabel.text = paceRange(fast: detailResult.fast1600m, slow: detailResult.slow1600m)
        shortTempoRunLabel.text = paceRange(fast: detailResult.shortTempoRun, slow: detailResult.shortTempoRun)
        midTempoRunLabel.text = paceRange(fast: detailResult.fastMidTempo, slow: detailResult.slowMidTempo)
        longTempoRunLabel.text = paceRange(fast: detailResult.fastLongTempo, slow: detailResult.slowLongTempo)
        longRunLabel.text = paceRange(fast: detailResult.fastLongRun, slow: detailResult.slowLongRun)
    }
    
    func paceRange(fast:Int,slow:Int) -> String {
        let (fm,fs) = secondsToMinutesSeconds(seconds: fast)
        let (sm,ss) = secondsToMinutesSeconds(seconds: slow)
        let resultString = "\(fm)\(NSLocalizedString("MINUTE", comment: "")) \(fs)\(NSLocalizedString("SECOND", comment: "")) - \(sm)\(NSLocalizedString("MINUTE", comment: "")) \(ss)\(NSLocalizedString("SECOND", comment: ""))"
        return resultString
    }
    
    //MARK: - Core Data
    typealias EditDoneHandler = (_ success:Bool,_ resultItem:Program?) -> Void
    func editProgram(originalItem:Program?,completion:@escaping EditDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            finalItem = localDataManager.createItem()
//            finalItem?.id = "run"
        }
        
        completion(true,finalItem)
    }
    
}
