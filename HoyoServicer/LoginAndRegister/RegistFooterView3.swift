//
//  RegistFooterView3.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/29.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RegistFooterView3: UIView {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var IDCardTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var invitationCodeTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
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
