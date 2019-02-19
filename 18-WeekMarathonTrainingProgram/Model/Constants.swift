//
//  Constants.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/1/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

//MARK: - UI
let NAVIGATIONBARCOLOR = UIColor(red: CGFloat(36.0/255.0), green: CGFloat(176.0/255.0), blue: CGFloat(235.0/255.0), alpha: CGFloat(1.0))

//MARK: - CoreData
var localDataManager:LocalDataManager!

struct paceDetail {
    
    var fast400m = 0
    var slow400m = 0
    var fast800m = 0
    var slow800m = 0
    var fast1200m = 0
    var slow1200m = 0
    var fast1600m = 0
    var slow1600m = 0
    var shortTempoRun = 0
    var fastMidTempo = 0
    var slowMidTempo = 0
    var fastLongTempo = 0
    var slowLongTempo = 0
    var fastLongRun = 0
    var slowLongRun = 0
    
}

//MARK: - Pace calculation
var (m,s) = (0,0)

//MARK: - Training program
let trainigProgram = [
    "Week1":[["400m","400m","400m","400m","400m","400m","400m","400m"],["5km"],["16km"]],
    "Week2":[["1200m","1200m","1200m","1200m"],["8km"],["19km"]],
    "Week3":[["800m","800m","800m","800m","800m","800m"],["11km"],["21km"]],
    "Week4":[["1600m","1600m","1600m"],["5km"],["16km"]],
    "Week5":[["400m","400m","400m","400m","400m","400m","400m","400m","400m","400m"],["8km"],["22km"]],
    "Week6":[["1200m","1200m","1200m","1200m","1200m"],["8km"],["24km"]],
    "Week7":[["800m","800m","800m","800m","800m","800m","800m"],["13km"],["27km"]],
    "Week8":[["1600m","1600m","1600m"],["16km"],["21km"]],
    "Week9":[["400m","400m","400m","400m","400m","400m","400m","400m","400m","400m","400m","400m"],["5km"],["29km"]],
    "Week10":[["800m","800m","800m","800m","800m","800m","800m","800m"],["8km"],["24km"]],
    "Week11":[["1600m","1600m","1600m","1600m"],["13km"],["32km"]],
    "Week12":[["400m","400m","400m","400m","400m","400m","400m","400m","400m","400m","400m","400m"],["8km"],["24km"]],
    "Week13":[["1200m","1200m","1200m","1200m","1200m","1200m"],["8km"],["32km"]],
    "Week14":[["800m","800m","800m","800m","800m","800m","800m"],["6km"],["24km"]],
    "Week15":[["1600m","1600m","1600m"],["13km"],["16km"]]
]
