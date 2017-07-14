//
//  ListsDetailViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 11/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

import MBProgressHUD

class ListsDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DetailViewCellDelegate {
    var orderID :String!
    var order:Order?
    var  detailArr  = [AnyObject]()
    var popToSuperConBlock : (()->Void)?
    var orderDetail :OrderDetail?
    var textTitle:String?
    var distance:String?
    
    // 支付信息
    var payInfos = [RNPAYDetailModel]()
    
    // 位置编码
    lazy var geoCoder: CLGeocoder = {
       return CLGeocoder()
    }()
   
    
    var tableView :UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.navigationController?.interactivePopGestureRecognizer?.enabled=true

        if let t = textTitle {
            navigationItem.title = t
        }else{
            navigationItem.title = "待处理"
        }
      
        
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        initView()
        tableView.estimatedRowHeight = 300
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.loadData()
       // self.toptitle.text! = textTitle!
        self.tableView.separatorStyle = .none
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
       // self.navigationController?.navigationBar.translucent = true
        //UIApplication.sharedApplication().statusBarHidden = true
        
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
       //  self.navigationController?.navigationBar.translucent = false
    }
    
    
    var detailViewCell:DetailViewCell!
    var detailTableViewCell2:DetailTableViewCell2!
    var detailTableViewCell3:DetailTableViewCell3!
    func initView(){
        // 初始化tableView的数据
        self.tableView=UITableView(frame:CGRect(x: 0, y: 0, width: WIDTH_SCREEN,height: HEIGHT_SCREEN - HEIGHT_NavBar),style:UITableViewStyle.plain)
        // 设置tableView的数据源
        self.tableView!.dataSource=self
        // 设置tableView的委托
        self.tableView!.delegate = self
        self.view.addSubview(self.tableView!)
        //
        self.tableView.register(UINib(nibName:"DetailViewCell", bundle:nil), forCellReuseIdentifier:"DetailViewCell")
        self.tableView.register(UINib(nibName:"DetailTableViewCell2", bundle:nil), forCellReuseIdentifier:"DetailTableViewCell2")
        self.tableView.register(UINib(nibName:"DetailTableViewCell3", bundle:nil), forCellReuseIdentifier:"DetailTableViewCell3")
        self.tableView.register(UINib(nibName:"RNPatButtonTableViewCell", bundle:nil), forCellReuseIdentifier:"RNPatButtonTableViewCell")
        
//        detailViewCell=NSBundle.mainBundle().loadNibNamed("DetailViewCell", owner: nil, options: nil).last as? DetailViewCell
//        detailViewCell.delegate = self
//        detailViewCell.selectionStyle = .None
//        detailViewCell.backgroundColor = UIColor.grayColor()
//        detailViewCell.finish.userInteractionEnabled=true
//        detailViewCell.toAddressMapButton.addTarget(self, action: #selector(toAddressMapClick), forControlEvents: .TouchUpInside)
//        //2
//        detailTableViewCell2=NSBundle.mainBundle().loadNibNamed("DetailTableViewCell2", owner: nil, options: nil).last as? DetailTableViewCell2
//        detailTableViewCell2.selectionStyle = .None
//        detailTableViewCell2.backgroundColor = UIColor.grayColor()
//        
//        //3
//        detailTableViewCell3=NSBundle.mainBundle().loadNibNamed("DetailTableViewCell3", owner: nil, options: nil).last as? DetailTableViewCell3
//        detailTableViewCell3.selectionStyle = .None
//        detailTableViewCell3.backgroundColor = UIColor.grayColor()
        
        
        
    }
    
    
    // DetailViewCell 中 位置按钮点击事件
    func toAddressMapClick()  {
        
        guard let address = detailViewCell.address.text else {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "没有目的地址,无法进行导航")
            return
            
        }
        
        // 编码
        geoCoder.geocodeAddressString(address, completionHandler: { (place, error) in
            if error == nil {
                // 编码成功
                guard let result = place else {
                    let alertView=SCLAlertView()
                    alertView.addButton("确定", action: {})
                    alertView.showError("提示", subTitle: "地址编码失败,无法导航")
                    return
                }
                
                guard let l = result.first?.location?.coordinate.latitude, let n = result.first?.location?.coordinate.longitude else{
                    let alertView=SCLAlertView()
                    alertView.addButton("确定", action: {})
                    alertView.showError("提示", subTitle: "地址编码失败,无法导航")
                    return
                }
                
              
                let tmpclLocation = CLLocationCoordinate2D(latitude: l, longitude: n)
                let tmpMap = ZBMapViewController(location: tmpclLocation, locationString: address)
                self.present(tmpMap, animated: true, completion: nil)

                
            }else{
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "地址编码失败,无法导航")
                
                return
            }
        })
        
       
