//
//  QQScanViewController.swift
//  swiftScan
//
//  Created by xialibing on 15/12/10.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit

protocol OznerScanViewControllerDelegate {
    func popToSubmitCon(_ result:String)
}
class OznerScanViewController: LBXScanViewController {
    
    
    var delegate : OznerScanViewControllerDelegate?
    
    /**
     @brief  扫码区域上方提示文字
     */
    var topTitle:UILabel?
    
    /**
     @brief  闪关灯开启状态
     */
    var isOpenedFlash:Bool = false
    
    // MARK: - 底部几个功能：开启闪光灯、相册、我的二维码
    
    //底部显示的功能项
    var bottomItemsView:UIView?
    
    //相册
    var btnPhoto:UIButton = UIButton()
    
    //闪光灯
    var btnFlash:UIButton = UIButton()
    
    //    //我的二维码
    //    var btnMyQR:UIButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //需要识别后的图像
        isNeedCodeImage = true
        
        //框向上移动10个像素
        scanStyle?.centerUpOffset += 10
        // self.navigationController?.interactivePopGestureRecognizer?.enabled=true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawBottomItems()
    }
    //    override func viewWillAppear(animated: Bool) {
    //        super.viewWillAppear(animated)
    //        self.navigationController?.navigationBar.hidden = false
    //        UIApplication.sharedApplication().statusBarHidden = false
    //    }
    
    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        
        for result:LBXScanResult in arrayResult
        {
            print("%@",result.strScanned ?? "")
        }
        
        let result:LBXScanResult = arrayResult[0]
        var transferData:String
        if let myResult = result.strScanned {
            if myResult.hasPrefix("http") && myResult.contains("cardvalue") {
                let range:Range = myResult.range(of: "cardvalue")!
                
                
                transferData = myResult.substring(from: myResult.index(after: range.upperBound))
                
//                if transferData.contains("&") {
//                    let strArr02 = transferData.components(separatedBy: "&")
//                    if let str =  strArr02.first {
//                        transferData = str
//                    }else{
//                        // strParamets = ""
//                    }
//                }
                
            }else{
                transferData = myResult
            }
        }else{
            transferData = ""
        }
        delegate?.popToSubmitCon(transferData)
        _ = self.navigationController?.popViewController(animated: true)
        //        let vc = ScanResultController()
        //        vc.codeResult = result
        //        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func drawBottomItems()
    {
        if (bottomItemsView != nil) {
            
            return;
        }
        
        let yMax = self.view.frame.maxY - self.view.frame.minY
        
        bottomItemsView = UIView(frame:CGRect( x: 0.0, y: yMax-100,width: self.view.frame.size.width, height: 100 ) )
        
        
        bottomItemsView!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        self.view .addSubview(bottomItemsView!)
        
        
        let size = CGSize(width: 65, height: 87);
        
        self.btnFlash = UIButton()
        btnFlash.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        btnFlash.center = CGPoint(x: bottomItemsView!.frame.width*3/4, y: bottomItemsView!.frame.height/2)
        btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControlState())
        btnFlash.addTarget(self, action: #selector(OznerScanViewController.openOrCloseFlash), for: UIControlEvents.touchUpInside)
        
        
        self.btnPhoto = UIButton()
        btnPhoto.bounds = btnFlash.bounds
        btnPhoto.center = CGPoint(x: bottomItemsView!.frame.width/4, y: bottomItemsView!.frame.height/2)
        btnPhoto.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_photo_nor"), for: UIControlState())
        btnPhoto.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_photo_down"), for: UIControlState.highlighted)
        btnPhoto.addTarget(self, action: #selector(openPhotoAlbum), for: UIControlEvents.touchUpInside)
        
        
        //        self.btnMyQR = UIButton()
        //        btnMyQR.bounds = btnFlash.bounds;
        //        btnMyQR.center = CGPointMake(CGRectGetWidth(bottomItemsView!.frame) * 3/4, CGRectGetHeight(bottomItemsView!.frame)/2);
        //        btnMyQR.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_myqrcode_nor"), forState: UIControlState.Normal)
        //        btnMyQR.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_myqrcode_down"), forState: UIControlState.Highlighted)
        //        btnMyQR.addTarget(self, action: #selector(QQScanViewController.myCode), forControlEvents: UIControlEvents.TouchUpInside)
        //
        bottomItemsView?.addSubview(btnFlash)
        bottomItemsView?.addSubview(btnPhoto)
        //        bottomItemsView?.addSubview(btnMyQR)
        
        self.view .addSubview(bottomItemsView!)
        
    }
    
    //开关闪光灯
    func openOrCloseFlash()
    {
        scanObj?.changeTorch();
        
        isOpenedFlash = !isOpenedFlash
        
        if isOpenedFlash
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_down"), for:UIControlState())
        }
        else
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControlState())
        }
    }
    
    
    
}