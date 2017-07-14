//
//  RNWaitPayViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/11/1.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
import MJRefresh

class RNWaitPayViewController: UITableViewController ,UIGestureRecognizerDelegate ,RobListViewCellDelegate{
    
    var pageIndex=1
    //var pageSize=10
    var textTitle:String?
    var orders=NSMutableArray()
    var oderbyTime = NSMutableDictionary()
    var isRobLoadEnd:Bool?
    
    var callBack: updateHomeData? // 点击返回按钮时回调
    
    let header = MJRefreshNormalHeader() // 下拉刷新
    let footer = MJRefreshAutoNormalFooter() //上拉刷新
    var showHeight: CGFloat = 0.0 // 界面内容显示的高度
    
    // 210000012 等待工程师支付
    // 210000012 等待用户支付
    fileprivate lazy var wEngineerPayArray = {
        return [Order]()
    }()
    fileprivate lazy var wUserPayArray = {
        return [Order]()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        setNavigationItem(oderbyTime.object(forKey: "city") as? String ?? "", selector: #selector(doRight), isRight: true)
        
        
        
        tableView.estimatedRowHeight = 400
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "RobListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RobListViewCell")
        self.tableView.backgroundColor = COLORRGBA(239, g: 239, b: 244, a: 1)
        
        
        tableView.separatorStyle = .none
        MBProgressHUD.showAdded(to: self.view, animated: true)
        tableView.isUserInteractionEnabled = false
        self.loadData()
        self.setUpRefresh()
        self.title = textTitle
        isRobLoadEnd=false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        UIApplication.shared.isStatusBarHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NSNotification.Name(rawValue: "UPDATEWAITORDER"), object: nil) // 观察更新数据通知
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATEWAITORDER"), object: nil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
    }
    
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(title :String,orderBytime:NSMutableDictionary ,action:String) {
        
        let style = UITableViewStyle.plain
        
        self.init(style: style)
        
        self.textTitle = title
        
        self.oderbyTime = orderBytime.mutableCopy() as! NSMutableDictionary
        self.oderbyTime.setValue("time", forKey: "orderby")
        self.oderbyTime.setValue(action, forKey: "action")
        // "pagesize":pageSize
        self.oderbyTime.setValue(20, forKey: "pagesize")
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - event response
extension RNWaitPayViewController{
    
    // 返回按钮事件
    func disMissBtn(){
        
        if (callBack != nil) {
            callBack!()
        }
        
        //  UIApplication.sharedApplication().statusBarHidden = false
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
    // 重新刷新数据
    func updateData(){
        
        headRefresh()
    }
    
}

// MARK: - custom methods

extension RNWaitPayViewController{
    
    func loadData(){
        
        User.GetOrderList(self.oderbyTime, success: {[weak self] orders in
            if let strongSelf = self{
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                //strongSelf.orders = orders
                if orders.count < 20{
                    strongSelf.footer.endRefreshingWithNoMoreData()
                }
                
//                for item in orders{
//                    strongSelf.orders.append(item)
//                }
                
               strongSelf.orders = orders
                
               strongSelf.tableView.isUserInteractionEnabled = true
              //  strongSelf.makeGroups(orders)
                //   print(orders)
                strongSelf.tableView.reloadData()
            } }) { (error) in
                
                self.tableView.isUserInteractionEnabled = true
                MBProgressHUD.hide(for: self.view, animated: true)
                print(error.localizedDescription)
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("错误提示", subTitle: error.localizedDescription)
        }
        
        
    }
    
    // 添加上拉下拉刷新控件
    func setUpRefresh() {
        
        //下拉刷新
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headRefresh))
        tableView.mj_header = header
        
        //上拉刷新
        
        footer.setRefreshingTarget(self, refreshingAction:  #selector(footerRefresh))
        tableView.mj_footer = footer
        
    }
    
    
    
    // 上拉刷新事件
    
    func footerRefresh() {
        
        pageIndex += 1 //页码增加
        
        self.oderbyTime["pageindex"]=self.pageIndex
        
        
        loadDataByUp(self.oderbyTime)
        
    }
    
    //添加下拉刷新
    func headRefresh() {
        
        //        if !self.orders .isEmpty {
        //            self.orders .removeAll() // 移除所有数据
        //        }
        
        showHeight = 0.0
        
        pageIndex = 1 //返回第一页
//        
//        wEngineerPayArray.removeAll()
//        wUserPayArray.removeAll()
        
      //  orders.removeAllObjects()
        
        footer.resetNoMoreData() // 重启
        self.oderbyTime["pageindex"]=self.pageIndex
        loadDataByPull(oderbyTime)
    }
    
    func loadDataByPull(_ param :NSDictionary){
        weak var weakSelf = self
        
        User.GetOrderList(param, success: { tmpOrders in
            
            weakSelf?.header.endRefreshing()
            
            if tmpOrders.count < 20{
                 weakSelf?.footer.endRefreshingWithNoMoreData()
            }
            
            if tmpOrders.count == 0{
                weakSelf?.tableViewDisplayWithMsg("暂时没有订单数据", ifNecessagryForRowCount: tmpOrders.count)
            }else{
                
                
                weakSelf?.orders=tmpOrders
                
              //  weakSelf?.makeGroups(tmpOrders)
                
                
            }
            weakSelf?.tableView.reloadData()
            
        }) { (error) in
            // MBProgressHUD.hideHUDForView(self.view, animated: true)
            // print("错误原因:\(error.localizedDescription)")
            weakSelf?.header.endRefreshing()
        }
        
        
    }
    
    func loadDataByUp(_ param :NSMutableDictionary){
        
        
        // MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        weak var weakSelf = self
        User.GetOrderList(param, success: { tmpOrders in
            
             weakSelf?.footer.endRefreshing()
            
            if tmpOrders.count < 20{
                weakSelf?.footer.endRefreshingWithNoMoreData()
            }
            
            // 先判断上拉是否获取的数据,没有数据不再请求
            if tmpOrders.count == 0{
                
                weakSelf?.pageIndex -= 1 // 当前页减一,保证currentpage最大为总页数
                //  MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
               // weakSelf?.footer.endRefreshingWithNoMoreData()
                return
            }else{
                
                for item in tmpOrders{
                    weakSelf?.orders.add(item)
                    
                }
                
              //  weakSelf?.makeGroups(tmpOrders)
                
                // MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
                weakSelf?.tableView.reloadData()
               
                
            }
        }) { (error) in
            // MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
            print("错误原因:\(error.localizedDescription)")
            weakSelf?.footer.endRefreshing()
        }
        
    }
    
    
    // 分组
    func makeGroups(_ dataArray: [Order]){
        
        for item in dataArray {
            if item.checkState == "210000012"{
                wEngineerPayArray.append(item)
            }else{
                wUserPayArray.append(item)
            }
        }
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
            
            footer.isHidden = false
            //            if (HEIGHT_SCREEN - HEIGHT_NavBar) > 10000 { // 即数据没有填满屏幕
            //                footer.hidden = true
            //            }else{
            //                footer.hidden = false
            //            }
        }
    }
    
    
}

