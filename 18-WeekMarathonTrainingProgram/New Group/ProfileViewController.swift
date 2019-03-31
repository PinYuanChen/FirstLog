//
//  ProfileViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/10.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import Charts

enum Result {
    case success
    case fail
}

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var downloadUploadStackView: UIStackView!
    @IBOutlet weak var downloadRecordButton: UIButton!
    @IBOutlet weak var uploadRecordButton: UIButton!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginFBButton: UIButton!
    var isLogin = false
    @IBOutlet weak var pieChartView: PieChartView!
    var finishedValue = PieChartDataEntry(value:0)
    var unfinishedValue = PieChartDataEntry(value:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetUp(target: self)
        self.navigationItem.title = "Profile"
        // Do any additional setup after loading the view.
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pieChartView.chartDescription?.text = ""
        loadPieChartData()
    }
    
    func fetchProfile() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "email, first_name, last_name, id, gender, picture.type(large)"])
            .start(completionHandler:  {
                (connection, result, error) in
                
                guard
                    let result = result as? NSDictionary,
                    let picture = result["picture"]  as? NSDictionary,
                    let data = picture["data"] as? NSDictionary,
                    let picURL = data["url"] as? String
                    else {
                        return
                }
                if let userImageURL = URL(string: picURL) {
                    if let userImageData = NSData(contentsOf: userImageURL) as Data? {
                        self.isLogin = true
                        self.avatarImageView.image = UIImage(data: userImageData)
                        self.avatarImageView.layer.cornerRadius = 50
                        self.avatarImageView.layer.masksToBounds = true
                        self.loginStackView.isHidden = self.isLogin
                        self.downloadUploadStackView.isHidden = !self.isLogin
                    }
                }
            })
    }

   
    @IBAction func didTappedLoginWithFBButton(_ sender: UIButton) {
        facebookLogin(sender: sender)
    }
    
    @IBAction func didTappedLogoutButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            FBSDKLoginManager().logOut()
            UserDefaults.standard.removeObject(forKey: "uid")
            self.isLogin = false
            self.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func didTappedDownloadRecordButton(_ sender: Any) {
        checkFirebaseDataExist()
    }
    
    @IBAction func didTappedUploadRecordButton(_ sender: Any) {
        guard let uploadDict = prepareUploadData() else {
            let alert = UIAlertController(title: "No data exist", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Confirm", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let uploadData = try? JSONSerialization.data(withJSONObject: uploadDict, options: .prettyPrinted) else{
            return
        }
        guard let uidString:String = UserDefaults.standard.object(forKey: "uid") as? String else {
            return
        }
        let databaseRef = Database.database().reference().child(uidString)
        let storageRef = Storage.storage().reference().child(uidString)
        
        let uploadtask = storageRef.putData(uploadData, metadata: nil)
        uploadtask.observe(.success){(snapshot) in
            //database的參照
            if let dataURL = snapshot.metadata?.downloadURL()?.absoluteString{
                let post: [String:Any] = ["data": dataURL]
                databaseRef.setValue(post)
            }
            let alert = UIAlertController(title: "資料備份成功!", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func reloadData () {
        loginStackView.isHidden = isLogin
        downloadUploadStackView.isHidden = !isLogin
        
        if FBSDKAccessToken.current() != nil {
            fetchProfile()
        }else{
            avatarImageView.image = UIImage(named: "avatarPlaceholder")
        }
    }
    
    func loadPieChartData() {
        var finishCount = 0.0
        guard let runs = localDataManager.programItem?.run?.allObjects as? [Run] else {
            self.updateChartData(finishedCount: 0.0)
            return
        }
        for run in runs {
            if run.complete == true {
                finishCount+=1
            }
        }
        updateChartData(finishedCount: finishCount)
    }
    
    func updateChartData(finishedCount:Double) {
        finishedValue.value = finishedCount
        finishedValue.label = "finished"
        
        unfinishedValue.value = 128.0 - finishedCount
        unfinishedValue.label = "unfinished"
        
        let numberOfFinishedDataEntries = [finishedValue, unfinishedValue]
        let chartDataSet = PieChartDataSet(values: numberOfFinishedDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [UIColor(red: 242/255, green: 159/255, blue: 183/255, alpha: 1), UIColor(red: 146/255, green: 204/255, blue: 250/255, alpha: 1)]
        chartDataSet.colors = colors as! [NSUIColor]
        pieChartView.data = chartData
    }
    
    //MARK: - FB login
    func facebookLogin(sender: UIButton) {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                UserDefaults.standard.set(user?.uid, forKey: "uid")
                DispatchQueue.main.async {
                    self.isLogin = true
                    self.reloadData()
                }
            })
        }
    }
    
    //MARK: - Upload
    func prepareUploadData() -> Dictionary<String, Any>? {
        var programDict = [String:Any]()
        var runDict = [String : Any]()
        var runDictArray = [runDict]
        var locationDict = [String : Any]()
        var locationDictArray = [locationDict]
        
        guard let program = localDataManager.programItem else {
            return nil
        }
        guard let runs = localDataManager.programItem?.run?.allObjects as? [Run] else {
            return nil
        }
        for run in runs {
            runDict["complete"] = run.complete
            runDict["distance"] = run.distance
            runDict["duration"] = run.duration
            runDict["id"] = run.id
            runDict["pace"] = run.pace
            runDict["week"] = run.week
            if let locations = run.location?.allObjects as? [Location] {
                for location in locations {
                    locationDict["id"] = location.id
                    locationDict["latitude"] = location.latitude
                    locationDict["longitude"] = location.longitude
                    locationDict["order"] = location.order
                    locationDictArray.append(locationDict)
                }
                runDict["location"] = locationDictArray
            }
            runDictArray.append(runDict)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = program.creationdate as? Date {
            programDict["creationdate"] = formatter.string(from: date)
        }
        programDict["fast400m"] = program.fast400m
        programDict["slow400m"] = program.slow400m
        programDict["fast800m"] = program.fast800m
        programDict["slow800m"] = program.slow800m
        programDict["fast1200m"] = program.fast1200m
        programDict["slow1200m"] = program.slow1200m
        programDict["fast1600m"] = program.fast1600m
        programDict["slow1600m"] = program.slow1600m
        programDict["slowshorttempo"] = program.slowshorttempo
        programDict["fastmidtempo"] = program.fastmidtempo
        programDict["slowmidtempo"] = program.slowmidtempo
        programDict["fastlongtempo"] = program.fastlongtempo
        programDict["slowlongtempo"] = program.slowlongtempo
        programDict["fastlongrun"] = program.fastlongrun
        programDict["slowlongrun"] = program.slowlongrun
        programDict["run"] = runDictArray
        
        return programDict
    }
    
    //MARK: - Download
    func checkFirebaseDataExist() {
        guard let uidString:String = UserDefaults.standard.object(forKey: "uid") as? String else {
            return
        }
        let databaseRef = Database.database().reference().child(uidString)
        databaseRef.observe(.value, with: { (snapshot) in
            if let downloadDict = snapshot.value as? [String:Any] {
                print(downloadDict)
                guard let downloadString = downloadDict["data"] as? String else {
                    return
                }
                let alert = UIAlertController(title: "Notice", message: "Your download record might overwrite your local record. Are you sure you want to continue?", preferredStyle: .alert)
                let okBtn = UIAlertAction(title: "Confirm", style: .default) { _ in
                    self.removeExistLocalData()
                    self.downloadFirebaseRecord(urlString: downloadString)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(okBtn)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                
            }else{
                let alert = UIAlertController(title: "No data exist", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Confirm", style: .cancel, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func downloadFirebaseRecord(urlString:String) {
        if let downloadURL = URL(string:urlString) {
            URLSession.shared.dataTask(with: downloadURL, completionHandler: { [weak self](data, response, error) in
                if error != nil {
                    print("Download Task Fail: \(error!.localizedDescription)")
                }
                if let downloadData = data {
                    DispatchQueue.main.sync {
                        guard let response = try? JSONSerialization.jsonObject(with: downloadData, options: .mutableContainers) else {
                            return
                        }
                        if let responseDict = response as? NSDictionary {
                           self?.saveProgramToCoreData(dataDict: responseDict)
                        }
                    }
                }
            }).resume()
        }
    }
    
    func removeExistLocalData() {
        if localDataManager.totalCount() > 0{
            if let item = localDataManager.fetchItemAt(index: 0) {
                localDataManager.deleteItem(item: item)
                localDataManager.saveContext(completion: { (success) in
                    NotificationCenter.default.post(name: Notification.Name(MAINVIEWRELOADDATA), object: nil)
                })
                localDataManager.clearDatabase(entity: "Run")
                localDataManager.clearDatabase(entity: "Location")
                localDataManager.saveContext (completion:nil)
            }
        }
    }
    
    func saveProgramToCoreData(dataDict:NSDictionary) {
        print(dataDict)
        editProgram(originalItem: nil, dic: dataDict) { (success, item) in
            guard success == true else {
                return
            }
            localDataManager.giveValue(toLocalData: item!)
            do {
                giveValueToDetailResult()
                try localDataManager.programItem!.managedObjectContext?.save()
                self.saveRunToCoreData(dataArray: dataDict["run"] as? [Any])
            } catch {
                let error = error as NSError
                assertionFailure("Unresolve error\(error)")
            }
        }
    }
    
    func saveRunToCoreData(dataArray:Array<Any>?) {
        guard (dataArray!.count > 1) else {
            saveSuccessAlert()
            return
        }
        
        for i in 1 ..< dataArray!.count {
            editRun(originalItem: nil, dic:dataArray![i] as! NSDictionary) { (success, item) in
                guard success == true else {return}
                localDataManager.giveValue(toLocalData: item as! Run)
                do {
                    try localDataManager.programItem!.managedObjectContext?.save()
                    NotificationCenter.default.post(name: Notification.Name(MAINVIEWRELOADDATA), object: nil)
                    if let dic = dataArray![i] as? NSDictionary {
                        self.saveLocationToCoreData(locationArray: dic["location"] as! Array)
                    }
                } catch {
                    let error = error as NSError
                    assertionFailure("Unresolve error\(error)")
                }
            }
        }
        loadPieChartData()
        saveSuccessAlert()
    }
    
    func saveSuccessAlert() {
        let alert = UIAlertController(title: "資料下載成功!", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveLocationToCoreData(locationArray:Array<Any>) {
        for i in 1..<locationArray.count {
            editLocation(originalItem: nil, dic: locationArray[i] as! NSDictionary) { (success, item) in
                guard success == true else {
                    return
                }
                do {
                    try localDataManager.programItem?.managedObjectContext?.save()
                } catch {
                    let error = error as NSError
                    assertionFailure("Unresolve error\(error)")
                }
            }
        }
    }
    
    typealias EditDoneHandler = (_ success:Bool,_ resultItem:Program?) -> Void
    func editProgram(originalItem:Program?,dic: NSDictionary,completion:@escaping EditDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            finalItem = localDataManager.createItem()
        }
//        finalItem?.creationdate = NSDate() as Date
        finalItem?.fast400m = Int32(dic["fast400m"] as! Int)
        finalItem?.slow400m = Int32(dic["slow400m"] as! Int)
        finalItem?.fast800m = Int32(dic["fast800m"] as! Int)
        finalItem?.slow800m = Int32(dic["slow800m"] as! Int)
        finalItem?.fast1200m = Int32(dic["fast1200m"] as! Int)
        finalItem?.slow1200m = Int32(dic["slow1200m"] as! Int)
        finalItem?.fast1600m = Int32(dic["fast1600m"] as! Int)
        finalItem?.slow1600m = Int32(dic["slow1600m"] as! Int)
        finalItem?.slowshorttempo = Int32(dic["slowshorttempo"] as! Int)
        finalItem?.fastmidtempo = Int32(dic["fastmidtempo"] as! Int)
        finalItem?.slowmidtempo = Int32(dic["slowmidtempo"] as! Int)
        finalItem?.fastlongtempo = Int32(dic["fastlongtempo"] as! Int)
        finalItem?.slowlongtempo = Int32(dic["slowlongtempo"] as! Int)
        finalItem?.fastlongrun = Int32(dic["fastlongrun"] as! Int)
        finalItem?.slowlongrun = Int32(dic["slowlongrun"] as! Int)
        
        completion(true,finalItem)
    }
    
    typealias EditRunDoneHandler = (_ success:Bool,_ resultItem:Run?) -> Void
    func editRun(originalItem:Run?,dic:NSDictionary,completion:@escaping EditRunDoneHandler) {
        let runManager = CoreDataManager<Run>(momdFilename: "ProgramModel", entityName: "Run", sortKey: "id")
        var finalItem = originalItem
        if finalItem == nil {
            //創建一個Run Item
            finalItem = runManager.createItemTo(target: localDataManager.programItem!)
            localDataManager.programItem?.addToRun(finalItem!)
        }
        finalItem?.id = dic["id"] as? String
        finalItem?.week = dic["week"] as? String
        finalItem?.duration = dic["duration"] as? String
        finalItem?.distance = dic["distance"] as? String
        finalItem?.pace = dic["pace"] as! Double
        finalItem?.complete = dic["complete"] as! Bool
        completion(true,finalItem)
    }
    
    typealias EditLocationDoneHandler = (_ success:Bool, _ resultItem:Location?) -> Void
    func editLocation(originalItem: Location?, dic:NSDictionary, completion: @escaping EditLocationDoneHandler) {
        let cllocationManager = CoreDataManager<Location>(momdFilename: "ProgramModel", entityName: "Location", sortKey: "id")
        var finalItem = originalItem
        if finalItem == nil {
            finalItem = cllocationManager.createItemTo(target:localDataManager.runItem!)
            finalItem?.id = dic["id"] as? String
            finalItem?.order = Int32(dic["order"] as! Int)
            localDataManager.runItem?.addToLocation(finalItem!)
        }
        if let longitude = dic["longitude"] as? Double {
            finalItem?.longitude = longitude
        }
        if let latitude = dic["latitude"] as? Double{
            finalItem?.latitude = latitude
        }
        completion(true,finalItem)
    }
}
