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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func labelSetUp() {
        targetDistanceLabel.text = runningGoal
        targetPaceLabel.text = getTargetPace(distance: runningGoalInt)
        if hasRecord {
            //fetch pace data from CD
            if checkCompletion(distance: runningGoalInt, workoutPace: Int(localDataManager.runItem!.pace)) {
                completetionLabel.text = "Pass"
            } else {
                completetionLabel.text = "Fail"
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
            //show record
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
            mapView.userTrackingMode = .none
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
            //save to core data
            //update and show result
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
        
        self.clearPolyline()
        
        self.polyline = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count)
        self.mapView.addOverlay(polyline as! MKOverlay)
        
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
    
}
