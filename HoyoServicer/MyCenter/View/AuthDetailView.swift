//
//  AuthDetailView.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/30.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class AuthDetailView: UIView,UITextFieldDelegate {

    @IBOutlet weak var imageButton1: UIButton!
    @IBOutlet weak var imageButton2: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var ID2TextField: UITextField!
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        nameTextField.delegate=self
        ID2TextField.delegate=self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.isFirstResponder) {
            
            textField.resignFirstResponder()
            
        }
        
        return true
    }

}
