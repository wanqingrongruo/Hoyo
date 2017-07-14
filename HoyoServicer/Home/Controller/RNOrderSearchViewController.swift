//
//  RNOrderSearchViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/3/16.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MBProgressHUD

class RNSearchTextField: UITextField {
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var padding = super.leftViewRect(forBounds: bounds)
        padding.origin.x += 5
        return padding
    }
}


class RNOrderSearchViewController: UIViewController {
    
    var searchbar: RNSearchTextField!
    var selectView = UIView()
    var conditionLabel = UILabel() // 选项 label
    
    var paramsDic: NSMutableDictionary // 请求参数字典
    var topCondition: String = "yqaction"
    var searchContent = "" // 搜索内容
    
    var dataSource = NSMutableArray()
    
    var tableView: UITableView!
    
    lazy var heightForIndex = {  // 高度缓存
        return [IndexPath: CGFloat]()
    }()
    // 已经展示过的 cell 的高度是否存在改变的情况 -- 如果存在,每次在缓存高度的都重复缓存,反之,不重新缓存
    var isChangeForCellHeight = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        setNavigationItem("searchOrder.png", selector: #selector(seachAction), isRight: true)
        view.backgroundColor = UIColor.white

        setupUI()
        
        setUpTableView()
    }
    
    init(paramDic: NSMutableDictionary) {
       // self.paramsDic = NSMutableDictionary()
        self.paramsDic = paramDic.mutableCopy() as! NSMutableDictionary  // 深复制, 否则会出错
        
        // 搜索显示所有结果,不分组显示
        self.paramsDic.removeObject(forKey: "pagesize")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NSNotification.Name(rawValue: "UPDATEWAITORDER"), object: nil) // 观察更新数据通知
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}

// MARK: - private methods

extension RNOrderSearchViewController {
    
    func setupUI(){
        
        let padding:CGFloat = 55
        searchbar = RNSearchTextField(frame: CGRect(x: padding, y: 5, width: MainScreenBounds.size.width - 2*padding, height: 30))
        searchbar.backgroundColor = UIColor.white
        searchbar.borderStyle = .roundedRect
        searchbar.clearButtonMode = .whileEditing
        searchbar.leftViewMode = .always
        searchbar.returnKeyType = .search
        searchbar.delegate = self
        searchbar.font = UIFont.systemFont(ofSize: 12)
        searchbar.placeholder = "搜索订单号、手机号、姓名、地址"
        self.navigationItem.titleView = searchbar as UIView
        
        selectView.frame = CGRect(x: 0, y: 1, width: 80, height: 28)
        selectView.backgroundColor = UIColor.clear
       // selectView.layer.cornerRadius = 5
        searchbar.leftView = selectView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectOrderType))
        selectView.addGestureRecognizer(tap)
        
        conditionLabel.frame = CGRect(x: 5, y: 3, width: 61, height: 22)
       // conditionLabel.font = UIFont(name: "Bold", size: 11)
        conditionLabel.font = UIFont.systemFont(ofSize: 11)
        conditionLabel.textColor = UIColor.black
        conditionLabel.text = getTopCondition(type: paramsDic["action"] as? String)
        selectView.addSubview(conditionLabel)
        
        let iconImageView = UIImageView(frame: CGRect(x: 66, y: 14, width: 10, height: 10))
        iconImageView.image = UIImage(named: "cornerMark")
        selectView.addSubview(iconImageView)
        
    }
    
    func setUpTableView() {
        
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN - HEIGHT_NavBar), style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "RobListViewCell",bundle: nil), forCellReuseIdentifier: "RobListViewCell")
        
        view.addSubview(tableView)
    }
    
    func downloadData(){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        tableView.isUserInteractionEnabled = false
        
        User.GetOrderList(paramsDic, success: {[weak self] orders in
              if let strongSelf = self{
                MBProgressHUD.hide(for:strongSelf.view, animated: true)
                
                strongSelf.dataSource = orders
               
                strongSelf.tableView.isUserInteractionEnabled = true
                strongSelf.tableView.reloadData()
                
            } }) { (error) in
                
                self.tableView.isUserInteractionEnabled = true
                MBProgressHUD.hide(for: self.view, animated: true)

                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("错误提示", subTitle: error.localizedDescription)
        }

    }


    // 获取首要条件
    func getTopCondition(type: String?) -> String {
        
        guard let t = type else {
            return "未处理订单"
        }
        
        switch t {
        case "yqaction":
            // 待处理
            return "未处理订单"
        case "arrangeaction":
            // 已预约
            return "已预约订单"
        default:
            return "未处理订单"
            
        }
    }
    
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
    
    // 重新刷新数据
    func updateData(){
    
       heightForIndex.removeAll()
       downloadData()
    }


}


