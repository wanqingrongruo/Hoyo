//
//  RNMonthViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/24.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//  容若的简书地址:http://www.jianshu.com/users/274775e3d56d/latest_articles
//  容若的新浪微博:http://weibo.com/u/2946516927?refer_flag=1001030102_&is_hot=1


import UIKit
import MJRefresh
import MBProgressHUD

class RNMonthViewController: UIViewController {
    
    // MARK: - 声明变量
    
    var dataSource: [RankDetailModel] = []
    
    var tableView: UITableView!
    
    let cellIndentifier: String = "cellIdentifier"
    
    var currentPage: Int = 1 //获取数据-- 当前页码,默认值为1
    
    let header = MJRefreshNormalHeader() // 下拉刷新
    let footer = MJRefreshAutoNormalFooter() //上拉刷新
    
    // MARK: - life cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setUpTableView()
        
        setUpRefresh()
        
        header.beginRefreshing() // 进入页面自动刷新
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - custom mothods
    
    func setUpTableView() {
        
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN - HEIGHT_NavBar - HEIGHT_TabBar), style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.delegate = self
        // tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = 95
        
        tableView.register(UINib(nibName: "AchievementCell",bundle: nil), forCellReuseIdentifier: cellIndentifier)
        
        view.addSubview(tableView)
    }
    
    func downFirstData() {
        
        //  MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        weak var weakSelf = self
        User.GetPerRankDetails("3", pageindex: "1", pageSize: "10", success: { (dataArr) in
            
            if dataArr.isEmpty{
                
                //  MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
                weakSelf?.header.endRefreshing()
                weakSelf?.tableViewDisplayWithMsg("暂时没有全国排名数据", ifNecessagryForRowCount: dataArr.count)
                return
            }else{
                
                for item in dataArr{
                    
                    weakSelf?.dataSource.append(item)
                }
                
                //  MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
                weakSelf?.tableView.reloadData()
                weakSelf?.header.endRefreshing()
                
            }
        }) { (error) in
            //  MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
            print("错误原因:\(error.localizedDescription)")
            weakSelf?.header.endRefreshing()
        }
        
        
    }
    func downloadNextData() {
        
        
        // MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        weak var weakSelf = self
        User.GetPerRankDetails("1", pageindex: String(currentPage), pageSize: "10", success: { (dataArr) in
            
            // 先判断上拉是否获取的数据,没有数据不再请求
            if dataArr.isEmpty{
                
                weakSelf?.currentPage -= 1 // 当前页减一,保证currentpage最大为总页数
                //MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
                weakSelf?.footer.endRefreshingWithNoMoreData()
                return
            }else{
                
                for item in dataArr{
                    weakSelf?.dataSource.append(item)
                }
                
                //  MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
                weakSelf?.tableView.reloadData()
                weakSelf?.footer.endRefreshing()
                
            }
        }) { (error) in
            // MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
            print("错误原因:\(error.localizedDescription)")
            weakSelf?.footer.endRefreshing()
        }
        
    }
    
    func setUpRefresh() {
        
        //下拉刷新
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headRefresh))
        tableView.mj_header = header
        
        //上拉刷新
        
        footer.setRefreshingTarget(self, refreshingAction:  #selector(footerRefresh))
        tableView.mj_footer = footer
        
    }
    
}

// MARK: - event response

extension RNMonthViewController{
    
    // 下拉刷新事件
    
    func headRefresh() {
        
        if !dataSource.isEmpty {
            dataSource.removeAll() // 移除所有数据
        }
        
        currentPage = 1 //返回第一页
        footer.resetNoMoreData() // 重启
        downFirstData()
    }
    
    // 上拉刷新事件
    
    func footerRefresh() {
        
        currentPage += 1 //页码增加
        downloadNextData()
        
    }
}


// MARK: - UITableViewDelegate && UITableViewDataSoure

extension RNMonthViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableViewDisplayWithMsg("暂时没有全国排名数据", ifNecessagryForRowCount: dataSource.count)
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier) as! AchievementCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if dataSource.count > indexPath.row{
            cell.configCell(dataSource[indexPath.row])
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) //取消选中效果
    }
    
    // 没有数据时的用户提示
    
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
            if (HEIGHT_SCREEN - HEIGHT_NavBar - HEIGHT_TabBar) > CGFloat(90*ifNecessagryForRowCount){ // 即数据没有填满屏幕
                footer.isHidden = true
            }else{
                footer.isHidden = false
            }        }
    }
    
}

