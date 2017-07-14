//
//  ServiceTrainViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/6/1.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
class ServiceTrainViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var GuidTextField: UITextField!
    @IBOutlet weak var MachineKindTextField: UITextField!
    @IBOutlet weak var MachineBrandTextField: UITextField!
    @IBOutlet weak var PhoneTextField: UITextField!
    @IBAction func SubmitClick(_ sender: AnyObject) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let weakSelf = self
        
        User.UpdateServiceTrainMachine(GuidTextField.text!, MachineKind: MachineKindTextField.text!, MachineBrand: MachineBrandTextField.text!, UserPhone: PhoneTextField.text!, success: {
            MBProgressHUD.hide(for: weakSelf.view, animated: true)
            let alert=SCLAlertView()
//            alert.addButton("确定", action: {
//                //
//            })
            alert.showTitle("提示", subTitle: "提交成功", duration: 1.5, completeText: "", style: SCLAlertViewStyle.success, colorStyle: nil, colorTextButton: nil, circleIconImage: nil)
            _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
        }) { (error) in
            MBProgressHUD.hide(for: weakSelf.view, animated: true)
            let alert=SCLAlertView()
//            alert.addButton("确定", action: {
//                //
//            })
            alert.showTitle("提示", subTitle: error.localizedDescription, duration: 1.5, completeText: "", style: SCLAlertViewStyle.error, colorStyle: nil, colorTextButton: nil, circleIconImage: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="服务直通车"
        GuidTextField.text=selfGuid
        MachineKindTextField.text=selfMachineKind
        MachineBrandTextField.text=selfMachineBrand
        PhoneTextField.text=selfPhone
        GuidTextField.delegate=self
        MachineKindTextField.delegate=self
        MachineBrandTextField.delegate=self
        PhoneTextField.delegate=self
        // Do any additional setup after loading the view.
        //        navigationController?.interactivePopGestureRecognizer?.enabled = false
        setNavigationItem("服务记录", selector: #selector(ServiceTrainViewController.checkRecord), isRight: true)
    }
    func checkRecord(){
        
        let historyServer = HistoryServerViewController(servicecode: self.GuidTextField!.text!)
        self.navigationController?.pushViewController(historyServer, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
           navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(ServiceTrainViewController.dissBtnAction))
        // navigationController?.navigationBar.translucent = false
    }
    
    func dissBtnAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    fileprivate var selfGuid=""
    fileprivate var selfMachineKind=""
    fileprivate var selfMachineBrand=""
    fileprivate var selfPhone=""
    convenience  init(Guid:String,MachineKind:String,MachineBrand:String,Phone:String) {
        
        self.init(nibName: "ServiceTrainViewController", bundle: nil)
        selfGuid=Guid
        selfMachineKind=MachineKind
        selfMachineBrand=MachineBrand
        selfPhone=Phone
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
