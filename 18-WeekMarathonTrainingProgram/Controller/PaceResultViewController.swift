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
    var programName:String?
    @IBOutlet weak var cancelButton: UIButton!
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
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
        }
        dismiss(animated: true, completion: nil)
    }
    
    func loadData() {
        
        if localDataManager.totalCount() != 0 {
            giveValueToDetailResult()
            cancelButton.setTitle("Delete", for: .normal)
        }
        
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
            finalItem?.creationdate = NSDate() as Date
        }
        finalItem?.fast400m = Int32(detailResult.fast400m)
        finalItem?.slow400m = Int32(detailResult.slow400m)
        finalItem?.fast800m = Int32(detailResult.fast800m)
        finalItem?.slow800m = Int32(detailResult.slow800m)
        finalItem?.fast1200m = Int32(detailResult.fast1200m)
        finalItem?.slow1200m = Int32(detailResult.slow1200m)
        finalItem?.fast1600m = Int32(detailResult.fast1600m)
        finalItem?.slow1600m = Int32(detailResult.slow1600m)
        finalItem?.slowshorttempo = Int32(detailResult.shortTempoRun)
        finalItem?.fastmidtempo = Int32(detailResult.fastMidTempo)
        finalItem?.slowmidtempo = Int32(detailResult.slowMidTempo)
        finalItem?.fastlongtempo = Int32(detailResult.fastLongTempo)
        finalItem?.slowlongtempo = Int32(detailResult.slowLongTempo)
        finalItem?.fastlongrun = Int32(detailResult.fastLongRun)
        finalItem?.slowlongrun = Int32(detailResult.slowLongRun)
        
        completion(true,finalItem)
    }
    
    func giveValueToDetailResult() {
        detailResult.fast400m = Int(localDataManager.programItem!.fast400m)
        detailResult.slow400m = Int(localDataManager.programItem!.slow400m)
        detailResult.fast800m = Int(localDataManager.programItem!.fast800m)
        detailResult.slow800m = Int(localDataManager.programItem!.slow800m)
        detailResult.fast1200m = Int(localDataManager.programItem!.fast1200m)
        detailResult.slow1200m = Int(localDataManager.programItem!.slow1200m)
        detailResult.fast1600m = Int(localDataManager.programItem!.fast1600m)
        detailResult.slow1600m = Int(localDataManager.programItem!.slow1600m)
        detailResult.shortTempoRun = Int(localDataManager.programItem!.slowshorttempo)
        detailResult.fastMidTempo = Int(localDataManager.programItem!.fastmidtempo)
        detailResult.slowMidTempo = Int(localDataManager.programItem!.slowmidtempo)
        detailResult.fastLongTempo = Int(localDataManager.programItem!.fastlongtempo)
        detailResult.slowLongTempo = Int(localDataManager.programItem!.slowlongtempo)
        detailResult.fastLongRun = Int(localDataManager.programItem!.fastlongrun)
        detailResult.slowLongRun = Int(localDataManager.programItem!.slowlongrun)
    }
}
