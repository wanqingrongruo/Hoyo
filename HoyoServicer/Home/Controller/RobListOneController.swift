
//
//  RobListOneController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 30/3/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
import MJRefresh
import SJFluidSegmentedControl

typealias updateHomeData = ()->()

class RobListOneController: UIViewController, UIGestureRecognizerDelegate, RobListViewCellDelegate, UITableViewDelegate, UITableViewDataSource{
    
    var tableView: UITableView!
    var tabView:UIView!
    var noDealOrderButton: UIButton!
    var arrangedOrderButton: UIButton!
    var currentSelected = 100 // 当前索引 -- 默认选择未处理订单
    
    var pageIndex=1
    var pageSize=20
    var textTitle:String?
    var orders=NSMutableArray()
    var oderbyTime = NSMutableDictionary()
    
    var callBack: updateHomeData? // 点击返回按钮时回调
    
    let header = MJRefreshNormalHeader() // 下拉刷新
    let footer = MJRefreshAutoNormalFooter() //上拉刷新
    var showHeight: CGFloat = 0.0 // 界面内容显示的高度
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = textTitle
        view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        setNavigationItem("searchOrder.png", selector: #selector(seachAction), isRight: true)
        //  setNavigationItem(oderbyTime.object(forKey: "city") as? String ?? "", selector: #selector(doRight), isRight: true)
        
        myTab()

        tableView = UITableView(frame: CGRect(x: 0, y: 50, width: WIDTH_SCREEN, height: HEIGHT_SCREEN - HEIGHT_NavBar - 50), style: UITableViewStyle.plain)
      //  tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN - HEIGHT_NavBar ), style: UITableViewStyle.plain)
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RobListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RobListViewCell")
        tableView.backgroundColor = COLORRGBA(239, g: 239, b: 239, a: 1)
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        tableView.isUserInteractionEnabled = false
        
       // self.loadData()
        setUpRefresh()
        header.beginRefreshing()
        
    }
    
    func myTab(){
        
//        tabView = UIView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: 40))
//        tabView.backgroundColor = UIColor.white
//        view.addSubview(tabView)
//        
//        noDealOrderButton = UIButton(type: .custom)
//        noDealOrderButton.frame = CGRect(x: 0, y: 0, width: WIDTH_SCREEN/2, height: 40)
//        noDealOrderButton.isSelected = true
//        noDealOrderButton.tag = 100
//        noDealOrderButton.setTitle("未处理订单", for: .normal)
//        noDealOrderButton.setTitleColor(UIColor.white, for: .normal)
//        noDealOrderButton.backgroundColor = UIColor.orange
//        noDealOrderButton.addTarget(self, action: #selector(clickAction(sender:)), for: .touchUpInside)
//        tabView.addSubview(noDealOrderButton)
//        
//        arrangedOrderButton = UIButton(type: .custom)
//        arrangedOrderButton.frame = CGRect(x: WIDTH_SCREEN/2, y: 0, width: WIDTH_SCREEN/2, height: 40)
//        arrangedOrderButton.tag = 101
//        arrangedOrderButton.setTitle("已预约订单", for: .normal)
//        arrangedOrderButton.setTitleColor(UIColor.black, for: .normal)
//        arrangedOrderButton.backgroundColor = UIColor.white
//        arrangedOrderButton.addTarget(self, action: #selector(clickAction(sender:)), for: .touchUpInside)
//        tabView.addSubview(arrangedOrderButton)
        
        let segmentedControl = SJFluidSegmentedControl(frame: CGRect(x: (WIDTH_SCREEN-275)/2.0, y: 0, width: 275, height: 50))
       // segmentedControl.backgroundColor = COLORRGBA(0, g: 53, b: 73, a: 1)
        segmentedControl.textFont = .systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        segmentedControl.delegate = self
        segmentedControl.dataSource = self
        view.addSubview(segmentedControl)
        
    }
    
