//
//  RNGroupSearchViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/23.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MBProgressHUD

class RNGroupSearchViewController: UIViewController {
    
    lazy var searchBar: UISearchBar = {
        
        let bar = UISearchBar(frame: CGRect(x:20, y: 0, width: WIDTH_SCREEN-120, height: 40))
        bar.placeholder = "填写小组名称/小组ID"
        bar.showsCancelButton = true
        bar.returnKeyType = .search
        bar.delegate = self
        bar.becomeFirstResponder()
//        let cancelButton = bar.value(forKey: "cancelButton") as! UIButton
//        cancelButton.isEnabled = false
//        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
//        cancelButton.setTitleColor(UIColor.green, for: .normal)
        
        return bar
    }()
    var searchString: String = ""
    
    lazy var tabelView: UITableView = {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-HEIGHT_NavBar) , style: .grouped)
        tableView.backgroundColor = COLORRGBA(239, g: 239, b: 239, a: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RNTeamGroupListTableViewCell", bundle: nil), forCellReuseIdentifier: "RNTeamGroupListTableViewCell")
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetDataSource = self
        
        return tableView
    }()
    
    lazy var dataSource:[GroupDetail] = {
        let arr = [GroupDetail]()
        return arr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItems = [UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn)),UIBarButtonItem.createBarButtonItem02("", target: self, action: #selector(spaceAction))]
        
       
        
        navigationItem.titleView = searchBar as UIView
        
        setUI()
        downloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = false
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
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

//MARK: - UITableViewDelegate & UITableViewDataSource

extension RNGroupSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        return 44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < dataSource.count {
            let groupDetail = dataSource[indexPath.section]
            guard let teamID = groupDetail.groupId else{
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "获取小组ID失败")
                return
            }
            let groupDetailVC = RNGroupDetailViewController(groupId: teamID, groupName: groupDetail.groupName ?? "小组详情", flag: 1)
            self.navigationController?.pushViewController(groupDetailVC, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RNTeamGroupListTableViewCell", for: indexPath) as! RNTeamGroupListTableViewCell
        
        if indexPath.row < dataSource.count {
            let groupDetail = dataSource[indexPath.section]
            
//            cell.nameLabel.isOpenHightLightForKeyword = true
//            cell.nameLabel.keyword = self.searchString
//            cell.IDLabel.isOpenHightLightForKeyword = true
//            cell.IDLabel.keyword = self.searchString
            
            cell.keyword = searchString
            cell.isOpenHighLight = true
            cell.configCell(groupDetail)
            
         
        }
        return cell
    }
    
}

// MARK: - TBEmptyDataSetDataSource & TBEmptyDataSetDelegate

extension RNGroupSearchViewController: TBEmptyDataSetDataSource, TBEmptyDataSetDelegate {
    // MARK: - TBEmptyDataSet data source
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyTeam")
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let title = "无小组列表信息"
        var attributes: [String: Any]?
        
        attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0), NSForegroundColorAttributeName: UIColor.gray]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let description = "没有搜索到相关信息,请确认搜索内容"
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


//MARK: - UISearchBarDelegate

extension RNGroupSearchViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        downloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        downloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


//MARK: - private methods

extension RNGroupSearchViewController {
    
//    func setSearchBar() {
//        
//        searchBar = UISearchBar
//    }
    
    func setUI(){
        
        view.addSubview(tabelView)
    }
    
    func downloadData() {
       // MBProgressHUD.showAdded(to: self.view, animated: true)
        User.QueryTeamList(query: searchString, success: { (dataArray) in
            
           //  MBProgressHUD.hide(for: self.view, animated: true)
            self.dataSource = dataArray
            
            self.tabelView.reloadData()
            
        }) { (error) in
            // MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
    }
    
}

//MARK: - event response

extension RNGroupSearchViewController {
    
    func disMissBtn(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    func cancelAction(){
        
        if searchBar.isExclusiveTouch {
            searchBar.isExclusiveTouch = !searchBar.isExclusiveTouch
            searchBar.resignFirstResponder()
            
        }
       
    }
    
    func spaceAction(){
        
    }
}

