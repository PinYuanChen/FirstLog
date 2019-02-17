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

