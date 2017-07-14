//
//  RobListMianViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 11/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
import MJRefresh


class RobListMianViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,RobListViewCellDelegate {
    var tableView  :UITableView! = nil
    //var currentData:NSMutableDictionary?
    
    var callBack: updateHomeData? // 点击返回按钮时回调
    
    var orderBylocationDic = NSMutableDictionary()
    
    var orderByTimeDic = NSMutableDictionary()
    
    
    var orders = NSMutableArray()
    
    var segSelectedIndex = 0
    
    var isLoadByTimeEnd:Bool?
    var loadMainPageIndexByTime=1
    var loadMainPageIndex=1
    var isLoadEnd:Bool?
    var isLoadByLocationEnd:Bool?
    var loadMainPageIndexByLocation=1
    var orderby:NSMutableDictionary?
    let header = MJRefreshNormalHeader() // 下拉刷新
    let footer = MJRefreshAutoNormalFooter() //上拉刷新
    //    var timeBlock:(()->Void)?
    
    var serviceAreas: [RNServiceAreasModel] = [RNServiceAreasModel]() // 服务区域
    
    var lock = NSLock() // 锁,,将 orders 锁住
    
    
    var listCell:RobListViewCell?
    
    lazy var segCon : UISegmentedControl = {
        let segCon = UISegmentedControl (frame: CGRect(x: 60, y: 10, width: WIDTH_SCREEN-60*2, height: 35))
        segCon.tintColor = COLORRGBA(58, g: 58, b: 58, a: 1)
        segCon.insertSegment(withTitle: "按时间排序", at: 0, animated: true)
        segCon.insertSegment(withTitle: "按距离排序", at: 1, animated: true)
        return segCon
    }()
    var   IsSelectLeft  = true
        {
        
        didSet{
            if IsSelectLeft == true
            {
                //                self.loadMainPageIndexByTime=1
                self.loadMainPageIndex=1
                isLoadEnd=false
                self.orderby=self.orderByTimeDic
                //                self.addUpView(self.orderByTimeDic)
                
                self.header.beginRefreshing()
                //                self.addPullView(self.orderByTimeDic)
              //  setUpRefresh()
               // self.footer.resetNoMoreData()
            }
            else{
                self.loadMainPageIndex=1
                self.isLoadEnd=false
                //                self.loadMainPageIndexByLocation=1
                
                self.orderby=orderBylocationDic
                // self.addRightUpView(self.orderByTimeDic)
                //                self.addUpView(self.orderBylocationDic)
                self.header.beginRefreshing()
               // setUpRefresh()
                //                self.addPullView(self.orderBylocationDic)
                self.footer.resetNoMoreData()
            }
            
            
        }
        
    }
    
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(addressDic : NSMutableDictionary, serviceAreas: [RNServiceAreasModel]) {
        
        var nibNameOrNil = String?("RobListMianViewController.swift")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        
       
        
        self.init(nibName: nibNameOrNil, bundle: nil)
        
        self.orderBylocationDic = addressDic.mutableCopy() as! NSMutableDictionary
        self.orderByTimeDic = addressDic.mutableCopy() as! NSMutableDictionary
        self.orderBylocationDic.setValue("location", forKey: "orderby")
        self.orderByTimeDic.setValue("time", forKey: "orderby")
        
        self.serviceAreas = serviceAreas
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.navigationController?.interactivePopGestureRecognizer?.enabled=true
        
        self.title = "抢单"
        
        segCon.frame = CGRect(x: 60, y: 10, width: WIDTH_SCREEN-60*2, height: 35)
        self.automaticallyAdjustsScrollViewInsets = true
        
        self.orderby=orderByTimeDic
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        setNavigationItem(orderby!.object(forKey: "city") as? String ?? "", selector: #selector(selectedArea), isRight: true)

       // setNavigationItem("筛选区域", selector: #selector(selectedArea), isRight: true)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-HEIGHT_NavBar))
                
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 400
       // tableView.tableFooterView = UIView(frame: CGRectZero)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "RobListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RobListViewCell")
        self.view.addSubview(tableView)
        segCon.selectedSegmentIndex = 0
        tableView.separatorStyle = .none
        
        
        isLoadByTimeEnd=false
        isLoadByLocationEnd=false
        isLoadEnd=false
        //        self.addPullView(self.orderByTimeDic)
        
       
        setUpRefresh()
        header.beginRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //  self.navigationController?.navigationBar.translucent = true
        //UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //  self.navigationController?.navigationBar.translucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        tableViewDisplayWithMsg("暂时没有订单数据", ifNecessagryForRowCount: orders.count)
        return (orders.count)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RobListViewCell") as! RobListViewCell
        
        cell.delegate = self
        listCell=cell
        
        //  cell.showCellText(self.orders[indexPath.row],title: self.toptitle.text!)
        if indexPath.row < self.orders.count {
            
            cell.showCellText(self.orders[indexPath.row] as! Order, title: navigationItem.title!, distance: "",row: indexPath.row)
        }
        
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // print("进来了")
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: 60))
        
        
        view.addSubview(segCon)
        segCon.addTarget(self, action: #selector(RobListMianViewController.controlPressed(_:)), for: .valueChanged)
        self.tableView.addSubview(view)
        view.backgroundColor = UIColor.white
        return view
    }
    