// MARK: - event response

extension RNOrderSearchViewController {
    
    // 返回按钮事件
    func disMissBtn(){
        
        if searchbar.isFirstResponder {
            searchbar.resignFirstResponder()
        }
        _ =  self.navigationController?.popViewController(animated: true)
        
    }
    
    func selectOrderType(){
        
        let popoverView = PopoverView()
        popoverView.menuTitles = ["未处理订单","已预约订单"]
        popoverView.textLabelColor = UIColor.white
        popoverView.cellColor = UIColor.orange
        popoverView.tableViewSeparatorColor = COLORRGBA(80, g: 80, b: 80, a: 1.0)
        
        popoverView.show(from: selectView, selected: { (index: Int) in
            
            self.conditionLabel.text =  popoverView.menuTitles[index] as? String
            
            switch index {
            case 0:
                self.paramsDic["action"] = "yqaction"
            case 1:
                self.paramsDic["action"] = "arrangeaction"
            default:
                self.paramsDic["action"] = "yqaction"
            }
            
        })

    }
    
    func seachAction(){
        
        // 搜索
        guard let searchText = searchbar.text, searchText != "" else {
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showWarning("提示", subTitle: "搜索内容不能为空哦")
            return
        }
        
        guard searchContent != searchText else {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showWarning("提示", subTitle: "不要总是搜索相同的内容咯~")
            return
        }
        
        searchContent = searchText
        searchbar.resignFirstResponder()
        
        paramsDic["searchWillDo"] = searchContent
        heightForIndex.removeAll()
        
        downloadData()
    }
}

// MARK: - UITableViewDelegate && UITableViewDataSoure

extension RNOrderSearchViewController: UITableViewDelegate,UITableViewDataSource{
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewDisplayWithMsg("没有搜索到订单数据", ifNecessagryForRowCount: dataSource.count)
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowheight = heightForIndex[indexPath]
        if (rowheight != nil) {
            return rowheight!
        }else{
            return 500
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isChangeForCellHeight{
            
            let rowHeight = cell.frame.size.height
            heightForIndex[indexPath] = rowHeight
        }else{
            if let _ = heightForIndex[indexPath]{
                // 不缓存
            }else{
                let rowHeight = cell.frame.size.height
                heightForIndex[indexPath] = rowHeight
            }
        }
        
    }


    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RobListViewCell") as! RobListViewCell
        cell.selectionStyle = .none
        
        if indexPath.row < dataSource.count{
            cell.showCellText(dataSource[indexPath.row] as! Order, title: "待处理", distance: self.calculateDistance(Double((dataSource[indexPath.row] as! Order).lng!), lat: Double((dataSource[indexPath.row] as! Order).lat!)),row: indexPath.row)
        }
        
        
        return cell
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row < dataSource.count {
            guard let lng = (dataSource[indexPath.row] as! Order).lng else{
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "获取经纬度数据失败,再试一次?")
                
                return
            }
            
            
            guard let lat = (dataSource[indexPath.row] as! Order).lat else{
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "获取经纬度数据失败,再试一次?")
                return
            }
            
//            guard let t = self.title else{
//                
//                let alertView=SCLAlertView()
//                alertView.addButton("确定", action: {})
//                alertView.showError("提示", subTitle: "获取标题失败,再试一次?")
//                return
//            }
            
            
            let detail = ListsDetailViewController(order: dataSource[indexPath.row] as! Order, title: "待处理", distance: calculateDistance(Double(lng), lat: Double(lat)))
            detail.hidesBottomBarWhenPushed = true
            
            
            self.navigationController?.pushViewController(detail, animated: true)
        }
        
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
        //  print("\(dist)")
        return "\(dist)"
    }
    
    
    func radians(_ degrees:Double)->Double{
        return(degrees*3.14159265)/180.0
        
    }
    
}


extension RNOrderSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        // 搜索
        seachAction()
        
        return true
    }
    
}

