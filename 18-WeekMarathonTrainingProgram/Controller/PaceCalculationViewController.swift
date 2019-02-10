//
//  PaceCalculationViewController.swift
//  18-WeekMarathonTrainingProgram
//
//  Created by pinyuan on 2019/1/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class PaceCalculationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var suggestionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hourTextField.delegate = self
        minuteTextField.delegate = self
        secondTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    @objc func tap(_ sender:Any) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn:string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    @IBAction func didTappedCalculateBtn(_ sender: UIButton) {
        if (distanceTextField.text != "" && minuteTextField.text != "" && secondTextField.text != "") {
            let inputHour = (hourTextField.hasText ? Int(hourTextField.text!)!*3600 : 0)
            paceCalculator(hour: inputHour, minute: Int(minuteTextField.text!)!*60, second: Int(secondTextField.text!)!, distance: Int(distanceTextField.text!)!)
            UserDefaults.standard.set(true, forKey: "insertData")
            let paceResultVC = storyboard?.instantiateViewController(withIdentifier: "PaceResultViewController") as! PaceResultViewController
            self.navigationController?.present(paceResultVC, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "輸入錯誤", message: "請填入正確數字\n*空欄位請填0", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func didTappedInfoBtn(_ sender: UIButton) {
    }
}