    func clickAction(sender: UIButton){
        
        guard !sender.isSelected else {
            return
        }
        
        let lastButton = tabView.viewWithTag(currentSelected) as! UIButton
        lastButton.isSelected = false
        lastButton.setTitleColor(UIColor.black, for: .normal)
        lastButton.backgroundColor = UIColor.white
        
        sender.isSelected = true
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.backgroundColor = UIColor.orange
        
        currentSelected = sender.tag
        
        switch sender.tag {
        case 100:
            self.footer.endRefreshing()
            oderbyTime["action"] = "yqaction"
            header.beginRefreshing()
            break
        case 101:
            self.footer.endRefreshing()
            oderbyTime["action"] = "arrangeaction"
            header.beginRefreshing()
            break
        default:
            break
        }
        
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
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(title :String,orderBytime:NSMutableDictionary ,action:String) {
        
        var nibNameOrNil = String?("RobListOneController.swift")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        
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
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        tableViewDisplayWithMsg("暂时没有订单数据", ifNecessagryForRowCount: orders.count)
        return orders.count
    }
    
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //   let cell = tableView.dequeueReusableCellWithIdentifier("RobListViewCell") as! RobListViewCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RobListViewCell") as! RobListViewCell
        
        //设置点击颜色不变
        cell.selectionStyle = .none
        
        
        //  cell.showCellText(orders[indexPath.row],title: self.title!)
        //        cell.showCellText(orders[indexPath.row], title: self.title!, distance: self.calculateDistance(), lat: (User.currentUser?.lng)!))
      //  print(indexPath.row)
        if indexPath.row < orders.count{
            cell.showCellText(orders[indexPath.row] as! Order, title: self.title!, distance: self.calculateDistance(Double((orders[indexPath.row] as! Order).lng!), lat: Double((orders[indexPath.row] as! Order).lat!)),row: indexPath.row)
        }
         
       // showHeight =  showHeight + cell.contentView.frame.size.height
        
        return cell
    }
    

     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        showHeight =  showHeight + cell.contentView.frame.size.height
//        
//        if (HEIGHT_SCREEN - HEIGHT_NavBar) > showHeight { // 即数据没有填满屏幕
//            footer.hidden = true
//        }else{
//            footer.hidden = false
//        }
    }
     func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
       
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //        
        //        self.navigationController!.interactivePopGestureRecognizer!.enabled = true
        //        self.navigationController!.interactivePopGestureRecognizer!.delegate = nil
        
        if indexPath.row < orders.count {
            guard let lng = (orders[indexPath.row] as! Order).lng else{
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "获取经纬度数据失败,再试一次?")
                
                return
            }
            
            
            guard let lat = (orders[indexPath.row] as! Order).lat else{
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "获取经纬度数据失败,再试一次?")
                return
            }
            
            guard let t = self.title else{
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "获取标题失败,再试一次?")
                return
            }
            
            
            let detail = ListsDetailViewController(order: orders[indexPath.row] as! Order, title: t, distance: calculateDistance(Double(lng), lat: Double(lat)))
            detail.hidesBottomBarWhenPushed = true
            
            
            self.navigationController?.pushViewController(detail, animated: true)
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
      //  print("\(dist)")
        return "\(dist)"
    }
    
    
    func radians(_ degrees:Double)->Double{
        return(degrees*3.14159265)/180.0
        
    }
    
    func loadData(){
        
        User.GetOrderList(self.oderbyTime, success: {[weak self] orders in
            if let strongSelf = self{
                MBProgressHUD.hide(for:strongSelf.view, animated: true)
                //strongSelf.orders = orders
                if orders.count < 20{
                    strongSelf.footer.endRefreshingWithNoMoreData()
                }
                
//                for item in orders{
//                    strongSelf.orders.append(item)
//                }
                
                strongSelf.orders = orders
               // print("成功.....-------")
                //   print(orders)
                strongSelf.tableView.isUserInteractionEnabled = true
                strongSelf.tableView.reloadData()
            } }) { (error) in
                
                self.tableView.isUserInteractionEnabled = true
                MBProgressHUD.hide(for: self.view, animated: true)
                print(error.localizedDescription)
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
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
        
        loadDataByUp(oderbyTime)
        
    }
    
    //添加下拉刷新
    func headRefresh() {
        
        //        if !self.orders .isEmpty {
        //            self.orders .removeAll() // 移除所有数据
        //        }
        
       // showHeight = 0.0
        
        pageIndex = 1 //返回第一页
        footer.resetNoMoreData() // 重启
        self.oderbyTime["pageindex"]=self.pageIndex
        loadDataByPull(oderbyTime)
    }
    
    
    func loadDataByUp(_ param :NSMutableDictionary){
        
        // MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        User.GetOrderList(param, success: { tmpOrders in
            
             self.footer.endRefreshing()
            
            if tmpOrders.count < 20{
                self.footer.endRefreshingWithNoMoreData()
            }
            
            // 先判断上拉是否获取的数据,没有数据不再请求
            if tmpOrders.count == 0{
                
              //  weakSelf?.pageIndex -= 1 // 当前页减一,保证currentpage最大为总页数
                //  MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
                self.footer.endRefreshingWithNoMoreData()
                return
            }else{
                
                for item in tmpOrders{
                   self.orders.add(item)
                }
                
                self.tableView.reloadData()
               
            }
        }) { (error) in
            
            self.footer.endRefreshing()
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle: error.localizedDescription)

        }
        
    }
    
    func loadDataByPull(_ param :NSDictionary){
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.GetOrderList(param, success: { orders in
            
            self.header.endRefreshing()
            
            if orders.count < 20{
                self.footer.endRefreshingWithNoMoreData()
            }
            
            if orders.count == 0 {
                
                self.orders.removeAllObjects()
                self.tableViewDisplayWithMsg("暂时没有订单数据", ifNecessagryForRowCount: orders.count)
            }else{
                self.orders = orders
            }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.isUserInteractionEnabled = true
            self.tableView.reloadData()
            
        }) { (error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            // print("错误原因:\(error.localizedDescription)")
            self.tableView.isUserInteractionEnabled = true
            self.header.endRefreshing()
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle: error.localizedDescription)

        }
        
        
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
        }
    }
        
}

