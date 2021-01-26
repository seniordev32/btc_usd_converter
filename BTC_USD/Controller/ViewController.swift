//
//  ViewController.swift
//  BTC_USD
//
//  Created by Moon on 1/26/21.
//  Copyright © 2021 Eric. All rights reserved.
//

import UIKit
import SwiftSpinner

class ViewController: UIViewController {

    @IBOutlet weak var excForm: UIStackView!
    @IBOutlet weak var tfBtcAmount: UITextField!
    @IBOutlet weak var tfUsdAmount: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        SwiftSpinner.useContainerView(view)
        SwiftSpinner.show("Loading ...")
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        APIManager.shared.getPriceRatio { (ratio) in
            if self.tfBtcAmount.text!.isEmpty && self.tfUsdAmount.text!.isEmpty {
                DispatchQueue.main.async {
                    self.setDefaultValues(true)
                }
            }
        }

        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            APIManager.shared.getPriceRatio { (_) in }
        }
    }

    private func setDefaultValues(_ isFirst: Bool = false) {
        if isFirst {
            SwiftSpinner.hide()
            excForm.isHidden = false
        }
        tfBtcAmount.text = "1"
        tfUsdAmount.text = "\(APIManager.shared.latestRatio)"
    }

    private func setBtcValue() {
        let usdAmount = (tfUsdAmount.text as NSString?)?.floatValue ?? 0.0
        tfBtcAmount.text = "\(usdAmount / APIManager.shared.latestRatio)"
    }

    private func setUsdValue() {
        let btcAmount = (tfBtcAmount.text as NSString?)?.floatValue ?? 0.0
        tfUsdAmount.text = "\(btcAmount * APIManager.shared.latestRatio)"
    }

    @objc func hideKeyboard() {
        view.endEditing(true)

        if tfBtcAmount.text!.isEmpty || tfUsdAmount.text!.isEmpty {
            setDefaultValues()
        }
    }

    @IBAction func amountChanged(_ textField: UITextField) {
        if textField == tfBtcAmount {
            setUsdValue()
        } else {
            setBtcValue()
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
//        let text = textField.text ?? ""
//        let replacementText = (text as NSString).replacingCharacters(in: range, with: string)
//        return replacementText.isValidDouble(10)

        let textFieldString = textField.text! as NSString;
        let newString = textFieldString.replacingCharacters(in: range, with:string)

        let floatRegEx = "^([0-9]+)?(\\.([0-9]+)?)?$"
        let floatExPredicate = NSPredicate(format:"SELF MATCHES %@", floatRegEx)

        return floatExPredicate.evaluate(with: newString)
    }
}

extension String {
    func isValidDouble(_ maxDecimalPlaces: Int) -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."
        
        if formatter.number(from: self) != nil {
            let split = components(separatedBy: decimalSeparator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.count <= maxDecimalPlaces
        }

        return false
    }
}
