//
//  PaceCalculationViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/1/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class PaceCalculationViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var distanceTitleLabel: UILabel!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceTextField.delegate = self
        hourTextField.delegate = self
        minuteTextField.delegate = self
        secondTextField.delegate = self
        navigationSetUp(target: self)
        self.navigationItem.title = NSLocalizedString("PACE_CALCULATION", comment: "")
        setUpUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        distanceTitleLabel.text = NSLocalizedString("DISTANCE", comment: "")
        kmLabel.text = NSLocalizedString("KM", comment: "")
        timeTitleLabel.text = NSLocalizedString("TIME", comment: "")
        suggestionLabel.text = NSLocalizedString("SUGGESTION_LABEL", comment: "")
        calculateButton.setTitle(NSLocalizedString("CALCULATE", comment: ""), for: .normal)
        cancelButton.setTitle(NSLocalizedString("CANCEL", comment: ""), for: .normal)
        hourTextField.placeholder = NSLocalizedString("HOUR", comment: "")
        minuteTextField.placeholder = NSLocalizedString("MINUTE", comment: "")
        secondTextField.placeholder = NSLocalizedString("SECOND", comment: "")
    }
    
    
    @objc func tap(_ sender:Any) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn:string)
        return allowedCharacters.isSuperset(of: characterSet)
        return true
    }
    
    @IBAction func didTappedCalculateBtn(_ sender: UIButton) {
        if (distanceTextField.text != "" && minuteTextField.text != "" && secondTextField.text != "") {
            let inputHour = (hourTextField.hasText ? Int(hourTextField.text!)!*3600 : 0)
            paceCalculator(hour: inputHour, minute: Int(minuteTextField.text!)!*60, second: Int(secondTextField.text!)!, distance: Int(distanceTextField.text!)!)
            let paceResultVC = storyboard?.instantiateViewController(withIdentifier: "PaceResultViewController") as! PaceResultViewController
            self.navigationController?.pushViewController(paceResultVC, animated: true)
            
        }else{
            
            
            let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("ERROR_MESSAGE", comment: ""), preferredStyle: .alert)
            let cancel = UIAlertAction(title: NSLocalizedString("CONFIRM", comment: ""), style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func didTappedCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
