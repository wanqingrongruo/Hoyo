//
//  RNMemberDetailViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/22.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD

class RNMemberDetailViewController: UIViewController {
    
    typealias DeleteCallBack = () -> ()  // 移除回调
    
    let memberDetail: TeamMembers
    
    let identifier: String
    
    var deleteCallBack: DeleteCallBack
    
    lazy var tabelView: UITableView = {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-HEIGHT_NavBar) , style: .plain)
        tableView.backgroundColor = COLORRGBA(239, g: 239, b: 239, a: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        tableView.register(UINib(nibName: "RNTeamMemberDetail", bundle: nil), forCellReuseIdentifier: "RNTeamMemberDetail")
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetDataSource = self
        
        return tableView
    }()
    
    lazy var dataSource: TeamMembers = {
        
        let model = TeamMembers()
        
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = memberDetail.nickname
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
//        if identifier == "1" {  // 团队负责人才可以移除成员
//           setNavigationItem("移除", selector: #selector(deleteMember), isRight: true)
//        }
        
        setUI()
        downloadData()
    }
    
    init(memberDetail: TeamMembers, identifier: String, deleteCallBack: @escaping DeleteCallBack) {
        self.memberDetail = memberDetail
        self.identifier = identifier
        self.deleteCallBack = deleteCallBack
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

extension RNMemberDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            return 123
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
            cell = tableView.dequeueReusableCell(withIdentifier: "RNTeamMemberDetail", for: indexPath) as! RNTeamMemberDetail
            cell?.selectionStyle = .none
            (cell as! RNTeamMemberDetail).configCell(dataSource)
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

extension RNMemberDetailViewController: TBEmptyDataSetDataSource, TBEmptyDataSetDelegate {
    // MARK: - TBEmptyDataSet data source
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyTeam")
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let title = "该工程师信息为空"
        var attributes: [String: Any]?
        
        attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0), NSForegroundColorAttributeName: UIColor.gray]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let description = "未获取到成员详情, 请确认网络是否畅通"
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


//MARK: - private methods

extension RNMemberDetailViewController {
    
    func setUI(){
        
        view.addSubview(tabelView)
    }
    
    func downloadData() {
        
        if let id = memberDetail.userid {
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            User.GetTeamMemberDetails(userid: id, success: { (dataArray) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                self.dataSource = dataArray
                
                self.dataSource.nickname = self.memberDetail.nickname
                self.dataSource.headimageurl = self.memberDetail.headimageurl
                self.dataSource.userid = self.memberDetail.userid
                self.dataSource.title = self.memberDetail.title
                
                self.tabelView.reloadData()
                
            }) { (error) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: error.localizedDescription)
            }
            
        }else{
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "未获取到工程师ID")
            
        }
    }
    
    func deleteAction(){
        
        guard let userid = memberDetail.userid else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "未获取到当前用户ID")
            return
        }
        MBProgressHUD.showAdded(to: view, animated: true)
        User.SignOutTeam(userid: userid, success: {
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: { [weak self] in
            
                self?.deleteCallBack()
                self?.navigationController?.popViewController(animated: true)
                
            })
            alertView.showSuccess("提示", subTitle: "移除成员成功")
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }

    }
    
}

//MARK: - event response

extension RNMemberDetailViewController {
    
    func disMissBtn(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    func deleteMember() {
        
        let alertView = SCLAlertView()
        alertView.addButton("确定", action: {
            self.deleteAction()
        })
        alertView.addButton("取消", action: {})
        alertView.showWarning("提示", subTitle: "是否确定移除该成员?")
        
    }
    
    
}

