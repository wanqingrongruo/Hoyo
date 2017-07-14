//
//  RNQRCodeScanViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/19.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD

class RNQRCodeScanViewController: LBXScanViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(dissBtnAction))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //重写第三方库方法
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        
        var type = ""
        var mac = ""
        let result:LBXScanResult = arrayResult[0]
        let jsonStr = result.strScanned! as String
        if (jsonStr.hasPrefix("http://")) {
            // print("yes")
            if jsonStr.contains("mac=") && jsonStr.contains("&type=") {
                
                let strArr = (jsonStr as NSString).components(separatedBy: "mac=")
                if  strArr.count > 0 {
                    
                    let str02 = (strArr.last! as NSString).components(separatedBy: "&type=")
                    
                    if str02.count > 0{
                        
                        mac = str02.first ?? "没有数据"
                        type = str02.last ?? "没有数据"
                        
                        let scanResultVC = RNScanResultViewController()
                        scanResultVC.typeCode = type
                        scanResultVC.number = mac
                        navigationController?.pushViewController(scanResultVC, animated: true)
                        
                    }else{
                        
                        let alertView=SCLAlertView()
                        alertView.addButton("确定", action: {
                        
                            let _ = self.navigationController?.popViewController(animated: true)
                        })
                        alertView.showError("提示", subTitle: "二维码格式不正确,请确认二维码是智能伴侣的二维码")
                        
                    }
                }else{
                    
                    let alertView=SCLAlertView()
                    alertView.addButton("确定", action: {
                         let _ = self.navigationController?.popViewController(animated: true)
                    })
                    alertView.showError("提示", subTitle: "二维码格式不正确,请确认二维码是智能伴侣的二维码")
                    
                }

            }else{
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {
                     let _ = self.navigationController?.popViewController(animated: true)
                })
                alertView.showError("提示", subTitle: "二维码格式不正确,请确认二维码是智能伴侣的二维码")

            }
            
        }else{
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {
                 let _ = self.navigationController?.popViewController(animated: true)
            })
            alertView.showError("提示", subTitle: "二维码格式不正确,请确认二维码是智能伴侣的二维码")
        }
        
       
    }
    
}


//MAEK: - event response

extension RNQRCodeScanViewController{
    
    func dissBtnAction() {
        _ = navigationController?.popViewController(animated: true)
    }
}
