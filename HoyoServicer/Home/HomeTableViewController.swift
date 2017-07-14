//
//  HomeTableViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//


import UIKit
import MBProgressHUD

class HomeTableViewController: UIViewController{
    
    // MARK: - properties
    
    var manager :CLLocationManager?
    var isLocationSuccess:Bool = false // 是否定位成功
    var nextTitle:String!
    var action :String!
    var repeatTime = 0
    var counttime:Timer!
    
    //  var orders=[Order]()
    //    var addressDicBlock:((CLLocationCoordinate2D,CLPlacemark)->Void)?
    var tableView:UITableView!
    var headImgView:UIImageView!
    
    var addressDic=NSMutableDictionary()
    
    //    var pagesize = 10
    //    var pageindex = 0
    
    var tmpWhitchImg = true // true 显示第一张, false 显示第二
    
    var headBanners = [String]()
    var footBanners = [String]()
    
    var serviceAreaArray = [RNServiceAreasModel]() // 服务区域数组
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  self.navigationController?.interactivePopGestureRecognizer?.enabled=true
        self.view.backgroundColor = UIColor.white
        
        //        // 导航转场动画代理
        //        navigationController?.delegate = self
        
        setUI()
        
        //数据初始化
        refresh()
        
        pushMeg()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 隐藏导航
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        myLocationManager()
        
        //  refresh()//数据初始化
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(OrderPushNotification)
        NotificationCenter.default.removeObserver(OrderPushNotificationString)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - public methods

extension HomeTableViewController{
    
    // UI
    
    func setUI(){
        
        //头部图片
        headImgView=UIImageView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: 228*HEIGHT_SCREEN/667))
        headImgView.image=UIImage(named: "home_top_1")
        self.view.addSubview(headImgView)
        
        let logoImg = UIImageView(image: UIImage(named: "HoyoLogoOfHead"))
        logoImg.frame=CGRect(x: (WIDTH_SCREEN/2-117*HEIGHT_SCREEN/667), y: 25*HEIGHT_SCREEN/667,width: 234*HEIGHT_SCREEN/667, height: 63*HEIGHT_SCREEN/667)
        logoImg.contentMode=UIViewContentMode.scaleToFill
        self.view.addSubview(logoImg)
        
        //表视图
        self.automaticallyAdjustsScrollViewInsets=false
        tableView=UITableView(frame: CGRect(x: 0, y: 228*HEIGHT_SCREEN/667, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-HEIGHT_TabBar-228*HEIGHT_SCREEN/667))
        tableView.delegate=self
        tableView.dataSource=self
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeTableViewCell")
        tableView.separatorStyle=UITableViewCellSeparatorStyle.none
        self.view.addSubview(tableView)
        
