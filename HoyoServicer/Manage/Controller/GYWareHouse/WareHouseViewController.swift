//
//  WareHouseViewController.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/4/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class WareHouseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instanceNavbar()
        warnLabel.center.y = view.center.y - 50
        warnLabel.center.x = view.center.x
        view.addSubview(warnLabel)
        
    }
    
    fileprivate func instanceNavbar(){
        self.title = "完善中"
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(WareHouseViewController.disMissBtn))
        navigationController?.isNavigationBarHidden = false
        
    }
    
    fileprivate lazy var warnLabel: UILabel = {
        let lb = UILabel()
        lb.text = "功能完善中，敬请期待!"
        lb.adjustsFontSizeToFitWidth = true
        lb.font = UIFont.systemFont(ofSize: 20)
        lb.sizeToFit()
        return lb
    }()
    
    func disMissBtn(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
