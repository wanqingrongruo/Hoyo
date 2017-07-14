    //
    //  GetTimeViewController.swift
    //  HoyoServicer
    //
    //  Created by zane on 16/6/1.
    //  Copyright © 2016年 com.ozner.net. All rights reserved.
    //
    
    import UIKit
    import MBProgressHUD
    import SJFluidSegmentedControl
    
    class GetTimeViewController: UIViewController,UITextViewDelegate{
        
        enum SelectedTime {
            case isLeft
            case isRight
        }
        
        @IBOutlet weak var bLable: UILabel!//必填
        @IBOutlet weak var aLable: UILabel!//必填
        @IBOutlet weak var plaLable: UILabel!//二次上门理由提示符
        @IBOutlet weak var reason: UITextView!//理由
        @IBOutlet weak var timeLable: UILabel!//时间
        @IBOutlet weak var dataLable: UILabel!//日期
        
        @IBOutlet weak var segmentedControl: SJFluidSegmentedControl!
        
        @IBOutlet weak var timeTitleView: UIView!
        @IBOutlet weak var timeSelecteView: UIView!
        
        @IBAction func timeButton(_ sender: AnyObject) {//时间选择器
            DatePickerDialog().show("选择日期", doneButtonTitle: "确认", cancelButtonTitle: "取消", datePickerMode: .date,formate : "YYYY-MM-dd") {
                (date) -> Void in
                self.dataLable.text="\(date)"
                print("选择日期\(date)")
            }
            
        }
        @IBAction func dayBTN(_ sender: AnyObject) {
            DatePickerDialog().show("选择时间", doneButtonTitle: "确认", cancelButtonTitle: "取消", datePickerMode: .time,formate : "HH:mm:ss") {
                (date) -> Void in
                self.timeLable.text = "\(date)"
                print("选择时间")
            }
            
        }
        var month:Int?//初始月
        var day:Int?//初始日总数
        var days:Int?//改变月份后日期总数
        var orderDetail:OrderDetail?
        
        lazy var currentSelectedOption:SelectedTime = { //
            return .isLeft
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.navigationController?.navigationBar.isHidden = false
            UIApplication.shared.isStatusBarHidden = false
            
            // self.navigationController?.interactivePopGestureRecognizer?.enabled=true
            plaLable.isHidden=false
            self.reason.delegate=self
            self.title="提交上门时间"
            self.bLable.layer.borderColor=UIColor(red: 1, green: 127/255, blue: 0, alpha: 1).cgColor
            self.bLable.layer.borderWidth=1
            self.bLable.layer.cornerRadius=8//圆角
            self.aLable.layer.borderColor=UIColor(red: 1, green: 127/255, blue: 0, alpha: 1).cgColor
            self.aLable.layer.borderWidth=1
            self.aLable.layer.cornerRadius=8//圆角
            
            
            
            //        reason.becomeFirstResponder()
            self.setNavigationItem("back.png", selector: #selector(doBack), isRight: false)
            
            self.setNavigationItem("历史记录", selector: #selector(pushToHistoryCon), isRight: true)
            reason.resignFirstResponder()
            
            
            segmentedControl.textFont = .systemFont(ofSize: 16, weight: UIFontWeightSemibold)
            segmentedControl.delegate = self
            segmentedControl.dataSource = self
            // Do any additional setup after loading the view.
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            
        }
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
        convenience  init(orderDetail : OrderDetail) {
            
            var nibNameOrNil = String?("GetTimeViewController.swift")
            if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
            {
                nibNameOrNil = nil
            }
            self.init(nibName: nibNameOrNil, bundle: nil)
            
            self.orderDetail = orderDetail
            
        }
        required init(coder aDecoder: NSCoder) {
            
            fatalError("init(coder:) has not been implemented")
            
        }
        
        
        func pushToHistoryCon(){
            let historyCon=HistoryTableViewController(orderDetail: orderDetail!)
            self.navigationController?.pushViewController(historyCon, animated: true)
            
        }
        override func doBack() {
            self.plaLable.isHidden=false
            self.navigationController?.isNavigationBarHidden = true
            UIApplication.shared.isStatusBarHidden = true
            _ =  self.navigationController?.popViewController(animated: true)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.isNavigationBarHidden = false
            UIApplication.shared.isStatusBarHidden = false
        }
        
        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            plaLable.isHidden=true
            return true
        }
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if reason.text == ""{
                plaLable.isHidden=false
            }
            reason.resignFirstResponder()
            
        }
        @IBAction func Get(_ sender: AnyObject) {//提交上门时间
            
            guard reason.text != "" else{
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: { })
                alertView.showError("提示", subTitle: "请填写申请理由")
                
                return
            }
            
            let param = NSMutableDictionary()
            param.setValue(orderDetail?.id, forKey: "orderid")
            param.setValue(reason.text, forKey: "remark")
            
            switch currentSelectedOption {
            case .isLeft:
                
                guard dataLable.text != "选择日期" && timeLable.text != "选择时间" else{
                    
                    let alertView=SCLAlertView()
                    alertView.addButton("确定", action: { })
                    alertView.showError("提示", subTitle: "请选择上门时间")
                    
                    return
                }
                
                
                param.setValue("\(dataLable.text!)"+" "+"\(timeLable.text!)"
                    , forKey: "time")
                //print("\(dataLable.text!)"+" "+"\(timeLable.text!)")
               
               // print(param)
                MBProgressHUD.showAdded(to: self.view, animated: true)
                subscibledTime(param: param)
            
                break
            case .isRight:
               // print(param)
                MBProgressHUD.showAdded(to: self.view, animated: true)
                subscibledTime(param: param)
                break
            
            }
            
          
            
        }      //  print(orderDetail?.id ?? "")
          
        
        // 预约上门
        func subscibledTime(param: NSMutableDictionary) {
            User.SubmitTime(param, success: {
                
                MBProgressHUD.hide(for: self.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: { [weak self]() in
                    
                    self?.skipToRobOneVC() // 跳转控制器
                })
                alertView.showSuccess("提示", subTitle: "提交成功")
            }) { (error) in
                print(error.localizedDescription)
                
                MBProgressHUD.hide(for: self.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("提示", subTitle: error.localizedDescription)
            }

        }
        
//        // 未确定时间
//        func dontSepecificTime(param: NSMutableDictionary) {
//            // TO DO
//        }

        
        // 跳转控
        func skipToRobOneVC(){
            
            guard let step = self.navigationController?.viewControllers.count else {
                
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "导航栈错误,跳转失败,请手动返回")
                return
            }
            
            guard step >= 3 else {
                
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "导航栈错误,跳转失败,请手动返回")
                return
            }
            
            guard let vc = navigationController?.viewControllers[step-3] else {
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "导航栈错误,跳转失败,请手动返回")
                return
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "UPDATEWAITORDER"), object: nil) // 发送通知到ListsDetailViewController让其更新数据
            _ = self.navigationController?.popToViewController(vc, animated: true)
            
            //        guard let _ = navigationController?.viewControllers else{
            //
            //            let alertView=SCLAlertView()
            //            alertView.addButton("ok", action: {})
            //            alertView.showError("提示", subTitle: "对不起,跳转失败,请手动返回")
            //            return
            //        }
            //        for vc in ( navigationController?.viewControllers)! {
            //
            //            if vc.isKind(of: RobListOneController.self){
            //
            //                NotificationCenter.default.post(name: Notification.Name(rawValue: "UPDATEWAITORDER"), object: nil) // 发送通知到ListsDetailViewController让其更新数据
            //               _ =  navigationController?.popToViewController(vc, animated: true)
            //            }
            //        }
            
        }
        
    }
    
    extension GetTimeViewController: SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate {
        
        func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
            return 2
        }
        
        func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleForSegmentAtIndex index: Int) -> String? {
            if index == 0 {
                return "预约上门"
            }
            return "未确定时间"
        }
        
        func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                              gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
            switch index {
            case 0:
                return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0),
                        UIColor(red: 97 / 255.0, green: 199 / 255.0, blue: 234 / 255.0, alpha: 1.0)]
            case 1:
                return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0),
                        UIColor(red: 97 / 255.0, green: 199 / 255.0, blue: 234 / 255.0, alpha: 1.0)]
            case 2:
                return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0),
                        UIColor(red: 97 / 255.0, green: 199 / 255.0, blue: 234 / 255.0, alpha: 1.0)]
            default:
                break
            }
            return [.clear]
        }
        
        func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                              gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
            switch bounce {
            case .left:
                return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0)]
            case .right:
                return [UIColor(red: 9 / 255.0, green: 82 / 255.0, blue: 107 / 255.0, alpha: 1.0)]
            }
        }
        
        
        func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didChangeFromSegmentAtIndex fromIndex: Int, toSegmentAtIndex toIndex: Int) {
            switch fromIndex {
            case 1:
                currentSelectedOption = .isLeft
                timeTitleView.isHidden = !timeTitleView.isHidden
                timeSelecteView.isHidden = !timeSelecteView.isHidden
                
                break
            case 0:
                currentSelectedOption = .isRight
                timeTitleView.isHidden = !timeTitleView.isHidden
                timeSelecteView.isHidden = !timeSelecteView.isHidden
                
                break
            default:
                break
            }
            
        }
    }
    
