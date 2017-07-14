//
//  MyExamViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/10.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class MyExamViewController: UIViewController {
    
    @IBOutlet weak var alertTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="我的考试"
        var tmpstr = "1.请工程师及时到认证网进行认证，以免接不了单的情况\n2.请工程师及时到认证网进行认证，以免接不了单的情况\n3.请工程师及时到认证网进行认证，以免接不了单的情况\n"
        tmpstr=tmpstr.replacingOccurrences(of: "\\n", with: "\n")
        alertTextView.text=tmpstr
        alertTextView.font=UIFont.systemFont(ofSize: 14)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden=true
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(MyExamViewController.disMissBtn))
        
    }
    
    
    
    func disMissBtn(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience  init() {
        
        var nibNameOrNil = String?("MyExamViewController")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
}