        //添加下拉加载数据事件
        tableView.addPullToRefresh {
            [weak self] in
            if let strongSelf=self{
                strongSelf.refresh()
            }
        }
        
    }
    
    // 推送
    
    func pushMeg(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentUserDidChange), name: NSNotification.Name(rawValue: CurrentUserDidChangeNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.pushOrederGY), name: NSNotification.Name(rawValue: OrderPushNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.selectTabbarAction), name: NSNotification.Name(rawValue: OrderPushNotificationString), object: nil)
        
        if UserDefaults.standard.value(forKey: OrderPushNotification) as? String == OrderPushNotification {
            UserDefaults.standard.setValue(nil, forKey: OrderPushNotification)
            pushOrederGY()
        }
        //        refresh()//数据初始化
    }
    
    // 定位
    
    func myLocationManager(){
        
        manager = CLLocationManager()
        manager!.delegate=self
        manager!.desiredAccuracy = kCLLocationAccuracyBest
        manager!.distanceFilter = 1000.0
        
        //        if #available(iOS 8.0, *) {
        //           manager!.requestAlwaysAuthorization()
        //        }
        manager!.requestAlwaysAuthorization()
        
        // ios9 允许设备后台定位（ios9后新特性，同一个设备，允许多个loaction manager,一些只能再前台定位，一些可以在后台定位）
        //        if #available(iOS 9.0, *) {
        //            manager?.allowsBackgroundLocationUpdates = true
        //        }
        
        if CLLocationManager.locationServicesEnabled() { // 系统定位服务是否开启
            manager!.startUpdatingLocation()
        }else{
            
            self.noticeError("定位服务未打开，请修改手机设置(设置->浩优服务家->位置->始终)", autoClear: true, autoClearTime: 3)
        }
        
        
    }
    
    
    // 推送消息跳转
    
    func pushOrederGY()  {
        _ =  navigationController?.popToRootViewController(animated: true)
        qiangdanAction()
    }
    
    func selectTabbarAction() {
        tabBarController?.selectedIndex = 2
    }
    
    //
    
    func CurrentUserDidChange() {
        self.tableView.reloadData()
    }
    
    // 刷新
    
    func refresh() {
        
        
        
        
        User.RefreshIndex({ [weak self](user, headArr, footArr, serviceAreas) in
            
            self!.headBanners = headArr
            self!.footBanners = footArr
            
            self!.serviceAreaArray = serviceAreas
            
            User.currentUser=user
            self!.tableView.reloadData()
            self!.tableView.pullToRefreshView.stopAnimating()
            
            // 到主线程更新 UI
            DispatchQueue.main.async {
                
                self?.upateUI(user)
            }
            
            
            
            
            }, failure: { (error) in
                
                
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("提示", subTitle: error.localizedDescription)
        })
        
    }
    
    func upateUI(_ user: User){
        
        
        var urlIndex = 0
        if headBanners.count > 0 {
            
            if headBanners.count > 1 {
                if tmpWhitchImg {
                    urlIndex = 0
                }else{
                    urlIndex = 1
                }
            }else{
                urlIndex = 0
            }
        }
        
        if headBanners.count > 0 {
            headImgView.sd_setImage(with: URL(string: headBanners[urlIndex]), placeholderImage: UIImage(named: "home_top_1"))
        }else{
            headImgView.image=UIImage(named: tmpWhitchImg ? "home_top_0":"home_top_1")
        }
        
        tmpWhitchImg = !tmpWhitchImg
    }
    
    /**
     点击菜单的哪个按钮
     
     - parameter Tag: 从左到右，从上到下，1、2....8
     */
    fileprivate func buttonClick(_ Tag:Int)
    {
        
        print(Tag)
        switch Tag {
        case 1:
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            qiangdanAction()
            
            break
        case 2:
            
            
            self.nextTitle = "待处理"
            
            self.action = "yqaction"
            self.pushToNextCon()
            
            break
        case 3:
            self.nextTitle = "待支付"
            self.action = "WaitPayAction"
            let waitPayVC = RNWaitPayViewController(title: nextTitle, orderBytime: self.addressDic,action: self.action)
            waitPayVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(waitPayVC, animated: true)
            
            break
        case 4:
            
            let viewCon =  ViewController()
            viewCon.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewCon, animated: true)
            break
        case 5:
            
            self.nextTitle = "待评价"
            self.action = "waitscoreaction"
            let waitPayVC = RNWaitPayViewController(title: nextTitle, orderBytime: self.addressDic,action: self.action)
            waitPayVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(waitPayVC, animated: true)

            break
        case 6:
            self.nextTitle = "待结算"
            self.action = "wsettlementaction"
            let waitPayVC = RNWaitPayViewController(title: nextTitle, orderBytime: self.addressDic,action: self.action)
            waitPayVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(waitPayVC, animated: true)

            
            break
        case 7:
            self.nextTitle = "已评价"
            self.action = "scoreaction"
            let waitPayVC = RNWaitPayViewController(title: nextTitle, orderBytime: self.addressDic,action: self.action)
            waitPayVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(waitPayVC, animated: true)

            break
        case 8:
            
            self.nextTitle = "已结算"
            self.action = "hsettlementaction"
            let waitPayVC = RNWaitPayViewController(title: nextTitle, orderBytime: self.addressDic,action: self.action)
            waitPayVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(waitPayVC, animated: true)
    
            //            let  myteam = MyTeamTableViewController()
            //           // myteam.hidesBottomBarWhenPushed = true
            //             self.navigationController?.pushViewController(myteam, animated: true)
            
            break
        case 9:
            // 安装水机
//            let installMachineVC = RNInstallMachineViewController(nibName: "RNInstallMachineViewController", bundle: nil)
//            installMachineVC.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(installMachineVC, animated: true)
            break
        case 10:
            // 激活出水
            break
        case 11:
            // 待定
            break
        case 12:
            // 待定
            break
            
        default:
            break
            
        }
        
    }
    
    func pushToNextCon( ){
        
        commonSkipAction()
    }
    
    
    
    
    // 抢单跳转
    
    func qiangdanAction(){
        
        if CLLocationManager.locationServicesEnabled() { // 系统定位服务是否开启
            
            if (CLLocationManager.authorizationStatus().rawValue == 0) || (CLLocationManager.authorizationStatus().rawValue == 3) {
                //  if isLocationSuccess { // 是否定位成功
                
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                getAddressFromUserDefault()
                
                self.addressDic.setValue("kqaction", forKey: "action")
                
                //                if self.serviceAreaArray.count == 0 {
                //                    let alerView = SCLAlertView()
                //                    alerView.addButton("确定", action: {})
                //                    alerView.showInfo("温馨提示", subTitle: "请先认证服务区域")
                //
                //                    return;
                //                }
                
                let robOneCon = RobListMianViewController(addressDic: self.addressDic, serviceAreas: self.serviceAreaArray)
                
                robOneCon.callBack = {
                    
                    //self?.refresh() // 刷新界面
                }
                
                
                robOneCon.hidesBottomBarWhenPushed = true
                
                self.navigationController?.pushViewController(robOneCon, animated: true)
                
                //                }else{
                //
                //                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                //
                //                    let alertView=SCLAlertView()
                //                    alertView.addButton("ok", action: {})
                //                    alertView.showError("错误提示", subTitle: "定位失败，请稍后")
                //                }
                
            }else{
                
                MBProgressHUD.hide(for: self.view, animated: true)
                self.noticeError("服务家定位服务未打开，请修改手机设置(设置->浩优服务家->位置->始终)", autoClear: true, autoClearTime: 3)
            }
        }else{
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.noticeError("系统定位服务未打开", autoClear: true, autoClearTime: 3)
        }
    }
    
    // 待处理-待评价-待结算-已评价-已结算跳转
    func commonSkipAction(){ // 暂时
        
        if CLLocationManager.locationServicesEnabled() { // 系统定位服务是否开启
            
            if (CLLocationManager.authorizationStatus().rawValue == 0) || (CLLocationManager.authorizationStatus().rawValue == 3) {
                
                getAddressFromUserDefault()
                
                let pendingDoing = RobListOneController(title: nextTitle, orderBytime: self.addressDic,action: self.action)
                pendingDoing.callBack = {
                    
                    // self?.refresh() // 刷新界面
                }
                
                pendingDoing.hidesBottomBarWhenPushed = true
                
                self.navigationController?.pushViewController(pendingDoing, animated: true)
                
                
            }else{
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                self.noticeError("服务家定位服务未打开，请修改手机设置(设置->浩优服务家->位置->始终)", autoClear: true, autoClearTime: 3)
            }
        }else{
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.noticeError("系统定位服务未打开", autoClear: true, autoClearTime: 3)
        }
        
    }
}