extension RNWaitPayViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        tableViewDisplayWithMsg("暂时没有订单数据", ifNecessagryForRowCount: orders.count)
//        if section == 0 {
//            return wEngineerPayArray.count
//        }else{
//            return wUserPayArray.count
//        }
        
        return orders.count
    }
//    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headView = UIView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: 40))
//        headView.backgroundColor = COLORRGBA(200, g: 200, b: 200, a: 1)
//        
//        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 40))
//        titleLabel.font =  UIFont.systemFontOfSize(14)
//        headView.addSubview(titleLabel)
//        
//        if section == 0 {
//            titleLabel.text = "等待工程师支付"
//            
//            if wEngineerPayArray.count > 0 {
//                return headView
//            }
//        }else{
//            titleLabel.text = "等待用户支付"
//            
//            if wUserPayArray.count > 0 {
//                return headView
//            }
//        }
//        
//        return nil
//    }
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //   let cell = tableView.dequeueReusableCellWithIdentifier("RobListViewCell") as! RobListViewCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RobListViewCell") as! RobListViewCell
        
        //设置点击颜色不变
        cell.selectionStyle = .none
        
        
         // cell.showCellText(orders[indexPath.row],title: self.title!)
        if indexPath.row < orders.count{
            cell.showCellText(orders[indexPath.row] as! Order, title: self.title!, distance: self.calculateDistance(Double((orders[indexPath.row] as! Order).lng!), lat: Double((orders[indexPath.row] as! Order).lat!)),row: indexPath.row)
        }

       //   print(indexPath.row)
        
//        if  indexPath.section == 0 {
//            if indexPath.row < orders.count{
//                cell.showCellText(wEngineerPayArray[indexPath.row], title: self.title!, distance: self.calculateDistance(Double(orders[indexPath.row].lng!), lat: Double(orders[indexPath.row].lat!)),row: indexPath.row)
//            }
//        }else{
//            if indexPath.row < orders.count{
//                cell.showCellText(wUserPayArray[indexPath.row], title: self.title!, distance: self.calculateDistance(Double(orders[indexPath.row].lng!), lat: Double(orders[indexPath.row].lat!)),row: indexPath.row)
//            }
//        }
        
        
        // showHeight =  showHeight + cell.contentView.frame.size.height
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //        showHeight =  showHeight + cell.contentView.frame.size.height
        //
        //        if (HEIGHT_SCREEN - HEIGHT_NavBar) > showHeight { // 即数据没有填满屏幕
        //            footer.hidden = true
        //        }else{
        //            footer.hidden = false
        //        }
    }
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //
        //        self.navigationController!.interactivePopGestureRecognizer!.enabled = true
        //        self.navigationController!.interactivePopGestureRecognizer!.delegate = nil
        
//        var tmpArr = [Order]()
//        if indexPath.section == 0 {
//            tmpArr = wEngineerPayArray
//            
//        }else{
//            tmpArr = wUserPayArray
//            
//        }
        
        if indexPath.row < orders.count {
            
            guard let _ = self.title, let ln = (orders[indexPath.row] as! Order).lng, let la = (orders[indexPath.row] as! Order).lat else {
                return
            }
            
            let detail = ListsDetailViewController(order: orders[indexPath.row] as! Order, title: self.title!,distance: calculateDistance(Double(ln), lat: Double(la)))
            detail.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(detail, animated: true)

        }
        
    }
    
}
