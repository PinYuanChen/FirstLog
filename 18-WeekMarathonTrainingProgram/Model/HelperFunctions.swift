//
//  HelperFunctions.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/1/26.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit


func paceCalculator(hour:Int, minute:Int, second:Int, distance:Int) -> paceDetail{
    var paceResult = paceDetail()
    (m,s) = secondsToMinutesSeconds(seconds:(hour+minute+second)/distance)
    
    let pace10k = (m*60)+s
    paceResult.fast400m = pace10k - 60
    paceResult.slow400m = pace10k - 55
    
    paceResult.fast800m = pace10k - 50
    paceResult.slow800m = pace10k - 45
    
    paceResult.fast1200m = pace10k - 45
    paceResult.slow1200m = pace10k - 40
    
    paceResult.fast1600m = pace10k - 40
    paceResult.slow1600m = pace10k - 35
    
    paceResult.shortTempoRun = pace10k
    paceResult.fastMidTempo = pace10k + 15
    paceResult.slowMidTempo = pace10k + 20
    paceResult.fastLongTempo = pace10k + 30
    paceResult.slowLongTempo = pace10k + 35
    paceResult.fastLongRun = pace10k + 60
    paceResult.slowLongRun = pace10k + 75
    
    return paceResult
}

func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
    return ((seconds % 3600) / 60, (seconds % 3600) % 60)
}

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}
