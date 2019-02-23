//
//  LocalDataManager.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/10.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import CoreData

class LocalDataManager:CoreDataManager<Program> {
    
    private(set) var programItemArray:[Program]?
    private(set) var programItem:Program?
    private(set) var runItem:Run?
    private(set) var locationItem:Location?
    
    static private(set) var shared:LocalDataManager?
    
    class func setAsSingleton(instance:LocalDataManager) {
        shared = instance
    }
    
    func checkProgramList() {
        if self.totalCount() > 0 {
            self.giveValue(toLocalData: (self.fetchItemAt(index: 0) as! Program))
        }
    }
    
    
    func giveValue(toLocalData:NSManagedObject) {
        switch toLocalData {
        case is Program:
            programItem = toLocalData as? Program
        case is Run:
            runItem = toLocalData as? Run
        case is Location:
            locationItem = toLocalData as? Location
        default:
            break
        }
    }

}
