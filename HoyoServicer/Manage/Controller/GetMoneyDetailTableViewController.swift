//
//  GetMoneyDetailTableViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 12/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class GetMoneyDetailTableViewController: UITableViewController {
    
    var bankInfo: String?//银行信息
    var getAmount:String? //提现金额
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "getMoneyDetailCell", bundle: Bundle.main), forCellReuseIdentifier: "getMoneyDetailCell")
        tableView.separatorStyle=UITableViewCellSeparatorStyle.none
        // setNavigationItem("back.png", selector: #selector(doBack), isRight: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        navigationItem.title = "提现详情"
        view.backgroundColor = UIColor.white
        
        let alertView=SCLAlertView()
        alertView.addButton("确定", action: {})
        alertView.showWait("提示", subTitle: "提现申请已提交,7-10个工作日审核成功后进行转账")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Table view data sougrce
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "getMoneyDetailCell") as! getMoneyDetailCell
        
        cell.selectionStyle = .none
        
        cell.bankInfoLabel.text = bankInfo
        let tmp = (getAmount! as NSString).doubleValue
        cell.getAmountLabel.text = String(format: "￥%2.f",tmp)
        
        weak var weakSelf = self
        cell.sucClosure = { () -> Void in
            
            _ = weakSelf?.navigationController?.popToRootViewController(animated: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return HEIGHT_SCREEN-HEIGHT_NavBar
    }
       
}

// MARK: - event response

extension GetMoneyDetailTableViewController{
    
    func disMissBtn() -> Void{
        _ = navigationController?.popViewController(animated: true)
    }
}

