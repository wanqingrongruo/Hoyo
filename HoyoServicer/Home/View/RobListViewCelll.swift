//
//  RobListViewCellTableViewCell.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 28/3/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
@objc
protocol RobListViewCellDelegate: class{
    @objc optional func refreshFromRobList(_ order:Order)
}


class RobListViewCell : UITableViewCell {
    
    weak var delegate: RobListViewCellDelegate?
    var  tableView: RobListOneController?
    
    var timeStamp:Date?
    //右边显示的抢的图片
    @IBOutlet weak var qiangImage: UIImageView!
    
    @IBOutlet weak var checkState: UILabel!
    //用户地址
    @IBOutlet weak var address: UILabel!
    // 编号
    @IBOutlet weak var orderIdLabel: RNMultiFunctionLabel!
    // 预约时间
    @IBOutlet weak var appointmentTimeLabel: UILabel!
    //用户反馈信息
    @IBOutlet weak var message: UILabel!
    //头像
    @IBOutlet weak var headImage: UIImageView!
    //背景
    @IBOutlet weak var backView: UIView!
    
    //距离抢单结束还有多少时间
    @IBOutlet weak var modifyTime: UILabel!
    
    //显示距离
    @IBOutlet weak var distance: UILabel!
    //故障处理
    @IBOutlet weak var troubleHandle: UILabel!
    
    //产品类型信息等
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var orderNumShow: UIButton!
    
    @IBOutlet weak var DistanceLabelTopWIthProductBottomSpace: NSLayoutConstraint!
    //定时器
    var nstimer:Timer?
    //还有多少时间，系统规定最长是30分钟
    var timeInval = TimeInterval()
    
    var order:Order?
    var IsShow = true{
        didSet{
            message.isHidden = !IsShow
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        orderIdLabel.adjustsFontSizeToFitWidth = true
        appointmentTimeLabel.adjustsFontSizeToFitWidth = true
        
        
        backView.layer.cornerRadius = 5
        backView.layer.masksToBounds = true
        //
        
    }
    
    
    func  showCellText(_ order:Order,title:String,distance:String,row:Int)
    {
        self.order = order
        
        if title == "待评价" {
            orderNumShow.isHidden = true
        }
        
        if title == "抢单" {
            self.checkState.isHidden = true
            self.modifyTime.isHidden = false
            self.qiangImage.isHidden = false
        }
        else{
            
            self.checkState.isHidden = false
            self.modifyTime.isHidden = true
            self.qiangImage.isHidden = true
        }
        
        if let imageName = (NetworkManager.defaultManager?.getTroubleHandle(order.serviceItem!).lastObject as? String){
            
            self.headImage.image=UIImage(named:  imageName)
        }else{
            self.headImage.image=UIImage(named:  "defaultImage")
        }
        
        if let id =  order.id{
            orderIdLabel.text = "订单编号:  " + id
        }
       
        
        if order.appointmentTime != nil {
            if (order.appointmentTime!.hasPrefix("\\Date(") || order.appointmentTime!.hasPrefix("/Date(")) && (order.appointmentTime! as NSString).length >= 9 {
                
                let  timeStamp  =  DateTool.dateFromServiceTimeStamp(order.appointmentTime! )!
                
                self.appointmentTimeLabel.text =  "预约时间:  " + DateTool.stringFromDate(timeStamp, dateFormat: "yyyy-MM-dd HH:mm")
                
            } else {
                
                if order.appointmentTime! == "" {
                    self.appointmentTimeLabel.text = "预约时间:  " + "未知"
                }
                else{
                    
                    self.appointmentTimeLabel.text = "预约时间:  " + order.appointmentTime!
                }
               
            }

        }
        
        guard let _ = order.describe else {
            return
        }
        
        self.message.text = order.describe!
        
        guard let _ = order.province, let _ = order.city, let _ = order.country, let _ =  order.address else {
            return
        }
        self.address.text = "\( order.province!)\(order.city!)\(order.country!)\(order.address!)"
       // self.address.text = order.province! +  order.city! + order.country! + order.address!
        
        let tmp = (order.distance! as NSString).doubleValue
        self.distance.text = distance=="" ? String(format: "%.2lf",tmp)  + "km" :  String(format: "%.2lf",Double(distance)!)  + "km"
    
        
        if order.productModel! + order.productName! == ""{ //  productName为空时修改约束
            
            backView.removeConstraint(DistanceLabelTopWIthProductBottomSpace)
            let constraint = NSLayoutConstraint(item: self.distance, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.troubleHandle, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 5)
            backView.addConstraint(constraint)
//            backView.setNeedsUpdateConstraints()
//            backView.updateConstraintsIfNeeded()
//            backView.updateConstraints()
        }
        
        self.productName.text = order.productModel! + order.productName! //
        
        
        self.checkState.text = NetworkManager.defaultManager?.getTroubleHandle(order.checkState!).firstObject as? String
        
        if let name = (NetworkManager.defaultManager?.getTroubleHandle(order.serviceItem!).firstObject as? String)
        {
            self.troubleHandle.text = name
        }else{
            self.troubleHandle.text = "未知类型"
        }
        
        timeStamp  =  DateTool.dateFromServiceTimeStamp(order.modifyTime! )!
        
        if(title == "抢单"){
            
            self.nstimer?.invalidate()
            
            self.nstimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(RobListViewCell.getLastTime), userInfo: nil, repeats: true)
            RunLoop.main.add(nstimer!, forMode: RunLoopMode.commonModes)
            
            //                self.getTime(timeStamp!)
            
            
            
            
        }
        
    }
       
    
    
    func getLastTime(){
        
        let  nowDate = Date()
        
        
        let dateInterVal  =  nowDate.timeIntervalSince(self.timeStamp!)
        let lastTimeInterVal = 3600 - dateInterVal
        
        
        
        // let intTimeInval =  NSString(format: "%.0lf", lastTimeInterVal+120)
        if lastTimeInterVal <= 0{
            delegate?.refreshFromRobList!(self.order!)
            nstimer?.invalidate()
        }
        else
        {
            
            if  lastTimeInterVal/60>=1 {
                self.timeInval = lastTimeInterVal
                let time = String(format: "%02d",Int(lastTimeInterVal/60)) + ":" + String(format: "%02d",Int(lastTimeInterVal.truncatingRemainder(dividingBy: 60)))
              //  print("\(Int(lastTimeInterVal/60))"+":"+"\(Int(lastTimeInterVal.truncatingRemainder(dividingBy: 60)))")
               // print(time)
                self.modifyTime.text = time
            }
            else  {
                //            if (lastTimeInterVal==0) {
                //                delegate!.refreshFromRobList()
                //                self.nstimer?.invalidate()
                //                return
                //            }
                let time = "00" + ":" + String(format: "%02.0lf",lastTimeInterVal)
                self.modifyTime.text = time
                
            }
            
        }
        
    }
    
    @IBAction func orderNumAction(_ sender: AnyObject) {
        
        let alertView = SCLAlertView()
        alertView.addButton("确定", action: {})
        guard (self.order?.id) != nil else {
            alertView.showInfo("订单编号", subTitle: "此单异常");
            return
        }
        
        if self.order?.id == "" {
            self.order?.id = "此单异常"
        }
        alertView.showInfo("订单编号", subTitle: self.order!.id!);
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
