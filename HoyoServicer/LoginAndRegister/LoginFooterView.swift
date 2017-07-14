//
//  LoginFooterView.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/29.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class LoginFooterView: UIView {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var foregetPassWordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}
