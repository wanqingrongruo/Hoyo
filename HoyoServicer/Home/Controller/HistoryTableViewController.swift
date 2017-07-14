//
//  HistoryTableViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 8/6/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
class HistoryTableViewController: UITableViewController {
    var orderDetail:OrderDetail?
    var historys:[HistoryList]?
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isStatusBarHidden=false
        self.navigationController?.navigationBar.isHidden=false
        
       // self.navigationController?.interactivePopGestureRecognizer?.enabled=true
        tableView.estimatedRowHeight = 400
        
        tableView.rowHeight = UITableViewAutomaticDimension
    tableView.register(UINib(nibName: "HistoryTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "HistoryTableViewCell")
        self.setNavigationItem("back.png", selector: #selector(doBack), isRight: false)
        tableView.separatorStyle = .none
        self.title="历史记录"
        addHistoryPullView()
        loadHistoryData()
        historys=[HistoryList]()
    }
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(orderDetail : OrderDetail) {
        
        var nibNameOrNil = String?("HistoryTableViewController.swift")
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    override func doBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addHistoryPullView(){
    self.tableView.addPullToRefresh { 
//        User.GetHomeTimeList((self.orderDetail?.id!)!, success: {
//            print("成功")
//            }, failure: { (error) in
//                print(error.localizedDescription)
//        })
        User.GetHomeTimeList((self.orderDetail?.id!)!, success: { (historys) in
            
            self.historys=historys
            self.tableView.pullToRefreshView.stopAnimating()
            self.tableView.reloadData()
            }, failure: { (error) in
                print(error.localizedDescription)
                self.tableView.pullToRefreshView.stopAnimating()
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("错误提示", subTitle: error.localizedDescription)
        })
        }
       
    }

    func loadHistoryData(){
      
            MBProgressHUD.showAdded(to: self.tableView, animated: true)
           User.GetHomeTimeList((self.orderDetail?.id!)!, success: { [weak self](historys)  in
            if let strongSelf=self{
                    MBProgressHUD.hide(for: strongSelf.tableView, animated: true)
                    strongSelf.tableView.isUserInteractionEnabled = true
                   
                    self?.historys=historys
                    print("成功.....-------")
                    
                    strongSelf.tableView.reloadData()
            
            }
           }) { [weak self] (error) in
                    if let strongSelf = self{
                        strongSelf.historys = [HistoryList]()
                        
                        //strongSelf.tableView.pullToRefreshView.stopAnimating()
                        self?.tableView.isUserInteractionEnabled = true
                        MBProgressHUD.hide(for: strongSelf.tableView, animated: true)
                        strongSelf.tableView.reloadData()
                        print(error.localizedDescription)
                        let alertView=SCLAlertView()
                        alertView.addButton("ok", action: {})
                        alertView.showError("错误提示", subTitle: error.localizedDescription)
                    }
            }
        
    
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (historys?.count)!
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell

        // Configure the cell...
        if (historys?.count==0){
        
        }
        else{
        cell.showHistoryText(historys![indexPath.row])
        }
        return cell
    }
 

  //关闭右滑返回上页功能
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//      //self.isCanSideBack=false
//        
//        if ((self.navigationController?.respondsToSelector(#selector(inter))) != nil){
//        //        }
//    }
//
//    func gesture
}
