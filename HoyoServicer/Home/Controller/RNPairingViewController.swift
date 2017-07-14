//
//  RNPairingViewController.swift
//  HoyoServicer
//
//  Created by 郑文祥 on 2017/6/19.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

enum OznerDeviceType:String {
    
    case Water_Bluetooth="Ozner RO"
    case Cup="CP001"
    case Tap="SC001"
    case TDSPan="SCP001"
    case Water_Wifi="MXCHIP_HAOZE_Water"
    case Air_Blue="FLT001"
    case Air_Wifi="FOG_HAOZE_AIR"
    case WaterReplenish="BSY001"
    
    case Water_Wifi_JZYA1XBA8CSFFSF="JZY-A1XB-A8_CSF&FSF"
    case Water_Wifi_JZYA1XBA8DRF="JZY-A1XB-A8_DRF"
    case Water_Wifi_JZYA1XBLG_DRF="JZY-A1XB-LG_DRF"
    
    //case Water_Wifi_Ayla="Water_Wifi_Ayla"
    //case Air_Wifi_Ayla="Air_Wifi_Ayla"
    
    
    static func getType(type:String) -> OznerDeviceType {
        switch type {
        case "580c2783":
            return OznerDeviceType.Air_Wifi
        case "16a21bd6":
            return OznerDeviceType.Water_Wifi
        default:
            return OznerDeviceType(rawValue: type)!
        }
    }
}

class RNPairingViewController: UIViewController {
    
    @IBOutlet var animalImg: UIImageView!
    
    var orderDetail:OrderDetail? // 订单详情--从上个界面带来
    var currentDevice = ROWaterPurufier()
    
    var currDeviceType = OznerDeviceType.Water_Bluetooth
    
    var callBack: (Bool)->()
    
    var pairTimer:Timer?
    //每隔2秒搜寻下蓝牙设备，总共搜索不到30秒，搜到就就跳转到成功
    var blueDevices=[ROWaterPurufier]()
    var blueTimer:Timer?
    var remainTimer=0 //倒计时60秒
    