// MARK: - event response

extension RobListOneController{
    
    // 返回按钮事件
    func disMissBtn(){
        
        if (callBack != nil) {
            callBack!()
        }
        
        //  UIApplication.sharedApplication().statusBarHidden = false
       _ =  self.navigationController?.popViewController(animated: true)
        
    }
    
    func seachAction(){
        let orderSearchVC = RNOrderSearchViewController(paramDic: self.oderbyTime)
        navigationController?.pushViewController(orderSearchVC, animated: true)
    }

    
    // 重新刷新数据
    func updateData(){
        
       // headRefresh()
      //  header.beginRefreshing()
        
//        if self.orders.count != 0 {
//            self.orders.removeAllObjects() // 移除所有数据
//        }
        
//        pageIndex = 1 //返回第一页
//        footer.resetNoMoreData() // 重启
//        self.oderbyTime["pageindex"]=self.pageIndex
//        self.loadData()
        
        header.beginRefreshing()
    }
    
}

extension RobListOneController: SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate {
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 2
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleForSegmentAtIndex index: Int) -> String? {
        if index == 0 {
            return "未处理订单"
        }
        return "已预约订单"
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
            self.footer.endRefreshing()
            oderbyTime["action"] = "yqaction"
            header.beginRefreshing()
            break
        case 0:
            self.footer.endRefreshing()
            oderbyTime["action"] = "arrangeaction"
            header.beginRefreshing()
            break
        default:
            break
        }

    }
}
