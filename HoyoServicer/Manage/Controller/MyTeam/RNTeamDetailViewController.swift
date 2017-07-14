//
//  RNTeamDetailViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/25.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD

class RNTeamDetailViewController: UIViewController {

    let groupID: String
    let groupName: String
    let flag: Int // 用来标识从哪个界面跳转过来的 -- 无用
    var footerView: RNTeamGroupDetailFooterView?
    
    lazy var tabelView: UITableView = {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-HEIGHT_NavBar) , style: .plain)
        tableView.backgroundColor = COLORRGBA(239, g: 239, b: 239, a: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        tableView.register(UINib(nibName: "RNTeamGroupDetail", bundle: nil), forCellReuseIdentifier: "RNTeamGroupDetail")
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetDataSource = self
        
        return tableView
    }()
    
    lazy var dataSource: GroupDetail = {
        
        let model = GroupDetail()
        
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "团队详情"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        setUI()
        downloadData()
    }
    
    init(groupId: String, groupName: String, flag: Int) {
        self.groupID = groupId
        self.groupName = groupName
        self.flag = flag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // navigationController?.setNavigationBarHidden(true, animated: animated)
        // navigationController?.navigationBar.isTranslucent = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource

extension RNTeamDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            let areas = dataSource.serviceArea
            if let a = areas, a.count > 0 {
                return "服务区域列表"
            }
            return nil
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 162
        }
        return 44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TO DO
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let areas = dataSource.serviceArea, areas.count > 0 {
            return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            let areas = dataSource.serviceArea
            
            if let a = areas {
                return a.count
            }else{
                return 0
            }
            
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        //
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNTeamGroupDetail", for: indexPath) as! RNTeamGroupDetail
            cell?.selectionStyle = .none
            (cell as! RNTeamGroupDetail).configCell(model: dataSource, flag: 0)
        }else{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
            if let areas = dataSource.serviceArea, indexPath.row < areas.count{
                let area = areas[indexPath.row]
                
                guard let pro = area.province, pro != "" else {
                    return cell!
                }
                var showArea = pro
                guard let city = area.city, city != "" else{
                    
                    cell?.textLabel?.text = showArea
                    return cell!
                }
                showArea += " / \(city)"
                guard let country = area.country, country != "" else {
                    cell?.textLabel?.text = showArea
                    return cell!
                }
                showArea += " / \(country)"
                cell?.textLabel?.text = showArea
            }
            
            
        }
        return cell!
    }
    
}

// MARK: - TBEmptyDataSetDataSource & TBEmptyDataSetDelegate

extension RNTeamDetailViewController: TBEmptyDataSetDataSource, TBEmptyDataSetDelegate {
    // MARK: - TBEmptyDataSet data source
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyTeam")
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let title = "团队信息为空"
        var attributes: [String: Any]?
        
        attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0), NSForegroundColorAttributeName: UIColor.gray]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let description = "未获取到团队详情, 请确认网络是否畅通"
        var attributes: [String: Any]?
        
        attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.blue]
        return NSAttributedString(string: description, attributes: attributes)
    }
    
    func verticalOffsetForEmptyDataSet(in scrollView: UIScrollView) -> CGFloat {
        if let navigationBar = navigationController?.navigationBar {
            return -navigationBar.frame.height * 0.75
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
    //
    //    func emptyDataSetWillAppear(in scrollView: UIScrollView) {
    //        print("EmptyDataSet Will Appear!")
    //    }
    //
    //    func emptyDataSetDidAppear(in scrollView: UIScrollView) {
    //        print("EmptyDataSet Did Appear!")
    //    }
    //
    //    func emptyDataSetWillDisappear(in scrollView: UIScrollView) {
    //        print("EmptyDataSet Will Disappear!")
    //    }
    //
    //    func emptyDataSetDidDisappear(in scrollView: UIScrollView) {
    //        print("EmptyDataSet Did Disappear!")
    //    }
}


//MARK: - RNTeamGroupDetailFooterViewDelegate

extension RNTeamDetailViewController: RNTeamGroupDetailFooterViewDelegate {
    
    func showProtocolDetail() {
        //
    }
    
    
    func joinUs() {
        //
        MBProgressHUD.showAdded(to: view, animated: true)
        User.JoinTeam(teamId: groupID, success: {
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {
                _ = self.navigationController?.popViewController(animated: true)
            })
            alertView.showSuccess("提示", subTitle: "申请成功,请等待审核")
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
    }
}

//MARK: - private methods

extension RNTeamDetailViewController {
    
    func setUI(){
        
        view.addSubview(tabelView)
        
        if flag == 1{
            
            footerView = Bundle.main.loadNibNamed("RNTeamGroupDetailFooterView", owner: nil, options: nil)?.last as? RNTeamGroupDetailFooterView
            footerView?.delegate = self
            tabelView.tableFooterView = footerView
        }

        
    }
    
    func downloadData() {
        
        User.GetTeamDetails(teamId: groupID, success: { (dataArray) in
            self.dataSource = dataArray
            
            self.tabelView.reloadData()
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
    }
    
}

//MARK: - event response

extension RNTeamDetailViewController {
    
    func disMissBtn(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
}

