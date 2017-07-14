//
//  NewsTableViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class NewsTableViewController: UITableViewController {
    
    var dataArr: [MessageModel] = []
    var messageList: Int = 0
        {
        didSet{
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // 导航转场动画代理
//        navigationController?.delegate = self
        
        instanceUI()
        NotificationCenter.default.addObserver(self, selector: #selector(NewsTableViewController.notice(_:)), name: NSNotification.Name(rawValue: messageNotification), object: nil)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden=false
        getDatas()
        getBadgeNum()
        NotificationCenter.default.addObserver(self, selector: #selector(ManageTableViewController.tabbarSelect), name: NSNotification.Name(rawValue: OrderPushNotification), object: nil)
    }
    
    func tabbarSelect() {
        tabBarController?.selectedIndex = 0
    }
    deinit {
        NotificationCenter.default.removeObserver(OrderPushNotification)
        NotificationCenter.default.removeObserver(messageNotification)
    }
    
    fileprivate func instanceUI() {
        self.title="消息"
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NewsTableViewCell")
        tableView.separatorStyle=UITableViewCellSeparatorStyle.none
        
    }
    
    func getDatas() {
        dataArr.removeAll()
        var modelArr: [MessageModel] = (MessageModel.allCachedObjects() as? [MessageModel])!
        modelArr.sort { (s1:MessageModel, s2: MessageModel) -> Bool in
            return Int(s1.msgId!)! > Int(s2.msgId!)!
        }
        dataArr = modelArr
        messageList = dataArr.count
    }
    
    //数组对象排序
    func onSort(_ s1: MessageModel,s2: MessageModel) -> Bool {
        return Int(s1.msgId!)! > Int(s2.msgId!)!
    }
    
    func notice(_ sender: AnyObject) {
        getDatas()
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
        return messageList 
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        if dataArr.count != 0 {
            let model:MessageModel = dataArr[indexPath.row]
            cell.selectionStyle=UITableViewCellSelectionStyle.blue
            cell.reloadUI(model)
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detail = GYDetailNewsVC()
        let model = dataArr[indexPath.row]
        //        detail.dataArr =  ScoreMessageModel.GetSourceArr(model.sendUserid!, entityName: "")
        detail.dataArr =  ScoreMessageModel.GetSourceArr(model.sendUserid!, entityName: "")
        MessageModel.updateSourceMessageNum(model.sendUserid!, entityName: "")
        detail.sendUserID = model.sendUserid
        detail.titleStr = model.sendNickName
        detail.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(detail, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model = dataArr[indexPath.row]
            ScoreMessageModel.deleteSource(model.sendUserid!, entityName: "")
            MessageModel.deleteSource(model.sendUserid!, entityName: "")
            getBadgeNum()
            getDatas()
        }
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return  "删除"
    }
    
    /**
     重新获取未读消息
     */
    func getBadgeNum() {
        var num:String = "0"
        let arr: [MessageModel] = (MessageModel.allCachedObjects() as? [MessageModel])!
        for item in arr {
            num = String(Int(num)! + Int(MessageModel.userMessageNum(item.sendUserid!, entityName: ""))!)
        }
        if num != "0" {
            if let tabBarItem = self.tabBarItem as? ESTabBarItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    tabBarItem.badgeValue = num
                }
            }
        } else {
            tabBarItem.badgeValue = nil
        }
    }
    
    
}

// MARK: - UINavigationControllerDelegate

extension NewsTableViewController: UINavigationControllerDelegate{
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = RNSimpleTrasition()
        return transition
    }
}


