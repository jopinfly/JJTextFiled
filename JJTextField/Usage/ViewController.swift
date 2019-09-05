//
//  ViewController.swift
//  JJTextField
//
//  Created by yubing.li on 2019/9/4.
//  Copyright © 2019 Matrixport. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let SMSCodeInputter = JJTextField(frame: CGRect(x: 50, y: 100, width: 100, height: 50))
        SMSCodeInputter.maxLength = 6
        SMSCodeInputter.acceptedCharacterSet = .number
        SMSCodeInputter.onBeginEdit = { (_) in }
        view.addSubview(SMSCodeInputter)
        
        let someInputter = JJTextField(frame: .zero)
        someInputter.maxLength = 2
        someInputter.acceptedCharacterSet = .designate(cs: "abcdef")
        view.addSubview(someInputter)
        
        let amountInputter = JJTextField(frame: .zero)
        amountInputter.acceptedCharacterSet = .decimal
        amountInputter.enableDecimalLimitMode = true
        amountInputter.onEditing = { (_) in }
        view.addSubview(amountInputter)
    }


}

