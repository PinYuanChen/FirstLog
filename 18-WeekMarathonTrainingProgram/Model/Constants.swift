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
let MAINVIEWRELOADDATA = "MainViewReloadData"

//MARK: - CoreData
var localDataManager:LocalDataManager!
var week = 0
var runSection = 0
var runRow = 0
var runningGoal = ""
   
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


//MARK: - Pace calculation
var (m,s) = (0,0)

//MARK: - Training program
let trainigProgram = [
    "Week1":[["400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m"],["5 km"],["16 km"]],
    "Week2":[["1200 m","1200 m","1200 m","1200 m"],["8 km"],["19 km"]],
    "Week3":[["800 m","800 m","800 m","800 m","800 m","800 m"],["11 km"],["21 km"]],
    "Week4":[["1600 m","1600 m","1600 m"],["5 km"],["16 km"]],
    "Week5":[["400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m"],["8 km"],["22 km"]],
    "Week6":[["1200 m","1200 m","1200 m","1200 m","1200 m"],["8 km"],["24 km"]],
    "Week7":[["800 m","800 m","800 m","800 m","800 m","800 m","800 m"],["13 km"],["27 km"]],
    "Week8":[["1600 m","1600 m","1600 m"],["16 km"],["21 km"]],
    "Week9":[["400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m"],["5 km"],["29 km"]],
    "Week10":[["800 m","800 m","800 m","800 m","800 m","800 m","800 m","800 m"],["8 km"],["24 km"]],
    "Week11":[["1600 m","1600 m","1600 m","1600 m"],["13 km"],["32 km"]],
    "Week12":[["400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m","400 m"],["8 km"],["24 km"]],
    "Week13":[["1200 m","1200 m","1200 m","1200 m","1200 m","1200 m"],["8 km"],["32 km"]],
    "Week14":[["800 m","800 m","800 m","800 m","800 m","800 m","800 m"],["6 km"],["24 km"]],
    "Week15":[["1600 m","1600 m","1600 m"],["13 km"],["16 km"]]
]

//MARK: - FAQ
let faqDict = [
    "About":[NSLocalizedString("ABOUT_QUESTION", comment: ""),NSLocalizedString("ABOUT_ANSWER", comment: "")]
]
