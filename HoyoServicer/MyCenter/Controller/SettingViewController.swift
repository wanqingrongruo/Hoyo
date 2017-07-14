//
//  SettingViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/8.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBAction func loginOut(_ sender: UIButton) {
        
        let alertView=SCLAlertView()
        alertView.addButton("确定", action: {
         appDelegate.LoginOut()
        })
        
        alertView.addButton("取消", action: {})
        alertView.showInfo("温馨提示", subTitle: "退出后将不再接受通知消息")
        
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("你好")
        print("你好")
        self.title="设置"
        // Do any additional setup after loading the view.
        
        versionLabel.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden=true
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(SettingViewController.disMissBtn))
    }
    
    func disMissBtn(){
       _ =  navigationController?.popViewController(animated: true)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience  init() {
        
        var nibNameOrNil = String?("SettingViewController")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
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
