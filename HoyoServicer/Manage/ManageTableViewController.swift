//
//  ManageTableViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
import MJRefresh

class ManageTableViewController: UITableViewController,ManageTableViewCellDelegate {
    
    let header = MJRefreshNormalHeader() // 下拉刷新
    
    var  accountModel: MyAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // 导航转场动画代理
//        navigationController?.delegate = self
        
        view.resignFirstResponder()
        
        self.automaticallyAdjustsScrollViewInsets=false
        tableView.register(UINib(nibName: "ManageTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ManageTableViewCell")
        
        // 获取资产详情
        downloadGetMoneyDetail()
        
        // 创建刷新
        setUpRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
                
        NotificationCenter.default.addObserver(self, selector: #selector(ManageTableViewController.tabbarSelect), name: NSNotification.Name(rawValue: OrderPushNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ManageTableViewController.selectTabbarAction), name: NSNotification.Name(rawValue: OrderPushNotificationString), object: nil)
    }
    
    func selectTabbarAction() {
        tabBarController?.selectedIndex = 2
    }
    
    func tabbarSelect() {
        tabBarController?.selectedIndex = 0
    }
    deinit {
        NotificationCenter.default.removeObserver(OrderPushNotification)
         NotificationCenter.default.removeObserver(OrderPushNotificationString)
    }
    func setUpRefresh() {
        
        //下拉刷新
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headRefresh))
        tableView.mj_header = header
        
        
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HEIGHT_SCREEN-HEIGHT_TabBar
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageTableViewCell", for: indexPath) as!  ManageTableViewCell
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        cell.delegate=self
        // Configure the cell...
        if let model = accountModel {
            cell.configCell(model)
        }
        
        
        return cell
    }
    /**
     ManageTableViewCellDelegate代理方法，从左到右，从上到下,button的tag分别为，1...8
     
     - parameter Tag: button的tag
     */
    func ButtonOfManageCell(_ Tag: Int) {
        switch Tag {
        case 1:
            let  financialManager = FinancialManagerVC()
            financialManager.expenditure = accountModel?.totalAssets ?? "0"
            financialManager.income = accountModel?.income ?? "0"
            financialManager.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(financialManager, animated: true)
            break
        case 2:
            let getMoney = GetMoneyViewController()
            getMoney.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(getMoney, animated: true)
            break
        case 3:
            let boundBank = BoundBankCardViewController()
            boundBank.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(boundBank, animated: true)
            break
        case 4:
            
            let achievement = RNAchievementViewController()
            achievement.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(achievement, animated: true)
            break
        case 5:
            let financialManager = FinancialManagerVC()
            financialManager.expenditure = accountModel?.totalAssets ?? "0"
            financialManager.income = accountModel?.income ?? "0"
            financialManager.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(financialManager, animated: true)
            
            break
        case 6:
            let newMember = RNRecruitNewMenmberViewController()
            newMember.hidesBottomBarWhenPushed  = true
            self.navigationController?.pushViewController(newMember, animated: true)
            break
            
        case 8://我的仓库
            let wareHouse = WareHouseViewController()
            wareHouse.hidesBottomBarWhenPushed  = true
            self.navigationController?.pushViewController(wareHouse, animated: true)
            break
            
        case 7://我的团队
            chooseTeam()
            break
        default:
            break
            
        }
        
    }
    
    fileprivate func chooseTeam() {
      
        guard let userid = User.currentUser?.id else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "未获取到用户id")
            return
        }
        MBProgressHUD.showAdded(to: view, animated: true)
        
        User.MemberIdentifier(userid: userid, success: { (userIdentifier) in
            // print("=======\(identifier)")
            MBProgressHUD.hide(for: self.view, animated: true)
            switch userIdentifier.identifier {
            case "1"?:
                
                self.checkState(identifier: "1", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到团队编号", refuseDes: "团队创建申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case "2"?:
                 self.checkState(identifier: "2", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到小组编号", refuseDes: "小组创建申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")

                break
            case "3"?:
                self.checkState(identifier: "3", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到小组编号", refuseDes: "加入申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")

                break
            case  "4"?:
                let joinUsVC = RNJoinUsViewController()
                self.navigationController?.pushViewController(joinUsVC, animated: true)
            default:
                break
            }
            
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }

        
        
    }
    
    func checkState(identifier: String, state: String?, groupId: String?, GroupDes: String, refuseDes: String, waitDes: String){
        
      
        guard let state = state else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "未获取到审核状态")
            return
        }
        if state == "70001" {
            // 通过
            guard let groupId = groupId else{
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: GroupDes)
                return
                
            }
            
            if identifier == "1" {
                let groupListVC = RNGroupListViewController(groupId, identifier: identifier)
                self.navigationController?.pushViewController(groupListVC, animated: true)

            }else{
                let teamGroupVC = RNTeamGroupViewController(teamid: groupId, groupName: "成员列表", identifier: identifier)
                self.navigationController?.pushViewController(teamGroupVC, animated: true)
            }
            
             
        }else if state == "70003" {
            // 待审核
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: waitDes)
            
        }else{
            
            // 拒绝
            let joinUsVC = RNJoinUsViewController()
            joinUsVC.msg = refuseDes
            self.navigationController?.pushViewController(joinUsVC, animated: true)

        }

    }
    
}

// MARK: - download data

extension ManageTableViewController{
    //获取账户余额
    func downloadGetMoneyDetail() -> Void {
        
        weak var weakSelf = self
        User.GetOwenMoney({ (model) in
            
            weakSelf?.accountModel = model
            
            weakSelf?.tableView.reloadData()
            
            weakSelf?.header.endRefreshing()
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}

// MARK: - event response

extension ManageTableViewController{
    
    // 下拉刷新事件
    
    func headRefresh() {
        
        downloadGetMoneyDetail()
    }
    
}


// MARK: - UI

// MARK: - UINavigationControllerDelegate

extension ManageTableViewController: UINavigationControllerDelegate{
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = RNSimpleTrasition()
        return transition
    }
}