//        
//        guard detailArr.count > 0 else {
//            let alertView=SCLAlertView()
//            alertView.addButton("确定", action: {})
//            alertView.showError("提示", subTitle: "没有订单详情数据")
//            return
//        }
//        
//        var tmpLat:Double = 0
//        var tmpLng:Double = 0
//        
//        var isgeocoder = "" // 鉴别经纬度是否是用地址编码得来
//        var tmpclLocation = CLLocationCoordinate2D(latitude: tmpLat, longitude: tmpLng)
//
//        if let lat = (detailArr[0] as! OrderDetail).lat, let lng = (detailArr[0] as! OrderDetail).lng {
//           
//             tmpLat = NSString(format: "%@", lat).doubleValue
//             tmpLng = NSString(format: "%@", lng).doubleValue
//             tmpclLocation = CLLocationCoordinate2D(latitude: tmpLat, longitude: tmpLng)
//
//        }else{
//            
//            guard let address = detailViewCell.address.text else {
//                let alertView=SCLAlertView()
//                alertView.addButton("确定", action: {})
//                alertView.showError("提示", subTitle: "没有目的地址,无法进行导航")
//                return
//                
//            }
//            
//            // 编码
//            
//            geoCoder.geocodeAddressString(address, completionHandler: { (place, error) in
//                if error == nil {
//                    // 编码成功
//                    guard let result = place else {
//                        let alertView=SCLAlertView()
//                        alertView.addButton("确定", action: {})
//                        alertView.showError("提示", subTitle: "地址编码失败,无法导航")
//                        return
//                    }
//                    
//                    guard let l = result.first?.location?.coordinate.latitude, let n = result.first?.location?.coordinate.longitude else{
//                        let alertView=SCLAlertView()
//                        alertView.addButton("确定", action: {})
//                        alertView.showError("提示", subTitle: "地址编码失败,无法导航")
//                        return
//                    }
//                    
//                    tmpLat = l
//                    tmpLng = n
//                    tmpclLocation = CLLocationCoordinate2D(latitude: l, longitude: n)
//                    isgeocoder = "地址编码"
//                    
//                }else{
//                    let alertView=SCLAlertView()
//                    alertView.addButton("确定", action: {})
//                    alertView.showError("提示", subTitle: "地址编码失败,无法导航")
//                    
//                    return
//                }
//            })
//            
//            let tmpMap = ZBMapViewController(location: tmpclLocation, locationString: address)
//            tmpMap.isgeocoder = isgeocoder
//            self.present(tmpMap, animated: true, completion: nil)
//
//        }
//        
//        
//        // TO DO: 重复这段代码一点都不优雅,等有时间回来修改...
//        
//        if tmpLat == 0 && tmpLng == 0 {
//            
//            guard let address = detailViewCell.address.text else {
//                let alertView=SCLAlertView()
//                alertView.addButton("确定", action: {})
//                alertView.showError("提示", subTitle: "没有目的地址,无法进行导航")
//                return
//                
//            }
//
//            // 编码
//            MBProgressHUD.showAdded(to: self.view, animated: true)
//            geoCoder.geocodeAddressString(address, completionHandler: { (place, error) in
//                MBProgressHUD.showAdded(to: self.view, animated: true)
//                if error == nil {
//                    // 编码成功
//                    guard let result = place else {
//                        let alertView=SCLAlertView()
//                        alertView.addButton("确定", action: {})
//                        alertView.showError("提示", subTitle: "地址编码失败,无法导航")
//                        return
//                    }
//                    
//                    guard let l = result.first?.location?.coordinate.latitude, let n = result.first?.location?.coordinate.longitude else{
//                        let alertView=SCLAlertView()
//                        alertView.addButton("确定", action: {})
//                        alertView.showError("提示", subTitle: "地址编码失败,无法导航")
//                        return
//                    }
//                    
//                    tmpLat = l
//                    tmpLng = n
//                    tmpclLocation = CLLocationCoordinate2D(latitude: l, longitude: n)
//                    isgeocoder = "地址编码"
//                    
//                    let tmpMap = ZBMapViewController(location: tmpclLocation, locationString: address)
//                    tmpMap.isgeocoder = isgeocoder
//                    self.present(tmpMap, animated: true, completion: nil)
//
//                    
//                }else{
//                    let alertView=SCLAlertView()
//                    alertView.addButton("确定", action: {})
//                    alertView.showError("提示", subTitle: "地址编码失败,无法导航")
//                    
//                    return
//                }
//            })
//            
//        }else{
//           
//            var address = "没有地址信息"
//            if let addr = detailViewCell.address.text {
//                address = addr
//            }
//
//            let tmpMap = ZBMapViewController(location: tmpclLocation, locationString: address)
//            tmpMap.isgeocoder = isgeocoder
//            self.present(tmpMap, animated: true, completion: nil)
//
//        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(order : Order,title :String,distance:String) {
        
        var nibNameOrNil = String?("ListsDetailViewController.swift")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        
        self.orderID = order.id!
        self.order=order
        textTitle = title
        self.distance=distance
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    // MARK:  Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // warning Incomplete implementation, return the number of rows
        
        var orderState: String? = ""
        if let state = order?.checkState{
          orderState = NetworkManager.defaultManager?.getTroubleHandle(state).firstObject as? String // 订单状态,根据订单状态显示不同的行数
        }
        
         //  if ( orderState == "等待用户支付" || orderState == "订单已经接单" || orderState == "订单审核通过")
        if ( orderState == "订单已经接单" || orderState == "订单审核通过"){
            return 1
        }
        
        if orderState == "等待工程师支付" {
             return detailArr.count + 1
        }
        
        return detailArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let orderState = NetworkManager.defaultManager?.getTroubleHandle(order!.checkState!).firstObject as? String // 订单状态,根据订单状态显示不同 cell
        
        // if ( orderState == "等待用户支付" || orderState == "订单已经接单" || orderState == "订单审核通过")
        if ( orderState == "订单已经接单" || orderState == "订单审核通过")
        {
            
            let   cell  = tableView.dequeueReusableCell(withIdentifier: "DetailViewCell") as! DetailViewCell
            self.detailViewCell=cell
            if detailArr.count != 0{
                cell.showCellText(detailArr[0] as! OrderDetail, title: navigationItem.title!,distance: self.distance!, payInfos: payInfos, vc: self)
                cell.toAddressMapButton.addTarget(self, action: #selector(toAddressMapClick), for: .touchUpInside)
            }
            cell.delegate = self
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.gray
            cell.frame = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame
                .size.height)
                        
            if orderState == "等待用户支付" {
                
                cell.finish.isUserInteractionEnabled=false
                cell.finish.backgroundColor=COLORRGBA(160, g: 170, b: 173, a: 1)
                cell.finish.tintColor=UIColor.white
            }
            
            return cell
            
        }
        else{
            switch (detailArr.count) as Int {
            case 1 :
                if indexPath.row == 0  {
                    
                    
                    let cell  = tableView.dequeueReusableCell(withIdentifier: "DetailViewCell") as! DetailViewCell
                     self.detailViewCell=cell
                    cell.showCellText(detailArr[0] as! OrderDetail, title: navigationItem.title!,distance: self.distance!, payInfos: payInfos, vc: self)
                    cell.toAddressMapButton.addTarget(self, action: #selector(toAddressMapClick), for: .touchUpInside)
                    cell.delegate = self
                    cell.selectionStyle = .none
                    cell.backgroundColor = UIColor.gray
                    cell.frame = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame
                        .size.height)
                    
                    cell.YQView.removeFromSuperview()
                    
                    return cell
                }
                
                else if indexPath.row == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RNPatButtonTableViewCell") as! RNPatButtonTableViewCell
                    cell.selectionStyle = .none
                    
                    if payInfos.count == 0 {
                        cell.payButton.isEnabled = false
                        cell.payButton.backgroundColor = UIColor.gray
                    }
                    cell.frame = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame
                        .size.height)

                    
                    cell.delegate = self
                    
                    return cell
                }

                break
            case 2:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DetailViewCell") as! DetailViewCell
                     self.detailViewCell=cell
                     cell.toAddressMapButton.addTarget(self, action: #selector(toAddressMapClick), for: .touchUpInside)
                    cell.showCellText(detailArr[indexPath.row] as! OrderDetail, title: navigationItem.title!,distance: self.distance!, payInfos: payInfos, vc: self)
                    cell.delegate = self
                    cell.selectionStyle = .none
                    cell.backgroundColor = UIColor.gray
                    cell.frame = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame
                        .size.height)
                    
                    cell.YQView.removeFromSuperview()
                    
                    return cell
                }
                else if indexPath.row == 1{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell2") as! DetailTableViewCell2
                    cell.showDetail2Text(detailArr[indexPath.row] as! FinshDetail)
                    cell.selectionStyle = .none
                    cell.backgroundColor = UIColor.gray
                    cell.frame = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame
                        .size.height)
                    return cell
                }
                
                else if indexPath.row == 2 {
                    
                    let cell                           = tableView.dequeueReusableCell(withIdentifier: "RNPatButtonTableViewCell") as! RNPatButtonTableViewCell
                    cell.selectionStyle                = .none
                    
                    if payInfos.count == 0 {
                        cell.payButton.isEnabled       = false
                        cell.payButton.backgroundColor = UIColor.gray
                    }
                    cell.frame                         = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame.size.height)
                    cell.delegate                      = self
                    
                    return cell
                }

                
                
            case 3:
                
                if indexPath.row == 0 {
                    let cell             = tableView.dequeueReusableCell(withIdentifier: "DetailViewCell") as! DetailViewCell
                    self.detailViewCell  = cell
                    cell.toAddressMapButton.addTarget(self, action: #selector(toAddressMapClick), for: .touchUpInside)
                    cell.showCellText(detailArr[indexPath.row] as! OrderDetail, title: navigationItem.title!,distance: self.distance!, payInfos: payInfos, vc: self)
                    cell.delegate        = self
                    cell.selectionStyle  = .none
                    cell.backgroundColor = UIColor.gray
                    cell.frame           = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame
                        .size.height)
                    
                    
                    cell.YQView.removeFromSuperview()
                    return cell
                }
                else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell2") as! DetailTableViewCell2
                    cell.showDetail2Text(detailArr[indexPath.row] as! FinshDetail)
                    cell.selectionStyle = .none
                    cell.backgroundColor = UIColor.gray
                    cell.frame = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame
                        .size.height)
                    return cell
                }
                else  if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell3") as! DetailTableViewCell3
                    cell.showDetail3Text(detailArr[indexPath.row] as! Settlementinfo)
                    cell.selectionStyle = .none
                    cell.backgroundColor = UIColor.gray
                    cell.frame = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame
                        .size.height)
                    return cell
                }
                else if indexPath.row == 3 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RNPatButtonTableViewCell") as! RNPatButtonTableViewCell
                    cell.selectionStyle = .none
                    
                    if payInfos.count == 0  {
                        cell.payButton.isEnabled = false
                        cell.payButton.backgroundColor = UIColor.gray
                    }
                    cell.frame = CGRect(x: 0, y: -64, width: WIDTH_SCREEN, height: cell.frame
                        .size.height)
                    cell.delegate = self
                    
                    return cell
                }

                
            default:
                break
                
            }

        
            
    }
    
    let cell = UITableViewCell()
    return cell
    
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     //   let y = self.tableView.bounds.origin.y
        
        
//        if  y <= 0{
//            self.navBar.alpha = 0.58
//            print("\(self.navBar.alpha)" + "--------")
//        }
//        else{
//          //  self.navBar.alpha = (self.tableView.bounds.origin.y+80)/230
//            
//            print(self.navBar.alpha)
//        }
    }
    
    func loadData(){
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        User.GetOrderDetails(self.orderID, success: {[weak self] (arr,payInfos) in
            if let strongSelf = self{
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
               // print(arr)
                self?.detailArr = arr
//                print("成功.....-------")
//                print(self!.detailArr)
//                print("成功.....-------")
                
                self?.payInfos = payInfos
                //print(arr)
                strongSelf.tableView.reloadData()
            } }) { (error) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                print(error.localizedDescription)
        }
        
        
    }
    
    //实现详情页头的代理
    func backToSuperCon() {
        
        disMissBtn()
        popToSuperConBlock!()
        
        
    }
    
    func showBrowPhtotoCon(_ cell :BrowseCollectionViewCell,browseItemArray:NSMutableArray) {
        
        let bvc = MSSBrowseNetworkViewController.init(browseItemArray: browseItemArray as [AnyObject], currentIndex: cell.imageView.tag - 100)
        self.present(bvc!, animated: false, completion: nil)
    }
    
    // 完成
    func pushToFinshView()
    {
        
        if let dataArr = self.detailArr.first as? OrderDetail {
            
            let submit  =  SubmitController(orderDetail: dataArr, payInfos: self.payInfos)
            self.navigationController?.pushViewController(submit, animated: true)

        }else{
         
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "抱歉,未获取到订单数据,请重试")
        }
        
    }
    
    //其他操作
    func pushToSubmitView() {
        
        // 选择具体操作
        let alertView=SCLAlertView()
        alertView.addButton("提交上门时间", action: { [weak self] in
            
            if let _ = self{
                
                let getTimeViewCon = GetTimeViewController(orderDetail: self!.detailArr.first as! OrderDetail)
                self!.navigationController?.pushViewController(getTimeViewCon, animated: true)

            }
            
        })
        
        alertView.addButton("无服务上门完成") { [weak self] in
            
            let alert = SCLAlertView()
            alert.addButton("确定", action: {
                //
                 self?.finishOrer("130000013")
            })
            alert.addButton("取消", action: {
            })
            alert.showWarning("无服务上门完成", subTitle: "请确定是否进行\"无服务上门完成\"操作?")
           
        }
        alertView.addButton("无服务未上门完成") { [weak self] in
            
            let alert = SCLAlertView()
            alert.addButton("确定", action: {
                //
                 self?.finishOrer("130000015")
            })
            alert.addButton("取消", action: {
            })
            alert.showWarning("无服务未上门完成", subTitle: "请确定是否进行\"无服务未上门完成\"操作?")
           
        }
        alertView.addButton("返回") { }
        
        alertView.showInfo("选择具体操作", subTitle: "")
        
    }
    
    func finishOrer(_ finishStyle: String) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.NoServiceFinshOrder(self.orderID, service: finishStyle, success: { [weak self] in
            
             MBProgressHUD.hide(for: self?.view, animated: true)
             NotificationCenter.default.post(name: Notification.Name(rawValue: "UPDATEWAITORDER"), object: nil) // 发送通知到RobListOneController让其更新数据
             _ = self?.navigationController?.popViewController(animated: true)
            
            }) { (error) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("提示", subTitle: error.localizedDescription)
        }
    }
    
    // 生成二维码
    func generateQR(text: String){
        
        let generateQRVC = RNGenerateQRViewController()
        generateQRVC.qrContent = text
        navigationController?.pushViewController(generateQRVC, animated: true)
    }
}

// MARK: - event response

extension ListsDetailViewController{
    
    func disMissBtn(){
        
      //  UIApplication.sharedApplication().statusBarHidden = false
       _ =  self.navigationController?.popViewController(animated: true)

    }
    
   
}

// MARK: - RNPatButtonTableViewCellDelegate

extension ListsDetailViewController: RNPatButtonTableViewCellDelegate{
    
    func gotoPay(){
        // 立即支付 - 支付成功后弹出提示并返回待处理界面
        
        let payViewController = RNPayViewController(orderId: self.orderID)
        navigationController?.pushViewController(payViewController, animated: true)
    }
}