    //    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //        let cell = tableView.dequeueReusableCellWithIdentifier("RobListViewCell", forIndexPath: indexPath) as! RobListViewCell
    //        cell.nstimer?.invalidate()
    //
    //
    //    }
    // 添加上拉下拉刷新控件
    func setUpRefresh() {
        
        //下拉刷新
        
        //header.setRefreshingTarget(self, refreshingAction: #selector(addPullView:))
        header.setRefreshingTarget(self, refreshingAction:  #selector(addPullView))
        tableView.mj_header = header
        
        //上拉刷新
        
        footer.setRefreshingTarget(self, refreshingAction:  #selector(addUpView))
        tableView.mj_footer = footer
        
    }
    
    
    //添加下拉刷新
    func addPullView(){
        
//        if !(self.orders.count==0) {
//            
//            self.orders.removeAll()// 移除所有数据
//        }
        
        self.loadMainPageIndex=1
        self.isLoadEnd=false
        
        //                strongSelf.loadMainPageIndexByLocation=1
        //                strongSelf.isLoadByLocationEnd=false
        footer.resetNoMoreData() // 重启
        self.tableView.isUserInteractionEnabled = false
        //                self.loadDataByPull(address)
        
        guard let param = orderby else{
            self.tableView.isUserInteractionEnabled = true
            return
        }
        self.loadDataByPull(param, isLoadEnd: self.isLoadEnd!,pageIndex:self.loadMainPageIndex)
        
        
    }
    
    func loadDataByPull(_ param :NSDictionary, isLoadEnd:Bool,pageIndex:Int){
       
        let param1  =  param.mutableCopy() as! NSMutableDictionary
        param1["pageindex"]=pageIndex
        param1["pagesize"] = 10

        
        // MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        weak var weakSelf = self
        User.GetOrderList(param1, success: { orders in
             weakSelf?.header.endRefreshing()
             weakSelf?.footer.endRefreshing()
            
            if orders.count < 10{
                 weakSelf?.footer.endRefreshingWithNoMoreData()
            }
            if orders.count == 0{
                weakSelf?.tableViewDisplayWithMsg("暂时没有订单数据", ifNecessagryForRowCount: orders.count)
            }
            
            self.orders = orders
            //  MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
            
            
            weakSelf?.navigationItem.rightBarButtonItem?.isEnabled = false // 不能点击
            weakSelf?.refresh()

            
            //  MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
            weakSelf?.tableView.isUserInteractionEnabled = true
            weakSelf?.tableView.reloadData()
           
            
            
            
        }) { (error) in
            // MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
            // print("错误原因:\(error.localizedDescription)")
            weakSelf?.header.endRefreshing()
            weakSelf?.tableView.isUserInteractionEnabled = true
            
            let alertView=SCLAlertView()
            alertView.addButton("ok", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
        
        
    }
    
    
    
    
    //上拉刷新
    func addUpView(){
        
       // if (self.isLoadEnd==false){
            self.loadMainPageIndex+=1
        //}
        self.tableView.isUserInteractionEnabled = false
        print(self.loadMainPageIndex)
        //                strongSelf.loadDataByUp((address,isLoadEnd))
        
        guard let param = orderby else{
            self.tableView.isUserInteractionEnabled = true
            return
        }
        self.loadDataByUp(param, isLoadEnd: self.isLoadEnd!,pageIndex:self.loadMainPageIndex)
        
        
    }
    
    
    
    
    
    func loadDataByUp(_ param:NSMutableDictionary,isLoadEnd:Bool,pageIndex:Int){
        
        
        let param1  =  param.mutableCopy() as! NSMutableDictionary
        param1["pageindex"]=pageIndex
        param1["pagesize"] = 10
        
        User.GetOrderList(param1, success: { [weak self]tmpOrders in
            
            self?.footer.endRefreshing()
            if tmpOrders.count < 10{
                self?.footer.endRefreshingWithNoMoreData()
            }

            
            if let strongSelf = self{
                strongSelf.tableView.isUserInteractionEnabled = true
                
                
                //                strongSelf.isLoadByLocationEnd=false
                //                strongSelf.isLoadByTimeEnd=false
                strongSelf.isLoadEnd=false
                let tmpCount = tmpOrders.count
                
                
                if tmpOrders.count == 0{
                    
                    //  MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
//                    strongSelf.footer.endRefreshingWithNoMoreData()
                    return
                }
                else{
                    
                    for index in 0..<tmpCount{
                        if ((tmpOrders[index] as! Order).id != nil){
                            // strongSelf.orders.append(tmpOrders[index])
                            strongSelf.orders.add(tmpOrders[index])
                            
                        }
                    }
                    
                }
                //                strongSelf.tableView.beginUpdates()
                //
                //
                //                strongSelf.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                //
                strongSelf.tableView.reloadData()
//                strongSelf.footer.endRefreshing()
                
                //   print("成功.....-------")
                
                strongSelf.navigationItem.rightBarButtonItem?.isEnabled = false // 不能点击
                strongSelf.refresh()
                
                
                strongSelf.tableView.isUserInteractionEnabled = true
            }
        }) { [weak self] (error) in
            
            self?.footer.endRefreshing()
            
            if let strongSelf=self{
                
                //                strongSelf.tableView.infiniteScrollingView.stopAnimating()
                strongSelf.tableView.isUserInteractionEnabled = true
                //                strongSelf.isLoadByTimeEnd=false
                //                strongSelf.isLoadByLocationEnd=false
                strongSelf.isLoadEnd=false
                if(error.localizedDescription=="获取数据为空"){
                    
                    strongSelf.isLoadEnd=true
                    
                    
                }
                
                // print(error.localizedDescription)
                
            }
            
            let alertView=SCLAlertView()
            alertView.addButton("ok", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
        
        
        
    }
    
    
    func controlPressed(_ segCon :UISegmentedControl){
        if segCon.selectedSegmentIndex != segSelectedIndex{
            
            //MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
            self.tableView.isUserInteractionEnabled = false
            IsSelectLeft = (segCon.selectedSegmentIndex==0)
            
            print(IsSelectLeft)
            
            //isShow = true
            
            segSelectedIndex = segCon.selectedSegmentIndex
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row < orders.count {
            
            guard let _ = self.title, let ln = (orders[indexPath.row] as! Order).lng, let la = (orders[indexPath.row] as! Order).lat else {
                return
            }
            
            let detail = ListsDetailViewController(order: orders[indexPath.row] as! Order, title: self.title!,distance: calculateDistance(Double(ln), lat: Double(la)))
            detail.popToSuperConBlock = {
                
               // print(self.orderByTimeDic)
                self.header.beginRefreshing()
                
            }
            self.navigationController?.pushViewController(detail, animated: true)
            
        }

//        let detail = ListsDetailViewController(order: orders[indexPath.row] as! Order, title: navigationItem.title!, distance:self.calculateDistance(Double((orders[indexPath.row] as! Order).lng!), lat: Double((orders[indexPath.row] as! Order).lat!)))
//        detail.popToSuperConBlock = {
//            
//            print(self.orderByTimeDic)
//            self.header.beginRefreshing()
//            
//        }
//        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func calculateDistance(_ lng:Double,lat:Double)->String{
        let  er:Double = 6378137 // 6378700.0f;
        let PI = 3.14159265
        var radLat1=self.radians(lat)
        let lat2=Double((User.currentUser?.lat)!)
        var radLat2 = self.radians(lat2)
        var radLng1=self.radians(lng)
        let lng2 = Double((User.currentUser?.lng)!)
        var radLng2 = self.radians(lng2)
        
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
    //当抢单时间所剩为0的时候刷新
    //    func refreshFromRobList(row) {
    //
    //            self.orders.removeAtIndex(row)
    //
    //
    //    }
    func refreshFromRobList(_ order: Order) {
        
        self.orders.remove(order)
        self.tableView.reloadData()
//        for (index, item) in self.orders.enumerated() {
//            if order.orderId == item.orderId {
//                
//                self.orders.remove(at: index)
//            }
//        }
//        self.tableView.reloadData()
     //   header.beginRefreshing()
    }
    
    
    func tableViewDisplayWithMsg(_ message: String, ifNecessagryForRowCount: Int ) -> Void {
        if  ifNecessagryForRowCount == 0{
            //没有数据时显示
            
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: 15)
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel
            
            footer.isHidden = true //没有数据是隐藏footer
            
        }else{
            tableView.backgroundView = nil
            if (HEIGHT_SCREEN - HEIGHT_NavBar - HEIGHT_TabBar) > CGFloat(172*ifNecessagryForRowCount){ // 即数据没有填满屏幕
                footer.isHidden = true
            }else{
                footer.isHidden = false
            }
            
        }
    }
}

// MARK: - event response

extension RobListMianViewController{
    
    func disMissBtn(){
        
        
        if (callBack != nil) {
            callBack!()
        }
        
        //  UIApplication.sharedApplication().statusBarHidden = false
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    // 筛选区域
    func selectedArea(){
        
        if serviceAreas.count == 0{
            // 服务区为空时获取服务区
            navigationItem.rightBarButtonItem?.isEnabled = false // 不能点击
            refresh()
        }else{
            
            let provinceVC = RNSelectProvinceTableViewController(style: UITableViewStyle.grouped ,closure: { (paramDic) in
                
                self.orderByTimeDic.addEntries(from: paramDic)
                self.orderBylocationDic.addEntries(from: paramDic)
                self.header.beginRefreshing()
                //                self.addPullView(self.orderByTimeDic)
                //  setUpRefresh()
                
                
                if paramDic["SearchArea"] != "" && paramDic["SearchArea"] != nil {
                    self.navigationItem.rightBarButtonItem?.title = paramDic["SearchArea"]
                }else if paramDic["SearchCity"] != "" && paramDic["SearchCity"] != nil{
                    self.navigationItem.rightBarButtonItem?.title = paramDic["SearchCity"]
                }else if paramDic["SearchProvince"] != "" && paramDic["SearchProvince"] != nil{
                    self.navigationItem.rightBarButtonItem?.title = paramDic["SearchProvince"]
                }else{
                    self.navigationItem.rightBarButtonItem?.title = self.orderby!.object(forKey: "city") as? String ?? ""
                }
                
                
                
                //  self.footer.resetNoMoreData()
                
            }, serviceAreas: self.serviceAreas)
            
            self.navigationController?.pushViewController(provinceVC, animated: true)
            
        }
        
    }
    
    func refresh() {
        
        User.RefreshIndex({ [weak self](user, headArr, footArr, serviceAreas) in
            
            
//            let alertView=SCLAlertView()
//            alertView.addButton("ok", action: {})
//            alertView.showError("提示", subTitle: "获取到服务区域可以点了")
            
            self?.serviceAreas = serviceAreas
            
            if serviceAreas.count > 0{
                // 到主线程更新 UI
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }else{
                let alertView=SCLAlertView()
                alertView.addButton("取消", action: {})
                alertView.addButton("确定", action: {
                
                   let _ = self?.navigationController?.popViewController(animated: true)
                })
                alertView.showNotice("提示", subTitle: "您没有服务区域,查看不到任何可抢订单,点击确定返回首页")
            }
            
           
        }, failure: { (error) in
                
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: error.localizedDescription)
        })
        
        
    }

}


