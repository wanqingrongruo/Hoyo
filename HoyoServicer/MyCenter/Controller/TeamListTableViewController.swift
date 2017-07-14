//
//  TeamListTableViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 20/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit


class TeamListTableViewController: UITableViewController, TeamMemberInfoVCDelegate {
    
    var index:Int = 1
    let pageSize = 10
    
    var memScope:String?
    var memberList: [TeamMembers] = []
        {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instanceUI()
        
        tableView.triggerPullToRefresh()
        
    }
    
    fileprivate func instanceData() {
        weak var weakSelf = self
        User.GetMyGroupMembers(pageSize, index: index, success: { (tmpArr:[TeamMembers]) in
//            if tmpArr.isEmpty {
//                weakSelf?.tableView.pullToRefreshView.stopAnimating()
//                weakSelf?.tableView.infiniteScrollingView.stopAnimating()
//                weakSelf?.tableViewDisplayWithMsg("暂无团队成员", ifNecessagryForRowCount: 0)
//                return
//            }
            if weakSelf?.index == 1 && weakSelf != nil{
                weakSelf?.memberList.removeAll()
                weakSelf?.memberList.append(contentsOf: tmpArr)
                weakSelf?.tableView.pullToRefreshView.stopAnimating()
                weakSelf?.tableView.infiniteScrollingView.stopAnimating()
                return
            }
            
            weakSelf?.memberList.append(contentsOf: tmpArr)
            weakSelf?.tableView.pullToRefreshView.stopAnimating()
            weakSelf?.tableView.infiniteScrollingView.stopAnimating()
            
        }) { (error:NSError) in
            
            weakSelf?.tableView.pullToRefreshView.stopAnimating()
            weakSelf?.tableView.infiniteScrollingView.stopAnimating()
        }
        
    }
    
    
    fileprivate func instanceUI(){
        self.title = "我的团队"
        tableView.estimatedRowHeight = 60
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.automaticallyAdjustsScrollViewInsets=false
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(WareHouseViewController.disMissBtn))
        tableView.tableFooterView = UIView()
        //tableView.separatorStyle=UITableViewCellSeparatorStyle.None
        
        //        teamListCell?.selectionStyle=UITableViewCellSelectionStyle.None
        tableView.register(UINib(nibName: "GYTeamListCell", bundle: Bundle.main), forCellReuseIdentifier: "GYTeamListCell")
        weak var weakSelf = self
        //下拉刷新
        tableView.addPullToRefresh {
            weakSelf?.index = 1
            weakSelf?.instanceData()
        }
        //上拉加载
        tableView.addInfiniteScrolling {
            weakSelf?.index = weakSelf!.index + 1
            weakSelf?.instanceData()
        }
    }
    
    func reloadUI() {
        tableView.triggerPullToRefresh()
    }
    
    func disMissBtn(){
       _ =  navigationController?.popViewController(animated: true)
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
            
        }else{
            tableView.backgroundView = nil
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
        return memberList.count 
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GYTeamListCell") as! GYTeamListCell
        cell.reloadUIWithModel(memberList[indexPath.row],memScope: memScope!)
        //设置点击颜色不变
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let teamMemberInfo = TeamMemberInfoVC()
        teamMemberInfo.memberInfo = memberList[indexPath.row]
        teamMemberInfo.memScope = memScope
        teamMemberInfo.delegate = self
        navigationController?.pushViewController(teamMemberInfo, animated: true)
        
    }
    
}
