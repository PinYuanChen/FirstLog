//
//  HelperFunctions.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/1/26.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

public func navigationSetUp(target:UIViewController) {
    target.navigationController?.navigationBar.barTintColor = NAVIGATIONBARCOLOR
    target.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    target.navigationController?.navigationBar.tintColor = .white
    target.navigationController?.navigationBar.layer.masksToBounds = false
    target.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
    target.navigationController?.navigationBar.layer.shadowOpacity = 0.8
    target.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    target.navigationController?.navigationBar.layer.shadowRadius = 2
}

func getCompleteStatus(week:String, runManager:CoreDataManager<Run>) -> Int {
    let trainingAry:[[String]] = trainigProgram[week]!
    var totalCount = 0
    var completeCount = 0
    for training in trainingAry {
        totalCount += training.count
    }
    if let result = runManager.searchBy(keyword: week, field: "week"){
        guard result != [] else {
           return 0
        }
        for item in result {
            if item.complete {
               completeCount += 1
            }
        }
    }
    if completeCount > 0 {
        return Int((Double(completeCount) * 100 / Double(totalCount)).rounded())
    } else {
        return 0
    }
}

func paceCalculator(hour:Int, minute:Int, second:Int, distance:Int) {
    (m,s) = secondsToMinutesSeconds(seconds:(hour+minute+second)/distance)
    
    let pace10k = (m*60)+s
    fast400m = pace10k - 60
    slow400m = pace10k - 55
    
    fast800m = pace10k - 50
    slow800m = pace10k - 45
    
    fast1200m = pace10k - 45
    slow1200m = pace10k - 40
    
    fast1600m = pace10k - 40
    slow1600m = pace10k - 35
    
    shortTempoRun = pace10k
    fastMidTempo = pace10k + 15
    slowMidTempo = pace10k + 20
    fastLongTempo = pace10k + 30
    slowLongTempo = pace10k + 35
    fastLongRun = pace10k + 60
    slowLongRun = pace10k + 75
}

func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
    return ((seconds % 3600) / 60, (seconds % 3600) % 60)
}

func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}

func giveValueToDetailResult() {
    fast400m = Int(localDataManager.programItem!.fast400m)
    slow400m = Int(localDataManager.programItem!.slow400m)
    fast800m = Int(localDataManager.programItem!.fast800m)
    slow800m = Int(localDataManager.programItem!.slow800m)
    fast1200m = Int(localDataManager.programItem!.fast1200m)
    slow1200m = Int(localDataManager.programItem!.slow1200m)
    fast1600m = Int(localDataManager.programItem!.fast1600m)
    slow1600m = Int(localDataManager.programItem!.slow1600m)
    shortTempoRun = Int(localDataManager.programItem!.slowshorttempo)
    fastMidTempo = Int(localDataManager.programItem!.fastmidtempo)
    slowMidTempo = Int(localDataManager.programItem!.slowmidtempo)
    fastLongTempo = Int(localDataManager.programItem!.fastlongtempo)
    slowLongTempo = Int(localDataManager.programItem!.slowlongtempo)
    fastLongRun = Int(localDataManager.programItem!.fastlongrun)
    slowLongRun = Int(localDataManager.programItem!.slowlongrun)
}

func paceRange(fast:Int,slow:Int) -> String {
    let (fm,fs) = secondsToMinutesSeconds(seconds: fast)
    let (sm,ss) = secondsToMinutesSeconds(seconds: slow)
    let resultString = "\(fm)\(NSLocalizedString("MINUTE", comment: "")) \(fs)\(NSLocalizedString("SECOND", comment: "")) - \(sm)\(NSLocalizedString("MINUTE", comment: "")) \(ss)\(NSLocalizedString("SECOND", comment: ""))"
    return resultString
}

func getTargetPace(distance:Int) -> String {
    giveValueToDetailResult()
    switch distance {
    case 400:
        return paceRange(fast: fast400m, slow: slow400m)
    case 800:
        return paceRange(fast: fast800m, slow: slow800m)
    case 1200:
        return paceRange(fast: fast1200m, slow: slow1200m)
    case 1600:
        return paceRange(fast: fast1600m, slow: slow1600m)
    case 5000:
        return paceRange(fast: shortTempoRun, slow: shortTempoRun)
    case 8000,
         11000:
        return paceRange(fast: fastMidTempo, slow: slowMidTempo)
    case 13000,
         16000:
        return paceRange(fast: fastLongTempo, slow: slowLongTempo)
    case 19000,
         21000,
         22000,
         24000,
         27000,
         29000,
         32000:
        return paceRange(fast: fastLongRun, slow: slowLongRun)
    default:
        return ""
    }
}

func checkCompletion(distance:Int, workoutPace:Int) -> Bool{
    switch distance {
    case 400:
        return workoutPace < slow400m
    case 800:
        return workoutPace < slow800m
    case 1200:
        return workoutPace < slow1200m
    case 1600:
        return workoutPace < slow1600m
    case 5000:
        return workoutPace < shortTempoRun
    case 8000,
         11000:
        return workoutPace < slowMidTempo
    case 13000,
         16000:
        return workoutPace < slowLongTempo
    case 19000,
         21000,
         22000,
         24000,
         27000,
         29000,
         32000:
        return workoutPace < slowLongRun
    default:
        return false
    }
}
