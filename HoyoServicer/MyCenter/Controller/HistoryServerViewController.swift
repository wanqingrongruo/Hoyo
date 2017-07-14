//
//  HistoryServerViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 30/6/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MJRefresh
class HistoryServerViewController: UITableViewController {
    
    var servicecode:String?
    var pageIndex :Int = 1
    var orders=[Order]()
    let header = MJRefreshNormalHeader() // 下拉刷新
    let footer = MJRefreshAutoNormalFooter() //上拉刷新
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(servicecode:String) {
        
        var nibNameOrNil = String?("HistoryServerViewController.swift")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        self.servicecode=servicecode
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        
        setUpRefresh()
        self.header.beginRefreshing()//进入自动刷新页面
    }
    
    func    setUpTableView(){
        //    navigationController?.interactivePopGestureRecognizer?.enabled = false
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 400
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.title="服务订单记录"
        tableView.register(UINib(nibName: "RobListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RobListViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.navigationController?.navigationBarHidden=false
        self.navigationController?.isNavigationBarHidden = false
         navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(HistoryServerViewController.dissBtnAction))
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func dissBtnAction() {
         _ = navigationController?.popViewController(animated: true)
    }
    
    func setUpRefresh() {
        
        //下拉刷新
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headRefresh))
        tableView.mj_header = header
        
        //上拉刷新
        
        footer.setRefreshingTarget(self, refreshingAction:  #selector(footerRefresh))
        tableView.mj_footer = footer
        
    }
    
    
    func headRefresh(){
        
        //        User.GetServiceRecordByServiceTrain(self.servicecode!, pageindex: 1, pagesize: 10, success: { 
        //            print("成功")
        //            }) { (error) in
        //                print("失败")
        //        }
        self.pageIndex=1
        
        loadDataByPull()
        
    }
    
    func footerRefresh(){
        
        self.pageIndex+=1
        
        loadDataByUp()
        
    }
    
    func loadDataByPull(){
        
        weak  var weakSelf = self
        User.GetServiceRecordByServiceTrain(self.servicecode!, pageindex: self.pageIndex , pagesize: 10, success: { (tmpOrders) in
            
            if tmpOrders.isEmpty{
                
                weakSelf?.header.endRefreshing()
            }
            weakSelf?.orders=tmpOrders
            weakSelf?.tableViewDisplayWithMsg("暂时没有服务订单记录", ifNecessagryForRowCount: tmpOrders.count)
            self.tableView.reloadData()
            weakSelf?.header.endRefreshing()
        }) { (error) in
            
            weakSelf?.header.endRefreshing()
            
            print("失败")
        }
        
        
    }
    
    func loadDataByUp(){
        
        weak var weakSelf = self
        User.GetServiceRecordByServiceTrain(self.servicecode!, pageindex: self.pageIndex, pagesize: 10, success: { (tmpOrders) in
            print("成功")
            
            if tmpOrders.isEmpty
            {
                
                weakSelf?.pageIndex-=1
                weakSelf?.footer.endRefreshingWithNoMoreData()
                
            }
            else{
                for tmporder in tmpOrders{
                    
                    weakSelf?.orders.append(tmporder)
                }
                weakSelf?.tableView.reloadData()
                weakSelf?.footer.endRefreshing()
                
            }
            
            
        }) { (error) in
            print("失败")
            
            weakSelf?.footer.endRefreshing()
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orders.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RobListViewCell") as! RobListViewCell
        
        //设置点击颜色不变
        cell.selectionStyle = .none
        
        cell.showCellText(orders[indexPath.row], title: self.title!, distance: self.calculateDistance(Double(orders[indexPath.row].lng!), lat: Double(orders[indexPath.row].lat!)),row: indexPath.row)
        return cell
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
        self.navigationController!.interactivePopGestureRecognizer!.delegate = nil
        
        
        
        let detail = ListsDetailViewController(order: orders[indexPath.row], title: self.title!,distance: calculateDistance(Double(orders[indexPath.row].lng!), lat: Double(orders[indexPath.row].lat!)))
        detail.hidesBottomBarWhenPushed = true
        
        
        self.navigationController?.pushViewController(detail, animated: true)
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }    
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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
