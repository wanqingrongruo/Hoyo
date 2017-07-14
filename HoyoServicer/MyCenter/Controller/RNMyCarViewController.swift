//
//  RNMyCarViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/12.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD

class RNMyCarViewController: UIViewController {
    
    var tableView: UITableView!
    
    lazy var dataSource:Array<RNCarInfoModel> = {
        
        var arr = [RNCarInfoModel]()
        let desc = ["合伙人ID:","合伙人姓名:","车辆厂牌型号:","车辆号牌:","发动机号:","车架号:","GPS信号源:","初次领证时间:","交强险保单号:","商业保单号:","保险到期:","挂靠公司名称:","服务区域:","年检到期:","扩展字段:","扩展字段:"]
       
        for i in 0..<desc.count{
            let model = RNCarInfoModel()
            model.title = desc[i]
            arr.append(model)
        }
        return arr
    }()
    
    var viPicture: String? // 车辆图片(VI)
    var hasRealData = false // 是否有真实数据


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "我的车辆"
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        view.backgroundColor = COLORRGBA(245, g: 245, b: 245, a: 1)
        
        initView()
        downloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// MARK: - custom mothods

extension RNMyCarViewController{
 
    func initView(){
        
        // 初始化tableView的数据
        self.tableView=UITableView(frame:CGRect(x: 0, y: 0, width: WIDTH_SCREEN,height: HEIGHT_SCREEN-HEIGHT_NavBar),style:UITableViewStyle.grouped)
        // 设置tableView的数据源
        self.tableView!.dataSource=self
        // 设置tableView的委托
        self.tableView!.delegate = self
      //  self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect.zero )
        self.tableView.register(UINib(nibName:"RNCarInfoTableViewCell", bundle:nil), forCellReuseIdentifier:"RNCarInfoTableViewCell")
        self.tableView.register(UINib(nibName:"RNVIPictureTableViewCell", bundle:nil), forCellReuseIdentifier:"RNVIPictureTableViewCell")
        self.view.addSubview(self.tableView!)
        
    }
    
    func downloadData(){
        
        MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        User.GetMyCarInfo({ [weak self](arr, picture) in
            
            for (_,value) in arr.enumerated() {
                
                if value != "" {
                    self!.hasRealData = true
                    
                    break // 跳出当前循环
                }
                
          }
            
            if self!.hasRealData {
                
                for i in 0..<self!.dataSource.count {
                    let model = self!.dataSource[i]
                    if i<arr.count{
                        model.content = arr[i]
                    }else{
                        model.content = ""
                    }
                    
                }
            }
            
           
            self!.viPicture = picture
            
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow, animated: true)
            self!.tableView.reloadData()
            
            }) { (error) in
                
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("提示", subTitle: error.localizedDescription)

        }
    }
    
    
    func tableViewDisplayWithMsg(_ message: String, ifNecessagry: Bool ) -> Void {
        
        if  !ifNecessagry {
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

// MARK: - private mothods

extension RNMyCarViewController{
    
    func disMissBtn(){
        
        //  UIApplication.sharedApplication().statusBarHidden = false
        _ = self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate && UITableViewDataSoure

extension RNMyCarViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if viPicture != nil && viPicture != "" {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableViewDisplayWithMsg("没有车辆信息", ifNecessagry:  self.hasRealData)
        
        if self.hasRealData {
            
            if section == 0 {
                return dataSource.count
            }else{
               return 1
            }
            
        }else{
            return 0
        }
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }else{
            return 147
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "RNCarInfoTableViewCell") as! RNCarInfoTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            var model = RNCarInfoModel()
            model = dataSource[indexPath.row]
            cell.config(model, index: indexPath)
            
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RNVIPictureTableViewCell") as! RNVIPictureTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            if let pic = viPicture {
                cell.configCell(pic)
            }
            
            return cell
        }
       
    }
    
}