// MARK: - private methods

extension HomeTableViewController{
    
    // 从本地获取位置数据
    func getAddressFromUserDefault(){
        
        self.addressDic.setValue(10, forKey: "pagesize")
        
        self.addressDic.setValue(1, forKey: "pageindex")
        
        if let province = UserDefaults.standard.object(forKey: PROVINCE) {
            
            self.addressDic.setValue((province as! String), forKey: "Province")
        }else{
            self.addressDic.setValue("上海", forKey: "Province")
        }
        if let city = UserDefaults.standard.object(forKey: CITY) {
            
            self.addressDic.setValue((city as! String), forKey: "city")
        }else{
            self.addressDic.setValue("上海", forKey: "city")
        }
        
        if let latitude = UserDefaults.standard.object(forKey: LATITUDE){
            
            self.addressDic.setValue((latitude as! Double), forKey: "lat")
        }else{
            self.addressDic.setValue(0.000, forKey: "lat")
        }
        
        if let longitude = UserDefaults.standard.object(forKey: LONGITUDE){
            
            self.addressDic.setValue((longitude as! Double), forKey: "lng")
        }else{
            self.addressDic.setValue(0.000, forKey: "lng")
        }
        
        
    }
}

// MARK: - event response

extension HomeTableViewController{
    
    
}

// MARK: - delegates

extension HomeTableViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[0]
        let o2d = newLocation.coordinate
        //CLLocationCoordinate2D
        //        let loca = 31.4217987560
        //        let logn = 116.7258979197
        //        let  location = CLLocation.init(latitude: loca, longitude: logn)
        
        //let o2d = newLocation.coordinate
        // manager.stopUpdatingLocation() // 停止定位后，当位置发生移动，didUpdateLocations这个代理再调用
        
        let  geoC = CLGeocoder()
        
        geoC.reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if(error == nil)
            {
                
                let placemark=placemarks?.first
                
                guard (placemark != nil) else {
                    
                    self.isLocationSuccess = false
                    return
                }
                
                // 保存位置信息在本地
                if placemark!.administrativeArea != nil {
                    
                    UserDefaults.standard.setValue((placemark!.administrativeArea! as String), forKey: PROVINCE)
                }else{
                    
                    UserDefaults.standard.setValue("上海", forKey: PROVINCE)
                }
                
                if placemark!.locality != nil{
                    
                    UserDefaults.standard.setValue((placemark!.locality! as String), forKey: CITY)
                }else{
                    
                    UserDefaults.standard.setValue("上海", forKey: CITY)
                }
                
                UserDefaults.standard.setValue((o2d.latitude as NSNumber).doubleValue, forKey: LATITUDE)
                UserDefaults.standard.setValue((o2d.longitude as NSNumber).doubleValue, forKey: LONGITUDE)
                
                if appDelegate.mainViewController != nil {
                    User.currentUser?.lat=NSNumber(value: o2d.latitude as Double)
                    User.currentUser?.lng=NSNumber(value: o2d.longitude as Double)
                    
                }else{
                    print("进不来");
                }
                
                self.isLocationSuccess = true
                
                //             self.addressDic.setValue(placemark?.subLocality, forKey: "Country")
                //self.addressDicBlock!(o2d,placemark!)
                
            }else
            {
                print("错误");
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { // 定位失败调用的代理方法
        
        isLocationSuccess = false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        if status.rawValue == 0 || status.rawValue == 3 {
            // isLocationSuccess = true
            
            manager.startUpdatingLocation()
        }
    }
    
}

