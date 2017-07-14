//
//  RNTeamGroupViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/19.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD

class RNTeamGroupViewController: UIViewController {

    let teamid: String
    let groupName: String
    let identifier: String
    
    lazy var tabelView: UITableView = {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-HEIGHT_NavBar) , style: .grouped)
        tableView.backgroundColor = COLORRGBA(239, g: 239, b: 239, a: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RNTeamGroup", bundle: nil), forCellReuseIdentifier: "RNTeamGroup")
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetDataSource = self
        
        return tableView
    }()
    
    lazy var dataSource: [TeamMembers] = {
        
        let arr = [TeamMembers]()
        
        return arr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = groupName
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        setNavigationItem("详情", selector: #selector(detailAction), isRight: true)
        
        setUI()
        downloadData()
    }
    
    init(teamid: String, groupName: String, identifier: String) {
        self.teamid = teamid
        self.groupName = groupName
        self.identifier = identifier
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

extension RNTeamGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row < dataSource.count {
            let groupDetail = dataSource[indexPath.section]
//            guard let userD = groupDetail.userid else{
//                let alertView = SCLAlertView()
//                alertView.addButton("确定", action: {})
//                alertView.showError("提示", subTitle: "获取工程师ID失败")
//                return
//            }
            let memberDetailVC = RNMemberDetailViewController(memberDetail: groupDetail, identifier: identifier, deleteCallBack: { 
                // 刷新数据
                self.downloadData()
            })
            self.navigationController?.pushViewController(memberDetailVC, animated: true)
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RNTeamGroup", for: indexPath) as! RNTeamGroup
        
        if indexPath.row < dataSource.count {
            let memberDetail = dataSource[indexPath.section]
            cell.configCell(memberDetail)
        }
        return cell
    }
    
}

// MARK: - TBEmptyDataSetDataSource & TBEmptyDataSetDelegate

extension RNTeamGroupViewController: TBEmptyDataSetDataSource, TBEmptyDataSetDelegate {
    // MARK: - TBEmptyDataSet data source
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyTeam")
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let title = "无成员列表信息"
        var attributes: [String: Any]?
        
        attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0), NSForegroundColorAttributeName: UIColor.gray]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let description = "未获取到成员列表, 请确认网络是否畅通"
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

extension RNTeamGroupViewController {
    
    func setUI(){
        
        view.addSubview(tabelView)
    }
    
    func downloadData() {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.GetTeamMemberList(teamId: teamid, success: { (dataArray) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.dataSource = dataArray
            
            self.tabelView.reloadData()
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
    }
    
}

//MARK: - event response

extension RNTeamGroupViewController {
    
    func disMissBtn(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
    func detailAction(){
        
        let groupDetailVC = RNGroupDetailViewController(groupId: teamid, groupName: groupName , flag: 0)
        self.navigationController?.pushViewController(groupDetailVC, animated: true)

    }
}

