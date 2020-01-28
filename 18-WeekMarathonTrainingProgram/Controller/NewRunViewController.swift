//
//  NewRunViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/2/21.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

public protocol NewRunViewControllerProtocol:AnyObject {
    var requestRun:[Run] {get}
}

class NewRunViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var runButton: UIButton!
    @IBOutlet weak var resultTableView: UITableView!
    
    var rightCancelButton:UIBarButtonItem?
    var (hasRecord,complete) = (false,false)
    var timer:Timer?
    var startRecording = false
    var seconds = 0.0
    var distanceCount = 0
    var instantPace = 0.0
    var locationManager = CLLocationManager()
    var locationDataArray:[CLLocation] = []
    var polyline:MKPolyline?
    var runningGoalInt:Int {
        get { return transferRunStringToInt(runString: runningGoal)}
    }
    var reLocations = [Location]()
    var requestRun:[Run]?
    
    let runManager = CoreDataManager<Run>(momdFilename: "ProgramModel", entityName: "Run", sortKey: "id")
    let cllocationManager = CoreDataManager<Location>(momdFilename: "ProgramModel", entityName: "Location", sortKey: "id")
    var aryTitles = [
        NSLocalizedString("TARGET_DISTANCE", comment: ""),
        NSLocalizedString("TARGET_PACE", comment: ""),
        NSLocalizedString("DISTANCE", comment: ""),
        NSLocalizedString("DURATION", comment: ""),
        NSLocalizedString("PACE", comment: ""),
        NSLocalizedString("COMPLETE", comment: "")
    ]
    
    var dicData = [
        NSLocalizedString("TARGET_DISTANCE", comment: "") : runningGoal,
        NSLocalizedString("TARGET_PACE", comment: ""): "",
        NSLocalizedString("DISTANCE", comment: "") : "",
        NSLocalizedString("DURATION", comment: "") : "",
        NSLocalizedString("PACE", comment: "") : "",
        NSLocalizedString("COMPLETE", comment: "") : ""
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshMapAndData),
            name: Notification.Name("refreshMapAndData"),
            object: nil)
        updateData()
        buttonSetUp()
        navigationSetUp(target: self)
        self.navigationItem.title = runningGoal
        rightCancelButton = UIBarButtonItem(title: NSLocalizedString("CLOSE", comment: ""), style: .plain, target: self, action: #selector(didTappedCloseButton))
        self.navigationItem.rightBarButtonItem = rightCancelButton
        mapSetUp()
        resultTableView.layer.cornerRadius = 8
        resultTableView.showsVerticalScrollIndicator = false
        resultTableView.showsHorizontalScrollIndicator = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }else{
            showTurnOnLocationServiceAlert()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }

    @IBAction func didTappedRunButton(_ sender: Any) {
        if hasRecord { //delete record
            let alert = UIAlertController(title: NSLocalizedString("DELETE_WARN_TITLE", comment: ""), message: NSLocalizedString("DELETE_WARN_MESSAGE", comment: ""), preferredStyle: .alert)
            let okBtn = UIAlertAction(title: NSLocalizedString("CONFIRM", comment: ""), style: .default) { _ in
                
                let manageContext = localDataManager.runItem?.managedObjectContext
                let item = self.requestRun![0] as Run
                let locations = item.location?.allObjects as! [Location]
                for i in 0..<locations.count {
                    manageContext?.delete(locations[i])
                }
                manageContext?.delete(item)
                
                do {
                    try manageContext?.save()
                    localDataManager.saveContext(completion: { (success) in
                        NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil)
                        //reload data
                        self.hasRecord = false
                        if self.mapView.annotations.count > 0 {
                            self.mapView.removeAnnotations(self.mapView.annotations)
                        }
                        if self.mapView.overlays.count>0{
                            self.mapView.removeOverlays(self.mapView.overlays)
                        }
                        self.seconds = 0.0
                        self.distanceCount = 0
                        self.instantPace = 0.0
                        self.updateData()
                        self.buttonSetUp()
                        self.locationDataArray.removeAll()
                        self.mapSetUp()
                    })
                    
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
            let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil)
            alert.addAction(okBtn)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else if startRecording {
            let alert = UIAlertController(title: NSLocalizedString("STOP", comment: ""), message: NSLocalizedString("STOP_WARN_MESSAGE", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("QUIT", comment: ""), style: .default, handler: { (UIAlertAction) in
                self.stopTimer()
                self.startRecording = false
                if self.mapView.annotations.count > 0 {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                }
                if self.mapView.overlays.count>0{
                    self.mapView.removeOverlays(self.mapView.overlays)
                }
                self.seconds = 0.0
                self.distanceCount = 0
                self.instantPace = 0.0
                self.buttonSetUp()
                self.locationDataArray.removeAll()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else { //start new run
            startRecording = true
            seconds = 0.0
            distanceCount = 0
            instantPace = 0.0
            buttonSetUp()
            startTimer()
            locationDataArray.removeAll()
            mapViewAddStartPlaceholder()
            rightCancelButton?.isEnabled = false
        }
    }
    
    @objc func refreshMapAndData() {
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(polyline!)
        }
        
        updateData()
        buttonSetUp()
        mapSetUp()
    }
    
    func updateData() {
        if ((dicData[NSLocalizedString("TARGET_PACE", comment: "")]) == "") {
            dicData[NSLocalizedString("TARGET_PACE", comment: "")] = getTargetPace(distance: runningGoalInt)
        }
        
        if hasRecord {
            //fetch data from CD
            complete = checkCompletion(distance: runningGoalInt, workoutPace: Int(localDataManager.runItem!.pace))
            if complete {
                dicData[NSLocalizedString("COMPLETE", comment: "")] = NSLocalizedString("COMPLETE_PASS", comment: "")
            } else {
                dicData[NSLocalizedString("COMPLETE", comment: "")] = NSLocalizedString("COMPLETE_FAIL", comment: "")
            }
            if requestRun != nil {
                for item in requestRun! {
                    dicData[NSLocalizedString("DISTANCE", comment: "")] = item.distance
                    let (minute,second) = secondsToMinutesSeconds(seconds: Int(item.pace))
                    dicData[NSLocalizedString("PACE", comment: "")] = "\(minute) \(NSLocalizedString("MINUTE", comment: "")) \(second) \(NSLocalizedString("SECOND", comment: ""))"
                    dicData[NSLocalizedString("DURATION", comment: "")] = item.duration
                }
            }
        }
        resultTableView.reloadData()
    }
    
    func buttonSetUp() {
        if hasRecord {
            runButton.setTitle(NSLocalizedString("DELETE", comment: ""), for: .normal)
        } else if startRecording {
            runButton.setTitle(NSLocalizedString("STOP", comment: ""), for: .normal)
        } else {
            runButton.setTitle(NSLocalizedString("START", comment: ""), for: .normal)
        }
    }
    
    func mapSetUp() {
        if !hasRecord {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            mapView.userTrackingMode = .followWithHeading
        }else{
            var locations = localDataManager.runItem?.location?.allObjects as! [Location]
            guard locations.count > 1 else { return }
            mapView.region = mapRegion()
            mapView.userTrackingMode = .none
            var coords = [CLLocationCoordinate2D]()
            reArrangeLocations()
            for i in 0..<reLocations.count{
                coords.append(CLLocationCoordinate2D(latitude: reLocations[i].latitude, longitude: reLocations[i].longitude))
            }
            polyline = MKPolyline(coordinates: coords, count: coords.count)
            mapView.addOverlay(polyline as! MKOverlay)
            mapViewAddPlaceholder()
        }
    }
    
    func durationFormatter(hour:String,minute:String,second:String) -> String {
        guard let hourString = hour.components(separatedBy: " ").first else {
            return ""
        }
        guard let minuteString = minute.components(separatedBy: " ").first else {
            return ""
        }
        guard let secondString = second.components(separatedBy: " ").first else {
            return ""
        }
        let durationString = "\(hourString) \(NSLocalizedString("HOUR", comment: "")) \(minuteString) \(NSLocalizedString("MINUTE", comment: "")) \(secondString) \(NSLocalizedString("SECOND", comment: ""))"
        return durationString
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer()
            timer = Timer.scheduledTimer(timeInterval: 0.5,
                                         target: self,
                                         selector: #selector(eachSecond(_:)),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
            locationManager.stopUpdatingLocation()
            startRecording = false
            rightCancelButton?.isEnabled = true
        }
    }
    
    @objc func didTappedCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    func showTurnOnLocationServiceAlert() {
        let alert = UIAlertController(title: NSLocalizedString("LOCATION_SERVICE_TITLE", comment: ""), message: NSLocalizedString("LOCATION_SERVICE_MESSAGE", comment: ""), preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: NSLocalizedString("SETTINGS", comment: ""), style: .default) { (_) -> Void in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func transferRunStringToInt(runString:String) -> Int {
        var result = 0
        guard let distance = runString.components(separatedBy: " ").first else {
            return 0
        }
        guard let unit = runString.components(separatedBy: " ").last else {
            return 0
        }
        if unit == "km" {
            result = Int(distance)! * 1000
        } else {
            result = Int(distance)!
        }
        
        return result
    }
    
    
    
    //MARK: - Map
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = localDataManager.runItem?.location?.allObjects.first as! Location
        
        var minLat = initialLoc.latitude
        var minLng = initialLoc.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = localDataManager.runItem?.location?.allObjects as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude)
            minLng = min(minLng, location.longitude)
            maxLat = max(maxLat, location.latitude)
            maxLng = max(maxLng, location.longitude)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                                           longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*3,
                                   longitudeDelta: (maxLng - minLng)*3))
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let identifier = "trackRecord"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if result == nil {
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            result?.annotation = annotation
        }
        
        result?.canShowCallout = true
        let imageFlag = UIImage(named: "p1")
        result?.image = imageFlag
        return result
    }
    
    func mapViewAddStartPlaceholder(){
     
        locationManager.startUpdatingLocation()
        guard let currentLocation = locationManager.location else {
            return
        }
        let coordinate = currentLocation.coordinate
        let placeholder1 = MKPointAnnotation()
        placeholder1.title = "START"
        placeholder1.coordinate = coordinate
        mapView.addAnnotation(placeholder1)
        
    }
    
    @objc func eachSecond(_ timer: Timer) {
        
        seconds += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        let secondsQuantity = "\(s)"
        let minutesQuantity = "\(m)"
        let hoursQuantity = "\(h)"
        dicData[NSLocalizedString("DURATION", comment: "")] = durationFormatter(hour: hoursQuantity.description, minute: minutesQuantity.description, second: secondsQuantity.description)
        let distanceQuantity = "\(distanceCount)\(NSLocalizedString("METER", comment: ""))"
        dicData[NSLocalizedString("DISTANCE", comment: "")] = "\(distanceQuantity.description) "
        guard !(instantPace.isNaN || instantPace.isInfinite) else {
            print("illegal value")
            return
        }
        let (minute,second) = secondsToMinutesSeconds(seconds: Int(instantPace))
        dicData[NSLocalizedString("PACE", comment: "")] = "\(minute) \(NSLocalizedString("MINUTE", comment: "")) \(second) \(NSLocalizedString("SECOND", comment: ""))"
        if distanceCount >= runningGoalInt {
            stopTimer()
            hasRecord = true
            mapView.showsUserLocation = false
            //save to core data
            editRun(originalItem: nil, completion: { (success, item) in
                guard success == true else {
                    return
                }
                localDataManager.giveValue(toLocalData: item as! Run)
                do {
                    try localDataManager.runItem?.managedObjectContext?.save()
                    try localDataManager.programItem?.managedObjectContext?.save()
                } catch {
                    let error = error as NSError
                    assertionFailure("Unresolved error\(error)")
                }
            })
            
            for i in 0..<locationDataArray.count {
                editLocation(originalItem: nil, index: i) { (success, item) in
                    guard success == true else {
                        return
                    }
                    do {
                        try localDataManager.runItem?.managedObjectContext?.save()
                        try localDataManager.programItem?.managedObjectContext?.save()
                        self.fetchDataToRequestRun()
                        NotificationCenter.default.post(name: Notification.Name("refreshMapAndData"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(MAINVIEWRELOADDATA), object: nil)
                    } catch {
                        let error = error as NSError
                        assertionFailure("Unresolved error\(error)")
                    }
                }
            }
        }
        resultTableView.reloadData()
    }
    
    func fetchDataToRequestRun() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
        request.predicate = NSPredicate(format: "id == %@", "\(week)\(runSection)\(runRow)")
        do {
            let requestRunAry = try localDataManager.runItem?.managedObjectContext?.fetch(request) as! [Run]
            requestRun = requestRunAry
        } catch {
            print("fetch fail")
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = NAVIGATIONBARCOLOR
            polylineRenderer.lineWidth = 5.0
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    
    func reArrangeLocations() {
        var locations = localDataManager.runItem?.location?.allObjects as! [Location]
        reLocations = locations
        for i in 0..<locations.count{
            reLocations.remove(at: Int(locations[i].order))
            reLocations.insert(locations[i], at: Int(locations[i].order))
        }
    }
    
    func mapViewAddPlaceholder() {
        let coordinate1 = reLocations.first
        let coordinate2 = reLocations.last
        let placeholder1 = MKPointAnnotation()
        let placeholder2 = MKPointAnnotation()
        placeholder1.title = "START"
        placeholder2.title = "END"
        placeholder1.coordinate.latitude = (reLocations.first?.latitude)!
        placeholder1.coordinate.longitude = (reLocations.first?.longitude)!
        placeholder2.coordinate.latitude = (reLocations.last?.latitude)!
        placeholder2.coordinate.longitude = (reLocations.last?.longitude)!
        mapView.addAnnotation(placeholder1)
        mapView.addAnnotation(placeholder2)
    }
    
    //MARK: - Core Location Method
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]){
        if startRecording {
            if let newLocation = locations.last{
                
                let locationAdded:Bool = filterLocation(newLocation)
                
                if locationAdded {
                    if  locationDataArray.count > 0 {
                        self.distanceCount += Int(newLocation.distance(from: self.locationDataArray.last!))
                        self.instantPace = (newLocation.timestamp.timeIntervalSince(self.locationDataArray.last!.timestamp)) * (1000/newLocation.distance(from: self.locationDataArray.last!))
                    }
                    locationDataArray.append(newLocation)
                    let coordinate = locationDataArray.last?.coordinate
                    let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009);
                    let region = MKCoordinateRegion(center: coordinate!, span: span)
                    mapView.setRegion(region, animated: true)
                    updatePolylines()
                }
                
            }
        }
       
    }
    
    func updatePolylines(){
        var coordinateArray = [CLLocationCoordinate2D]()
        
        for loc in locationDataArray{
            coordinateArray.append(loc.coordinate)
        }
        
        clearPolyline()
        polyline = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count)
        mapView.addOverlay(polyline as! MKOverlay)
        
    }
    
    func clearPolyline(){
        if self.polyline != nil{
            self.mapView.removeOverlay(self.polyline!)
            self.polyline = nil
        }
    }
    
    func filterLocation(_ location: CLLocation) -> Bool{
        let age = -location.timestamp.timeIntervalSinceNow
        
        if age > 10{
            print("Locaiton is old.")
            return false
        }
        
        if location.horizontalAccuracy < 0{
            print("Latitidue and longitude values are invalid.")
            return false
        }
        
        if location.horizontalAccuracy > 100{
            print("Accuracy is too low.")
            return false
        }

        return true
        
    }
    
    //MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
        cell.selectionStyle = .none
        let title = aryTitles[indexPath.row]
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = dicData[title]
        return cell
    }
    
    //MARK: - Core Data
    typealias EditDoneHandler = (_ success:Bool,_ resultItem:Run?) -> Void
    func editRun(originalItem:Run?,completion:@escaping EditDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            finalItem = runManager.createItemTo(target: localDataManager.programItem!)
            finalItem?.id = "\(week)\(runSection)\(runRow)"
            localDataManager.programItem?.addToRun(finalItem!)
        }
        
        finalItem?.id = "\(week)\(runSection)\(runRow)"
        finalItem?.week = "Week\(week)"
        finalItem?.duration = dicData[NSLocalizedString("DURATION", comment: "")]
        finalItem?.distance = dicData[NSLocalizedString("DISTANCE", comment: "")]
        finalItem?.pace = instantPace
        finalItem?.complete = checkCompletion(distance: runningGoalInt, workoutPace: Int(instantPace))
        completion(true,finalItem)
    }
    
    //MARK: Annotation
    typealias EditLocationDoneHandler = (_ success:Bool, _ resultItem:Location?) -> Void
    func editLocation(originalItem: Location?, index:Int, completion: @escaping EditLocationDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            finalItem = cllocationManager.createItemTo(target:localDataManager.runItem!)
            finalItem?.id = "\(week)\(runSection)\(runRow)"
            finalItem?.order = Int32(index)
            localDataManager.runItem?.addToLocation(finalItem!)
        }
        if let longitude = locationDataArray[index].coordinate.longitude as? Double {
            finalItem?.longitude = longitude
        }
        if let latitude = locationDataArray[index].coordinate.latitude as? Double{
            finalItem?.latitude = latitude
        }
        completion(true,finalItem)
    }
}