extension HomeTableViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return HEIGHT_SCREEN-HEIGHT_TabBar-228*HEIGHT_SCREEN/667
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        cell.buttonClickCallBack={ [weak self] buttonTag in
            if let strongSelf = self {
                strongSelf.buttonClick(buttonTag)
            }
            
        }
        
        cell.delegate = self
        
        do{
            if User.currentUser?.orderabout != nil {
                let tmpOrderDic = try? JSONSerialization.jsonObject(with: (User.currentUser?.orderabout)! as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
                let finshOfOrder:String = (((tmpOrderDic as AnyObject).object(forKey: "finsh") ?? 0) as! NSNumber).stringValue
                let waitOfOrder:String = (((tmpOrderDic as AnyObject).object(forKey: "wait") ?? 0) as! NSNumber).stringValue
                cell.orderAboutLabel.text = "已完成\(finshOfOrder)单     待处理\(waitOfOrder)单"
                
                cell.unDealLabel.isHidden = false
                
                let waitCount = Int(waitOfOrder)
                if let count = waitCount {
                    if count > 99 {
                        cell.unDealLabel.text = "99+"
                    }else if count <= 0{
                        cell.unDealLabel.isHidden = true
                    }else{
                        cell.unDealLabel.text = waitOfOrder
                    }
                }else{
                    cell.unDealLabel.text = waitOfOrder
                }
                
                cell.unDealLabel.layer.cornerRadius = 9.0
                cell.unDealLabel.layer.masksToBounds = true
            }
            
        }
        
        if User.currentUser?.score != nil {
            
            cell.scoreOfStar = (User.currentUser?.score)!=="" ? 0:Int((User.currentUser?.score)!)!
        }
        
        
        cell.nameLabel.text = User.currentUser!.name
        
        if User.currentUser?.headimageurl != nil
        {
            var tmpUrl = User.currentUser?.headimageurl
            if (tmpUrl!.contains("http"))==false {
                tmpUrl!=(NetworkManager.defaultManager?.website)!+tmpUrl!
            }
            
            cell.personImg.layer.masksToBounds = true
            cell.personImg.layer.cornerRadius = cell.personImg.frame.size.width / 2.0
            cell.personImg.sd_setImage(with: URL(string: tmpUrl!))
            //e(data: (User.currentUser?.headimageurl)!)
            
        }
        
        
        //        if User.currentUser?.headimageurl != nil
        //        {
        //            cell.personImg.image=UIImage(data: (User.currentUser?.headimageurl)!)
        //        }
        
        cell.footerScrollViewSetup(footBanners)
        return cell
    }
    
}

extension HomeTableViewController: HomeTableViewCellDelegate {
    
    func scanQR() {
        
        
        //设置扫码区域参数
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44;
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner;
        style.photoframeLineW = 3;
        style.photoframeAngleW = 18;
        style.photoframeAngleH = 18;
        style.isNeedShowRetangle = false;
        
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove;
        
        //qq里面的线条图片
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
        
        let vc = RNQRCodeScanViewController()
        vc.title="扫一扫"
        vc.scanStyle = style
        vc.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITabBarControllerDelegate

extension HomeTableViewController: UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = RNSimpleTrasition()
        return transition
    }
}

// MARK: - UINavigationControllerDelegate

extension HomeTableViewController: UINavigationControllerDelegate{
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .none:
            //            let transition = RNSimpleTrasition()
            //            return transition
            return nil
        case .pop:
            let transition = RNSimpleTrasition()
            return transition
        case .push:
            let transition = RNSimpleTrasition()
            return transition
        }
        
    }
}

//

//extension HomeTableViewController:
