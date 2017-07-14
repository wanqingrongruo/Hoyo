//
//  GYDetailNewsVC.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/18.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD

let detailCellIndefier = "GYDetailNewCell"


class GYDetailNewsVC: UIViewController {
    
    var tableView: UITableView = UITableView()
    var titleStr: String?
    var sendUserID: String?
    var dataArr: [ScoreMessageModel] = []
        {
        didSet{
            tableView.reloadData()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instanceUI()
        getDatas()
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.scrolliewToBootom()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(GYDetailNewsVC.notice(_:)), name: NSNotification.Name(rawValue: messageNotification), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden=true
        title = titleStr
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(GYDetailNewsVC.dissBtnAction))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MessageModel.updateSourceMessageNum(sendUserID!, entityName: "")
        
    }
    
    func notice(_ sender: AnyObject) {
        dataArr =  ScoreMessageModel.GetSourceArr(sendUserID!, entityName: "")
        scrolliewToBootom()
    }
    
    /**
     获取本地数据
     */
    func getDatas() {
        dataArr =  ScoreMessageModel.GetSourceArr(sendUserID!, entityName: "")
    }
    
    fileprivate func instanceUI() {
        
        UserDefaults.standard.setValue("0", forKey: "messageNum")
        NotificationCenter.default.post(name: Notification.Name(rawValue: messageNotification), object: nil, userInfo: ["messageNum": "1"])
        tableView.frame = CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN - 64)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        //        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(tableView)
        tableView.register(GYDetailNewCell.self, forCellReuseIdentifier: detailCellIndefier)
        tableView.register(UINib(nibName: "OrderMessageCell",bundle: Bundle.main), forCellReuseIdentifier: "OrderMessageCell")
        tableView.register(UINib(nibName: "GYScoreMessageCell",bundle: Bundle.main), forCellReuseIdentifier: "GYScoreMessageCell")
    }
    
    /**
     自动跳转到最后一行
     */
    func scrolliewToBootom() {
        if dataArr.count >= 1 {
            tableView.scrollToRow(at: IndexPath(item: dataArr.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        }
    }
    
    func dissBtnAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(messageNotification)
    }
    
    
    
}

extension GYDetailNewsVC: UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row < dataArr.count else{
            return UITableViewCell()
        }
        
        let model: ScoreMessageModel = dataArr[indexPath.row]
        
        guard let _ = model.messageType else{
            return UITableViewCell()
        }
        
        switch model.messageType! {
        /// 可抢订单
        case "orderrob":
            let  cell =  tableView.dequeueReusableCell(withIdentifier: "OrderMessageCell") as! OrderMessageCell
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.lightGray
            cell.reloadUI(model)
            return cell
        ///普通消息
        case "string":
            if model.messageCon! == "有新的订单可以抢~" {
                let  cell =  tableView.dequeueReusableCell(withIdentifier: "OrderMessageCell") as! OrderMessageCell
                cell.selectionStyle = .none
                cell.backgroundColor = UIColor.lightGray
                cell.reloadUI(model)
                return cell
            } else {
                let  cell =  tableView.dequeueReusableCell(withIdentifier: detailCellIndefier) as! GYDetailNewCell
                cell.selectionStyle = .none
                cell.backgroundColor = UIColor.lightGray
                cell.reloadUI(model)
                //                cell.messageLabel.emojiDelegate = self
                //                
                //                let tap = UITapGestureRecognizer(target: self, action: #selector(GYDetailNewsVC.urlTapAction))
                //                
                //                cell.messageLabel.addGestureRecognizer(tap)
                
                return cell
            }
        /// 积分消息
        case "score":
            let cell = tableView.dequeueReusableCell(withIdentifier: "GYScoreMessageCell") as! GYScoreMessageCell
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.lightGray
            cell.reloadUI(model)
            return cell
        /// 指派订单
        case "ordernotify":
            let  cell =  tableView.dequeueReusableCell(withIdentifier: "OrderMessageCell") as! OrderMessageCell
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.lightGray
            cell.reloadUI(model)
            return cell
            
        default:
            
            //        cell.reloadUI(model)
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model: ScoreMessageModel = dataArr[indexPath.row]
        var timeErrand:Int  =  0
        if let time1 = model.createTime {
            timeErrand  =  calculateCurrenTimePoor(time1)
        }
        switch model.messageType! {
        case "string":
            //后台接口修改前 防止用户点击系统通知
            if model.messageCon! == "有新的订单可以抢~"  {
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showInfo("温馨提示", subTitle: "订单过于古老")
            }
            
            break
        case "ordernotify":
            if model.remark == "" || model.remark == nil{
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showInfo("指派订单", subTitle: "请查看首页->待处理")
                
            } else {
                orderPushToDetail(indexPath.row,timeCount: timeErrand)
            }
            break
        case "orderrob":
            
            if model.remark == "" || model.remark == nil {
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showInfo("温馨提示", subTitle: "此订单异常，无法查看")
                return
            }
            orderPushToDetail(indexPath.row,timeCount: timeErrand)
            break
        default:
            break
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model: ScoreMessageModel = dataArr[indexPath.row]
            guard model.msgId != "" else {
                return
            }
            ScoreMessageModel.deleteSourceOne(model.msgId!, entityName: "")
            dataArr.removeAll()
            getDatas()
            
        }
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return  "删除"
    }
    
    //    func urlTapAction() {
    //        print("点击了链接")
    //    }
    //
    //    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    //        
    //        if ((touch.view?.isKindOfClass(MLEmojiLabel.self)) != nil) {
    //            return true
    //        } else {
    //            return false
    //        }
    //        
    //    }
    
    
    //计算时间差
    func calculateCurrenTimePoor(_ timeStr: String) -> Int{
        let formatter = DateFormatter()
        //1.2设置时间的格式
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //1.3设置时间的区域（真机必须设置，否则会转换失败）
        formatter.locale = Locale(identifier: "en")
        //1.4转换字符串，转化好的时间是去除时区的时间
        
        if let da =  formatter.date(from: timeStr){
            let calendar = Calendar.current
            //1.判断是否是今天
            if calendar.isDateInToday(da) {
                //1.0 获取当前时间和系统时间之间的差距(秒数)
                let since = Int(Date().timeIntervalSince(da))
                //1.1是否是刚刚
                //1.2多少分钟以前
                print(since)
                if  since < 60 * 30 {
                    return 29
                }
                //1.3多少小时以前
                return 60
            }
            
        }
        return 666
    }
    
    func orderPushToDetail(_ num: Int,timeCount: Int) {
        MBProgressHUD.showAdded(to: view, animated: true)
        let model: ScoreMessageModel = dataArr[num]
        weak var weakSelf = self
        User.GetOrderNewDetails(model.remark!, success: { (order) in
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            print(order)
            var titleStr = ""
            //根据标题判断是否隐藏抢单按钮
            if order.checkState == "110000002" {
                if timeCount > 30{
                    titleStr = "订单详情"
                } else {
                    titleStr = "抢单"
                }
            } else {
                titleStr = "订单详情"
            }
            if weakSelf == nil {
                print("weakSelf nil 了")
                return
            }
            let detail = ListsDetailViewController(order:order, title: titleStr, distance:(weakSelf?.calculateDistance(Double(order.lng!), lat: Double(order.lat!)))!)
            detail.popToSuperConBlock = {
                print("抢单成功")
            }
            weakSelf?.orderPush(order,timeCount: timeCount)
            weakSelf?.navigationController?.pushViewController(detail, animated: true)
            }, failure: { (error) in
                MBProgressHUD.hide(for: weakSelf?.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showEdit("温馨提示", subTitle:error.localizedDescription)
        })
    }
    
    /**
     判断当前订单状态
     
     - parameter order: 订单信息
     */
    func orderPush(_ order: Order,timeCount: Int) {
        let alertView=SCLAlertView()
        if  order.checkState != "" {
            switch order.checkState! {
            case "110000002":
                if timeCount > 30 {
                    alertView.showInfo("温馨提示", subTitle: "此订单已过期", closeButtonTitle: "确定", duration: 2)
                } else {
                    alertView.showInfo("温馨提示", subTitle: "此订单可抢", closeButtonTitle: "确定", duration: 2)
                }
                break
            case "110000007":
                alertView.showInfo("温馨提示", subTitle: "此订单异常", closeButtonTitle: "确定", duration: 2)
                break
            case "110000008":
                alertView.showInfo("温馨提示", subTitle: "此订单已完成", closeButtonTitle: "确定", duration: 2)
                break
            case "110000011":
                alertView.showInfo("温馨提示", subTitle: "此订单已经接单", closeButtonTitle: "确定", duration: 2)
                break
            default:
                break
            }
        }
        
    }
    
    /**
     计算距离
     
     - parameter lng: 经度
     - parameter lat: 维度
     
     - returns:与当前用户的距离
     */
    func calculateDistance(_ lng:Double,lat:Double)->String{
        let  er:Double = 6378137 // 6378700.0f;
        let PI = 3.14159265
        var radLat1=radians(lat)
        let lat2=Double((User.currentUser?.lat)!)
        var radLat2 = radians(lat2)
        var radLng1=radians(lng)
        let lng2 = Double((User.currentUser?.lng)!)
        var radLng2 = radians(lng2)
        
        if( radLat1 < 0 )
        {radLat1 = PI/2 + fabs(radLat1)}// south
        if( radLat1 > 0 )
        {
            radLat1 = PI/2 - fabs(radLat1)
        }// north
        if( radLng1 < 0 )
        {
            radLng1 = PI*2 - fabs(radLng1)
        }//west
        if( radLat2 < 0 )
        {
            radLat2 = PI/2 + fabs(radLat2)
        }// south
        if( radLat2 > 0 )
        {
            radLat2 = PI/2 - fabs(radLat2)
        }// north
        if( radLng2 < 0 )
        {
            radLng2 = PI*2 - fabs(radLng2)
        }// west
        
        let x1 = er * cos(radLng1) * sin(radLat1)
        let y1 = er * sin(radLng1) * sin(radLat1)
        let z1 = er * cos(radLat1)
        let x2 = er * cos(radLng2) * sin(radLat2)
        let y2 = er * sin(radLng2) * sin(radLat2)
        let z2 = er * cos(radLat2)
        let dx = (x1-x2)*(x1-x2)
        let dy = (y1-y2)*(y1-y2)
        let dz = (z1-z2)*(z1-z2)
        let d = sqrt(dx+dy+dz)
        let tmpm = er*er+er*er-d*d
        let tmpn = 2*er*er
        //side, side, side, law of cosines and arccos
        let theta = acos((tmpm)/(tmpn))
        let  dist  = theta*er/1000.0
        print("\(dist)")
        return "\(dist)"
    }
    
    
    func radians(_ degrees:Double)->Double{
        return(degrees*3.14159265)/180.0
        
    }
    
}

//extension GYDetailNewsVC: MLEmojiLabelDelegate {
//    
//    func mlEmojiLabel(emojiLabel: MLEmojiLabel!, didSelectLink link: String!, withType type: MLEmojiLabelLinkType) {
//        
//        switch type {
//        case MLEmojiLabelLinkType.URL:
//            print("URL")
//        case MLEmojiLabelLinkType.PhoneNumber:
//            print("电话")
//        case MLEmojiLabelLinkType.Email:
//            print("邮箱")
//        default:
//            break
//        }
//        
//    }
//    
//}
