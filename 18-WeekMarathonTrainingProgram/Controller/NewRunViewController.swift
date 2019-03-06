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
import HealthKit

class NewRunViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var targetDistanceLabel: UILabel!
    @IBOutlet weak var targetPaceLabel: UILabel!
    @IBOutlet weak var completetionLabel: UILabel!
    @IBOutlet weak var currentDistanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentPaceLabel: UILabel!
    @IBOutlet weak var runButton: UIButton!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshMapAndData),
            name: Notification.Name("refreshMapAndData"),
            object: nil)
        labelSetUp()
        buttonSetUp()
        navigationSetUp()
        mapSetUp()
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
        startRecording = true
        seconds = 0.0
        distanceCount = 0
        instantPace = 0.0
        startTimer()
        locationDataArray.removeAll()
        mapViewAddStartPlaceholder()
    }
    
    @objc func refreshMapAndData() {
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(polyline!)
        }
        
        labelSetUp()
        buttonSetUp()
        mapSetUp()
    }
    
    func labelSetUp() {
        targetDistanceLabel.text = runningGoal
        targetPaceLabel.text = getTargetPace(distance: runningGoalInt)
        if hasRecord {
            //fetch pace data from CD
            complete = checkCompletion(distance: runningGoalInt, workoutPace: Int(localDataManager.runItem!.pace))
            if complete {
                completetionLabel.text = "Pass"
            } else {
                completetionLabel.text = "Fail"
            }
            
            if requestRun != nil {
                for item in requestRun! {
                    currentDistanceLabel.text = item.distance
                    let (minute,second) = secondsToMinutesSeconds(seconds: Int(item.pace))
                    currentPaceLabel.text = "\(minute) min \(second) s"
                    durationLabel.text = item.duration
                }
            }
        }
    }
    
    func buttonSetUp() {
        if complete {
            runButton.setTitle("Cancel", for: .normal)
        } else if (hasRecord && !complete) {
            runButton.setTitle("Retry", for: .normal)
        } else {
            runButton.setTitle("Start", for: .normal)
        }
    }
    
    func navigationSetUp() {
        
        self.navigationController?.navigationBar.barTintColor = NAVIGATIONBARCOLOR
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
       self.navigationItem.title = runningGoal
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
        rightCancelButton = UIBarButtonItem(title: "Canel", style: .plain, target: self, action: #selector(didTappedCancelButton))
       self.navigationItem.rightBarButtonItem = rightCancelButton
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
            
        } else {
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
        }
    }
    
    @objc func didTappedCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func showTurnOnLocationServiceAlert() {
        
        let alert = UIAlertController(title: "Turn on Location Service", message: "To use location tracking feature of the app, please turn on the location service from the Settings app.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
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
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: Double(s))
        let minutesQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: Double(m))
        let hoursQuantity = HKQuantity(unit: HKUnit.hour(), doubleValue: Double(h))
        durationLabel.text = "\(hoursQuantity.description)  \(minutesQuantity.description) \(secondsQuantity.description)"
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: Double(distanceCount))
        currentDistanceLabel.text = "\(distanceQuantity.description) "
        let (minute,second) = secondsToMinutesSeconds(seconds: Int(instantPace))
        currentPaceLabel.text = "\(minute) min \(second) s"
        if distanceCount >= runningGoalInt {
            stopTimer()
            hasRecord = true
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
                        NotificationCenter.default.post(name: Notification.Name("refreshMapAndData"), object: nil)
                    } catch {
                        let error = error as NSError
                        assertionFailure("Unresolved error\(error)")
                    }
                }
            }
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
    
    //MARK: - Core Data
    typealias EditDoneHandler = (_ success:Bool,_ resultItem:Run?) -> Void
    func editRun(originalItem:Run?,completion:@escaping EditDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            //創建一個Run Item
            finalItem = runManager.createItemTo(target: localDataManager.programItem!)
            finalItem?.id = "\(week)\(runSection)\(runRow)"
            print(finalItem!.id)
            localDataManager.programItem?.addToRun(finalItem!)
        }
        
        finalItem?.id = "\(week)\(runSection)\(runRow)"
        finalItem?.duration = durationLabel.text
        finalItem?.distance = currentDistanceLabel.text
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
