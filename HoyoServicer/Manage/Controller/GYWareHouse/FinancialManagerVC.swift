//
//  FinancialManagerVC.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/6.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
import MJRefresh


class FinancialManagerVC: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    
    var index: Int = 1
    let pageSize = 10
    var  expenditure: String?
        {
        didSet{
            
            if expenditure != "" {
                payNumLabel.text = expenditure
            } else {
                payNumLabel.text = "0.0"
            }
        }
    }
    var  income: String?
        {
        didSet{
            if income != "" {
                incomeNumLabel.text = income
            } else {
                print(income ?? "")
                incomeNumLabel.text = "0.0"
            }
        }
    }
    
    var dataArr: [AccountDetailModel] = []
        {
        didSet{
            tableView.reloadData()
        }
    }
    
    let header = MJRefreshNormalHeader() // 下拉刷新
    let footer = MJRefreshAutoNormalFooter() //上拉刷新
    var isLoading = false //　是否正在加载
    var moneyType: Int = 0 // 获取类型 0: 全部, 1: 收入, 2: 提现, 3:扣款
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instanceUI()
        
        setUpRefresh()
        header.beginRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(FinancialManagerVC.backAction))
        title = "财务管理"
        dataArr.removeAll()
    }
    
    // 添加上拉下拉刷新控件
    func setUpRefresh() {
        
        //下拉刷新
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headRefresh))
        tableView.mj_header = header
        
        //上拉刷新
        
        footer.setRefreshingTarget(self, refreshingAction:  #selector(footerRefresh))
        tableView.mj_footer = footer
        
    }

    // 上拉刷新事件
    
    func footerRefresh() {
        
        
        if isLoading {
            return
        }
        index += 1 //页码增加
        isLoading = true
        self.tableView.isUserInteractionEnabled = false
        getDatas()
        
    }
    
    //添加下拉刷新
    func headRefresh() {
        
        if isLoading{
            return
        }
        index = 1 //返回第一页
        isLoading = true
        self.tableView.isUserInteractionEnabled = false
        footer.resetNoMoreData() // 重启
        getDatas()
    }

    
    
    func getDatas() {
        
        print(index)
       // MBProgressHUD.showAdded(to: view, animated: true)
        User.GetOwenMoneyDetails(index, pagesize: pageSize,moneyType: moneyType, success: { (accountArr: [AccountDetailModel]) in
         
            
         //    MBProgressHUD.hide(for: self.view, animated: true)
            self.footer.endRefreshing()
            self.header.endRefreshing()
            
            if accountArr.count < self.pageSize {
                self.footer.endRefreshingWithNoMoreData()
            }
            
            if self.index == 1 {
                self.dataArr = accountArr
            }else{
                self.dataArr.append(contentsOf: accountArr)
            }
            
            self.isLoading = false
            self.tableView.isUserInteractionEnabled = true
            
            self.tableView.reloadData()
            
            
            
        }) { (error:NSError) in
            
           // MBProgressHUD.hide(for: self.view, animated: true)
            self.footer.endRefreshing()
            self.header.endRefreshing()
            
            self.isLoading = false
            self.tableView.isUserInteractionEnabled = true
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle: error.localizedDescription)
        }
    }
    
    func instanceUI(){
        view.backgroundColor = UIColor.white
        view.addSubview(topView)
        topView.addSubview(payLabel)
        topView.addSubview(incomeLabel)
        topView.addSubview(payNumLabel)
        topView.addSubview(incomeNumLabel)
        let segementArr = ["明细","收入","支出"]
        let segement = UISegmentedControl(items: segementArr)
        segement.frame = CGRect(x: 12, y: 60 + 12, width: WIDTH_SCREEN - 24, height: 35)
        segement.tintColor = UIColor(red: 35/255.0, green: 39/255.0, blue: 44/255.0, alpha: 1.0)
        segement.selectedSegmentIndex = 0
        segement.addTarget(self, action: #selector(segPressed(_:)), for: .valueChanged)
        view.addSubview(segement)
        
        tableView.frame = CGRect(x: 0, y: 95 + 12, width: WIDTH_SCREEN, height: HEIGHT_SCREEN - HEIGHT_NavBar - 95 - 12)
        tableView.backgroundColor =  UIColor(red: 246/255.0, green: 247/255.0, blue: 248/255.0, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 78
        tableView.register(UINib(nibName: "RNFinacialManagerCell", bundle: nil), forCellReuseIdentifier: "RNFinacialManagerCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
//        tableView.emptyDataSetDelegate = self
//        tableView.emptyDataSetDataSource = self
        
         view.addSubview(tableView)
       
    }
    
    
    //MARK: -界面所需控件
    fileprivate lazy var tableView: UITableView = {
        let tab = UITableView()
        return tab
    }()
    fileprivate lazy var topView: UIView = {
        let vi = UIView()
        vi.frame = CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: 60)
        //设置背景图片颜色
        vi.layer.contents = UIImage(named:"blackImgOfNavBg")?.cgImage
        return vi
    }()
    
    
    
    fileprivate lazy var payLabel: UILabel = {
        let lb = UILabel()
        lb.frame = CGRect(x: 0, y: 0, width: WIDTH_SCREEN/2, height: 30)
        //        lb.backgroundColor = UIColor.redColor()
        lb.text = "支出(元)"
        lb.textColor = UIColor.gray
        lb.textAlignment = NSTextAlignment.center
        return lb
    }()
    
    fileprivate lazy var incomeLabel: UILabel = {
        let lb = UILabel()
        lb.frame = CGRect(x: WIDTH_SCREEN/2, y: 0, width: WIDTH_SCREEN/2, height: 30)
        //        lb.backgroundColor = UIColor.purpleColor()
        lb.text = "收入(元)"
        lb.textColor = UIColor.gray
        lb.textAlignment = NSTextAlignment.center
        return lb
    }()
    
    fileprivate lazy var payNumLabel: UILabel = {
        let lb = UILabel()
        lb.frame = CGRect(x: 0, y: 30, width: WIDTH_SCREEN/2, height: 30)
        //        lb.backgroundColor = UIColor.redColor()
        lb.text = "0.0"
        lb.textColor = UIColor.white
        lb.textAlignment = NSTextAlignment.center
        return lb
    }()
    
    fileprivate lazy var incomeNumLabel: UILabel = {
        let lb = UILabel()
        lb.frame = CGRect(x: WIDTH_SCREEN/2, y: 30, width: WIDTH_SCREEN/2, height: 30)
        //        lb.backgroundColor = UIColor.purpleColor()
        lb.text = "0.0"
        lb.textColor = UIColor.white
        lb.textAlignment = NSTextAlignment.center
        return lb
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: - event respnse

extension FinancialManagerVC {
    
    func backAction(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    func segPressed(_ seg: UISegmentedControl) {
        
        if seg.selectedSegmentIndex == moneyType {
            return
        }
        
       // index = 1
       // footer.resetNoMoreData() // 重启
        
        switch seg.selectedSegmentIndex {
        case 0:
            moneyType = 0
            seg.selectedSegmentIndex = 0
            header.beginRefreshing()
        case 1:
            moneyType = 1
            seg.selectedSegmentIndex = 1
            header.beginRefreshing()
        case 2:
            moneyType = 2
            seg.selectedSegmentIndex = 2
            header.beginRefreshing()
        default:
            break
        }
    }
    
    
}

//MARK: - tableView代理方法 数据源
extension FinancialManagerVC
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if dataArr.count == 0 {
//            tableViewDisplayWithMsg("暂无数据", ifNecessagryForRowCount: 0)
//        }
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RNFinacialManagerCell") as! RNFinacialManagerCell
        cell.selectionStyle = .none
        
        if indexPath.row < dataArr.count {
            let model =  dataArr[indexPath.row]
            cell.reloadUI(model)
        }
        
        return cell
        
    }
    
}

// MARK: - TBEmptyDataSetDataSource & TBEmptyDataSetDelegate

extension FinancialManagerVC: TBEmptyDataSetDataSource, TBEmptyDataSetDelegate {
    // MARK: - TBEmptyDataSet data source
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyTeam")
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let title = "无数据"
        var attributes: [String: Any]?
        
        attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0), NSForegroundColorAttributeName: UIColor.gray]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let description = "当前无收支明细"
        var attributes: [String: Any]?
        
        attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.blue]
        return NSAttributedString(string: description, attributes: attributes)
    }
    
    func verticalOffsetForEmptyDataSet(in scrollView: UIScrollView) -> CGFloat {
        if let navigationBar = navigationController?.navigationBar {
            return -navigationBar.frame.height * 0.75 -  95 - 12
        }
        return 0
    }
    
    func verticalSpacesForEmptyDataSet(in scrollView: UIScrollView) -> [CGFloat] {
        return [25, 8]
    }
    
    
    // MARK: - TBEmptyDataSet delegate
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetTapEnabled(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetScrollEnabled(in scrollView: UIScrollView) -> Bool {
        return true
    }
}


