//
//  RNJoinUsViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/18.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNJoinUsViewController: UIViewController {
    
    struct JoinModel {
        var headImage: UIImage
        var title: String
        var subTitle: String
    }
    
    var headerView: RNJoinUsHeaderView?
    
    var msg: String? = nil
    
    lazy var tabelView: UITableView = {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-HEIGHT_NavBar) , style: .plain)
        tableView.backgroundColor = COLORRGBA(239, g: 239, b: 239, a: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RNTableViewCell")
        
        return tableView
    }()
    
    lazy var dataSource: [JoinModel] = {
        
        let model01 = JoinModel(headImage: UIImage(named:"teamIcon")!, title: "我要创建团队", subTitle: "我是首席合伙人")
        let model02 = JoinModel(headImage: UIImage(named:"groupIcon")!, title: "我要创建小组", subTitle: "我是团队负责人")
        
        let arr = [model01, model02]
        
        return arr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "申请加入团队"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        if let m = msg {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: m)
        }
        
        setUI()
        
            
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
       // navigationController?.navigationBar.isTranslucent = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource

extension RNJoinUsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < dataSource.count {
            
            switch indexPath.row {
            case 0:
                // 创建团队
                let createTeamVC = RNCreateTeamViewController(nibName: "RNCreateTeamViewController", bundle: nil)
                self.navigationController?.pushViewController(createTeamVC, animated: true)
                break
            case 1:
                //　创建小组
                let createGroupVC = RNCreateGroupViewController(nibName: "RNCreateGroupViewController", bundle: nil)
                self.navigationController?.pushViewController(createGroupVC, animated: true)
                break
            default:
                 break
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RNTableViewCell")
        
        if indexPath.row < dataSource.count {
            
            let model = dataSource[indexPath.row]
            cell.imageView?.image = model.headImage
            cell.textLabel?.text = model.title
            cell.detailTextLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.text = model.subTitle
        }
        return cell
    }
    
}

//MARK: - UISearchBarDelegate

extension RNJoinUsViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // TO DO
        let groupSearchVC = RNGroupSearchViewController()
        self.navigationController?.pushViewController(groupSearchVC, animated: true)
        return false
    }
}

//MARK: - private methods

extension RNJoinUsViewController {
    
    func setUI(){
        
        headerView = Bundle.main.loadNibNamed("RNJoinUsHeaderView", owner: nil, options: nil)?.last as? RNJoinUsHeaderView
        headerView?.searchbar.delegate = self
        tabelView.tableHeaderView = headerView
        
        if let userid = User.currentUser?.id {
            headerView?.IDLabel.text = "我的ID: " + userid
        }else{
            headerView?.IDLabel.text = "我的ID: " + "未获取到"
        }

       
        view.addSubview(tabelView)
        
    }
    
    
    
}

//MARK: - event response

extension RNJoinUsViewController {
    
    func disMissBtn(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}
