//
//  RNPairFailViewController.swift
//  HoyoServicer
//
//  Created by 郑文祥 on 2017/6/19.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNPairFailViewController: UIViewController {
    
    var orderDetail:OrderDetail? // 从上个界面带过来
    @IBAction func repairAction(_ sender: Any) {
        disMissBtn()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "配对失败"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func disMissBtn(){
      
//        self.dismiss(animated: true) { 
//            //
//        }
        _ = self.navigationController?.popViewController(animated: true)
    }

}
