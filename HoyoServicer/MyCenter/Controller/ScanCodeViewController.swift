//
//  ScanCodeViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/6/1.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD

class ScanCodeViewController: LBXScanViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        // navigationController?.navigationBar.translucent = false
         navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(ScanCodeViewController.dissBtnAction))
    }
    
    func dissBtnAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //func handleCodeResult(arrayResult:[LBXScanResult])
    //重写第三方库方法
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        let weakSelf = self
        var strParamets = ""
        let result:LBXScanResult = arrayResult[0]
        let jsonStr = result.strScanned! as String
        if (jsonStr.hasPrefix("http://")) {
            //print("yes")
            let strArr = (jsonStr as NSString).components(separatedBy: "cardvalue=")
            if strArr.count > 1 {
                strParamets = strArr.last ?? ""
//                if strParamets.contains("&") {
//                   let strArr02 = strParamets.components(separatedBy: "&")
//                    if let str =  strArr02.first {
//                        strParamets = str
//                    }else{
//                        strParamets = ""
//                    }
//                }
            }
        } else {
            let nsdataJson = jsonStr.data(using: String.Encoding.utf8) //data  是json格式字符串
            let json = JSON(data:nsdataJson!)
            strParamets = json["data"].stringValue
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.CheckServiceTrain(strParamets, success: { (ServiceId, MachineKind, MachineBrand, UserPhone) in
            MBProgressHUD.hide(for: weakSelf.view, animated: true)
            print(ServiceId)
            print(MachineKind)
            print(MachineBrand)
            print(UserPhone)
            //跳转到新页面
            let serviceTrainVC=ServiceTrainViewController(Guid: ServiceId, MachineKind: MachineKind, MachineBrand: MachineBrand, Phone: UserPhone)
            weakSelf.navigationController?.pushViewController(serviceTrainVC, animated: true)
        }) { (error) in
            MBProgressHUD.hide(for: weakSelf.view, animated: true)
            _ = weakSelf.navigationController?.popViewController(animated: true)
            let alert=SCLAlertView()
            alert.addButton("确定", action: {
                //
             })
            alert.showError("提示", subTitle: "扫描二维码失败，可能原因：二维码无效或网络不流畅，请重试")
//            alert.showTitle("提示", subTitle: "扫描二维码失败，可能原因：二维码无效或网络不流畅，请重试", duration: 2.0, completeText: "", style: SCLAlertViewStyle.edit, colorStyle: nil, colorTextButton: nil, circleIconImage: nil)
        }
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
