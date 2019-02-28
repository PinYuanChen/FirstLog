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

class NewRunViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var targetDistanceLabel: UILabel!
    @IBOutlet weak var targetPaceLabel: UILabel!
    @IBOutlet weak var completetionLabel: UILabel!
    @IBOutlet weak var currentDistanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentPaceLabel: UILabel!
    @IBOutlet weak var runButton: UIButton!
    var hasRecord:Bool?
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationSetUp()
        
    }

    @IBAction func didTappedRunButton(_ sender: Any) {
    }
    
    func navigationSetUp() {
        
        self.navigationController?.navigationBar.barTintColor = NAVIGATIONBARCOLOR
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
         self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
       
    }
}
