//
//  GYScoreVC.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/20.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

let scoreMessageCellID = "scoreMessageCellID"

class  GYScoreVC: UIViewController {
    
    var tableView: UITableView = UITableView()
    
    var dataArr: [ScoreMessageModel] = []
        {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instanceUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden=true
        view.backgroundColor = UIColor.red
        title = "评价详情"
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(GYScoreVC.dissBtnAction))
    }
    
    fileprivate func instanceUI() {
        
        UserDefaults.standard.setValue("0", forKey: "scoreNum")
        NotificationCenter.default.post(name: Notification.Name(rawValue: messageNotification), object: nil, userInfo: ["messageNum": "1"])
        tableView.frame = view.bounds
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        //        tableView.rowHeight = 300
        
        view.addSubview(tableView)
        tableView.register(ScoreMessageCell.self, forCellReuseIdentifier: scoreMessageCellID)
        
    }
    
    func dissBtnAction() {
       _ =  navigationController?.popViewController(animated: true)
    }
    
}

extension  GYScoreVC: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell =  tableView.dequeueReusableCell(withIdentifier: scoreMessageCellID) as! ScoreMessageCell
        
        let model: ScoreMessageModel = dataArr[indexPath.row]
        cell.selectionStyle = .none
        cell.reloadUI(model)
        return cell
        
    }
    
}

