//
//  EditNameViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 21/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class EditNameViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var editName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "名字"
        
        editName.delegate = self
        setNavigationItem("取消", selector: #selector(UIViewController.doBack), isRight: false)
        setNavigationItem("保存", selector:#selector(EditNameViewController.doBackAndSave), isRight: true)
        self.navigationItem.rightBarButtonItem?.tintColor = COLORRGBA(50, g: 104, b: 51, a: 1)
        self.editName.text =  User.currentUser?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        // navigationController?.navigationBar.translucent = false
    }
    func doBackAndSave()
    {
        if !(self.editName.text! == ""||self.editName.text! == User.currentUser?.name) {
            callBack!(self.editName.text!)
        }
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    override func doBack() {
        
        
       _ =  self.navigationController?.popViewController(animated: true)
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        print("修改中")
        
        self.navigationItem.rightBarButtonItem?.tintColor = COLORRGBA(47, g: 210, b: 50, a: 1)
        return  true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.navigationItem.rightBarButtonItem?.tintColor = COLORRGBA(50, g: 104, b: 51, a: 1)
        editName.resignFirstResponder()
        doBackAndSave()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        editName.resignFirstResponder()
        self.navigationItem.rightBarButtonItem?.tintColor = COLORRGBA(50, g: 104, b: 51, a: 1)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    var callBack:((String)->Void)?
    
    convenience  init(callback:@escaping ((String)->Void)) {
        
        var nibNameOrNil = String?("EditNameViewController")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        callBack=callback
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
}
