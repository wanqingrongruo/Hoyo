//
//  BoundBankCardViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/30.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//  容若的简书地址:http://www.jianshu.com/users/274775e3d56d/latest_articles
//  容若的新浪微博:http://weibo.com/u/2946516927?refer_flag=1001030102_&is_hot=1


import UIKit
import IQKeyboardManager
import MBProgressHUD

class BoundBankCardViewController: UIViewController {
    var tableView: UITableView!
    var dataSource:Array<BankModel> = []{
        didSet{
            
            if dataSource.isEmpty {
                 tableViewDisplayWithMsg("没有银行卡,点击左上角添加银行卡吧", ifNecessagryForRowCount: dataSource.count)
            }else{
                
                tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
                
                //刷新数据
                tableView.reloadData()
                
                return

            }
        }
         
    }
    
    // MARK: - lift cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "我的银行卡"
        
        view.backgroundColor = UIColor(red: 40/255.0, green: 56/255.0, blue: 82/255.0, alpha: 1.0)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
       // navigationItem.rightBarButtonItem = UIBarButtonItem.createBarButtonItem("add_normal", target: self, action: #selector(addCards))
        
        navigationItem.rightBarButtonItem = createBarButtonItem(nil, imageName: "add_normal", target: self, action: #selector(addCards))

        
        initView()
        
        downloadDataFromServer()
        //新分支--主分支
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardReturnKeyHandler.init().lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        
       // navigationController?.navigationBarHidden = true
    }
    
    // MARK: - custom methods 
    
    func initView(){
        
        
        // 初始化tableView的数据
        self.tableView=UITableView(frame:CGRect(x: 0, y: 0, width: WIDTH_SCREEN,height: HEIGHT_SCREEN-HEIGHT_NavBar),style:UITableViewStyle.grouped)
        tableView.backgroundColor = UIColor(red: 40/255.0, green: 56/255.0, blue: 82/255.0, alpha: 1.0)
        // 设置tableView的数据源
        self.tableView!.dataSource=self
        // 设置tableView的委托
        self.tableView!.delegate = self
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.tableFooterView = UIView(frame: CGRect.zero )
        self.tableView.rowHeight = 120
        //
        self.tableView.register(UINib(nibName:"BoundCarViewCell", bundle:nil), forCellReuseIdentifier:"BoundCarViewCell")
        self.view.addSubview(self.tableView!)
        
    }
    
    //barItem
    func  createBarButtonItem(_ title:String?,imageName: String?, target:AnyObject?,action:Selector) -> UIBarButtonItem{
        
        let btn = UIButton()
        if title != nil {
            btn.setTitle(title, for: UIControlState())
        }
        
        if imageName != nil {
            btn.setImage(UIImage(named: imageName!), for: UIControlState())
        }

        
        btn.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        //btn.sizeToFit()
        btn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        return UIBarButtonItem(customView: btn)
        
    }

    
}


// MARK: - download data

extension BoundBankCardViewController{
    
    func downloadDataFromServer() -> Void {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        weak var weakSelf = self
        User.GetOwenBindBlankCard({ (tmpArr) in
            
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            weakSelf?.dataSource = tmpArr
        }){ (error) in
            
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            print("错误原因:\(error.localizedDescription)")
        }
        
    }
}


// MARK: - UITableViewDelegate && UITableViewDataSoure

extension BoundBankCardViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return dataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoundCarViewCell") as! BoundCarViewCell
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        /*
         使用这个方法的目的: 让UITableView 滑动更流畅
         这个代理方法是在现实cell之前被调用 -- 这里cell已经现实,此时执行数据绑定会更好
         当然这对cell定高的UITableView来说没有作用,但对动态高度的cell来说,很容易地让滑动更流畅
         */
        let  cell = cell as! BoundCarViewCell
        cell.contentView.backgroundColor = UIColor(red: 40/255.0, green: 56/255.0, blue: 82/255.0, alpha: 1.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if dataSource.count > indexPath.section {
            
            cell.configureForCell(dataSource[indexPath.section])
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
//    //删除一行
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
//        
//        
//    }
    //选择一行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //        let alert = UIAlertView()
        //        alert.title = "提示"
        //
        //        alert.addButtonWithTitle("Ok")
        //        alert.show()
    }
    
}


// MARK: - 没有数据时的用户提示

extension BoundBankCardViewController{
    
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
}

// MARK: - event response

extension BoundBankCardViewController{
    
    //左边按钮
    func disMissBtn(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    // 添加银行卡
    func addCards() {
       // let addCar = AddCarViewController()
       // self.navigationController?.pushViewController(addCar, animated: true)
        
        let addBankVC = RNNewAddBankViewController(nibName: "RNNewAddBankViewController", bundle: nil)
        self.navigationController?.pushViewController(addBankVC, animated: true)
        

    }
    
}