    var count = 0
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, callBack:@escaping (Bool) -> ()) {
    
        self.callBack = callBack
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "正在配对"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pairTimer =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(selectPairType), userInfo: nil, repeats: false)//1秒动画，然后选择配对方式
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animalImg.oznerRotateSpeed=180
        
        self.count = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        blueTimer?.invalidate()
        pairTimer?.invalidate()
        pairTimer = nil
        
        blueTimer = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if pairTimer != nil {
            pairTimer?.invalidate()
            pairTimer = nil
        }
        
        if blueTimer != nil {
            blueTimer?.invalidate()
            blueTimer = nil
        }
    }
    
    deinit {
        //防止手势返回时导致界面跳转无导航以及界面
        
        if pairTimer != nil {
            pairTimer?.invalidate()
            pairTimer = nil
        }
        
        if blueTimer != nil {
            blueTimer?.invalidate()
            blueTimer = nil
        }
      
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func selectPairType()  {
        if pairTimer == nil {
            return
        }
        switch currDeviceType {
        case OznerDeviceType.Cup,OznerDeviceType.Tap,OznerDeviceType.TDSPan,OznerDeviceType.Air_Blue,OznerDeviceType.WaterReplenish,OznerDeviceType.Water_Bluetooth://蓝牙配对
            if pairTimer == nil {
                return
            }
            StarBluePair()
        case OznerDeviceType.Water_Wifi,OznerDeviceType.Air_Wifi,.Water_Wifi_JZYA1XBA8CSFFSF,.Water_Wifi_JZYA1XBA8DRF,.Water_Wifi_JZYA1XBLG_DRF://Wifi配对
            if pairTimer == nil {
                return
            }
            // self.performSegue(withIdentifier: "showWifiPair", sender: nil)
            break
        }
    }
    
    
    
    func StarBluePair() {
        if pairTimer == nil {
            return
        }
        remainTimer=60
        blueDevices=[ROWaterPurufier]()
        blueTimer=Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(bluePairing), userInfo: nil, repeats: true)
    }
    @objc private func bluePairing() {
        
        if blueTimer==nil || remainTimer<0 {
            return
        }
        remainTimer-=2
        let deviceIOArr=OznerManager.instance().getNotBindDevices()
        for io in deviceIOArr! {
            if OznerManager.instance().checkisBindMode(io as! BaseDeviceIO) == true
            {
                let deviceType = OznerDeviceType.getType(type: (io as! BaseDeviceIO).type)
                
                if currDeviceType == deviceType  {
                    if let device=OznerManager.instance().getDeviceBy(io as! BaseDeviceIO) {
                        
                        blueDevices.append(device as! ROWaterPurufier)
                        
                        blueTimer?.invalidate()
                        pairTimer?.invalidate()
                        break
                        // Int((device as! ROWaterPurufier).settingInfo.waterRemindDays)
                    }
                }
                
            }
        }
        if blueDevices.count>0 {
           
            let device  = blueDevices[0]
            device.delegate = self
            
        }else if remainTimer<0{
            skipVC("showfailed")
        }
        
    }
    
    func skipVC(_ type: String) {
        
        defer {
            OznerManager.instance().remove(currentDevice)
            
            self.currentDevice = ROWaterPurufier()
            blueDevices=[ROWaterPurufier]()
            
            blueTimer?.invalidate()
            pairTimer?.invalidate()
            pairTimer = nil
            
            blueTimer = nil
        }
        
        switch type {
        case "showsuccess":
            // 成功界面
            let confirmVC = RNConfirmWaterValueViewController(nibName: "RNConfirmWaterValueViewController", bundle: nil, callBack: { [weak self](isLined) in
                self?.callBack(isLined)
                _ = self?.navigationController?.popViewController(animated: true)
            })
            confirmVC.orderDetail = self.orderDetail
            confirmVC.deviceInfo = self.currentDevice
            self.navigationController?.pushViewController(confirmVC, animated: true)
            break
        case "showfailed":
            // 失败界面
            let pairFailVC = RNPairFailViewController(nibName: "RNPairFailViewController", bundle: nil)
            //            self.present(pairFailVC, animated: true, completion: {
            //                //
            //            })
            self.navigationController?.pushViewController(pairFailVC, animated: true)
            break
        default:
            break
        }
    }
}

//MARK: - event response

extension RNPairingViewController {
    
    func disMissBtn(){
        
        self.callBack(false)
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}

extension RNPairingViewController: OznerDeviceDelegate{
    
    func oznerDeviceStatusUpdate(_ device: OznerDevice!) {
     
        switch device.connectStatus() {
        case Connected:
            device.updateSettings({ (error) in
                //
            })
            
//            self.currentDevice = device as! ROWaterPurufier
//            print("=========\(self.currentDevice.settingInfo.waterRemindDays)")
//            print(self.currentDevice.settingInfo.waterStopDate)
//            skipVC("showsuccess")
           
        default:
            break
        }

    }
    
    func oznerDeviceSensorUpdate(_ device: OznerDevice!) {
        
        self.count += 1
        
        
//        self.currentDevice = device as! ROWaterPurufier
//                    print("=========\(self.currentDevice.settingInfo.waterRemindDays)")
//                    print(self.currentDevice.settingInfo.waterStopDate)
        if count == 5{
            
            self.currentDevice = device as! ROWaterPurufier
//            print("=========\(self.currentDevice.settingInfo.waterRemindDays)")
//            print(self.currentDevice.settingInfo.waterStopDate)
            skipVC("showsuccess")
//            if (device as! ROWaterPurufier).settingInfo.waterStopDate != Date(timeIntervalSince1970: 0) {
//   
//                return
//            }else{
//                self.count = 0
//            }
        }
       
       // print("***************count = \(count)")
    }
}

