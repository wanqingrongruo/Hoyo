//
//  MyTeamTableViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/19.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
class MyTeamTableViewController: UITableViewController {
    
    var rightBtnState: Bool  = false
    var bootomViewState: Bool = true
    var teamMembers:[TeamMembers]?
    var localArr: [[String]]?
    var netArr: [[String]]?
    var areaArr:String?
    ///保存我的团队相关信息
    var myTeamData :[MyTeamModel]?
    {
        didSet{
            let modelTeam = myTeamData![0]
            if modelTeam.userself != "" {
                var lastArr: [String] = []
                if modelTeam.suplevel1 != "" {
                    lastArr.append(modelTeam.suplevel1!)
                }
                if modelTeam.suplevel2 != "" {
                    lastArr.append(modelTeam.suplevel2!)
                }
                if modelTeam.suplevel3 != "" {
                    lastArr.append(modelTeam.suplevel3!)
                }
                
                switch lastArr.count {
                case 0:
                    localArr = [["网点名称","团队编号","服务区域"],["创建人","创建时间","审核状态","保证金","合伙人分类"],["用户名","审请时间","审核状态"]]
                    netArr = [[modelTeam.groupName!,modelTeam.groupNumber!,areaArr!],[modelTeam.nickname!,modelTeam.createTime!,modelTeam.memberState!,"￥"+modelTeam.scopevalue!,modelTeam.scopename!],[modelTeam.userselfNickname!,modelTeam.userselfCreateTime!,modelTeam.userselfMemberState!]]
                    break
                case 1:
                    localArr = [["网点名称","团队编号","服务区域"],["创建人","创建时间","审核状态","保证金","合伙人分类"],["用户名","审请时间","审核状态"],["上级联系人1"]]
                    netArr = [[modelTeam.groupName!,modelTeam.groupNumber!,areaArr!],[modelTeam.nickname!,modelTeam.createTime!,modelTeam.memberState!,"￥"+modelTeam.scopevalue!,modelTeam.scopename!],[modelTeam.userselfNickname!,modelTeam.userselfCreateTime!,modelTeam.userselfMemberState!],[lastArr[0]]]
                    break
                case 2:
                    localArr = [["网点名称","团队编号","服务区域"],["创建人","创建时间","审核状态","保证金","合伙人分类"],["用户名","审请时间","审核状态"],["上级联系人1","上级联系人2"]]
                    netArr = [[modelTeam.groupName!,modelTeam.groupNumber!,areaArr!],[modelTeam.nickname!,modelTeam.createTime!,modelTeam.memberState!,"￥"+modelTeam.scopevalue!,modelTeam.scopename!],[modelTeam.userselfNickname!,modelTeam.userselfCreateTime!,modelTeam.userselfMemberState!],[lastArr[0],lastArr[1]]]
                    break
                case 3:
                    localArr = [["网点名称","团队编号","服务区域"],["创建人","创建时间","审核状态","保证金","合伙人分类"],["用户名","审请时间","审核状态"],["上级联系人1","上级联系人2","上级联系人3"]]
                    netArr = [[modelTeam.groupName!,modelTeam.groupNumber!,areaArr!],[modelTeam.nickname!,modelTeam.createTime!,modelTeam.memberState!,"￥"+modelTeam.scopevalue!,modelTeam.scopename!],[modelTeam.userselfNickname!,modelTeam.userselfCreateTime!,modelTeam.userselfMemberState!],[lastArr[0],lastArr[1],lastArr[2]]]
                    break
                default:
                    break
                }
                //特权信息(待定)[modelTeam.scopename!,modelTeam.scopevalue!,modelTeam.groupScopeName!,modelTeam.groupScoupValue!]
                
                switch modelTeam.userselfMemberState! {
                    
                case "审核失败","被封号了","审核中":
                    rightBtnState = false
                    bootomBtn.setTitle("取消申请", for: UIControlState())
                    break
                case "审核成功":
                    rightBtnState = true
                    bootomBtn.setTitle("退出团队", for: UIControlState())
                    bootomViewState = false
                    break
                default:
                    break
                }
            } else {
                localArr = [["网点名称","团队编号","服务区域"],["创建人","创建时间","审核状态","保证金","合伙人分类"]]
                netArr = [[modelTeam.groupName!,modelTeam.groupNumber!,areaArr!],[modelTeam.nickname!,modelTeam.createTime!,modelTeam.memberState!,"￥"+modelTeam.scopevalue!,modelTeam.scopename!]]
                switch modelTeam.memberState! {
                case "审核失败","被封号了","审核中":
                    rightBtnState = false
                    bootomBtn.setTitle("取消申请", for: UIControlState())
                    break
                case "审核成功":
                    rightBtnState = true
                    bootomViewState = false
                    //                    bootomBtn.setTitle("解散团队", forState: UIControlState.Normal)
                    break
                default:
                    break
                }
                
            }
            if rightBtnState  {
                let rightBarButton = UIBarButtonItem(title: "成员列表", style: .plain, target: self, action: #selector(ToMemberList))
                navigationItem.rightBarButtonItem=rightBarButton
                navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            }
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /**
         获取数据
         */
        //        instanceData()
        instanceUI()
        weak var weakSelf = self
        MBProgressHUD.showAdded(to: view, animated: true)
        //        DispatchQueue.global(priority: .high).async {
        //            weakSelf?.instanceData()
        //            DispatchQueue.main.async(execute: {
        //                weakSelf?.tableView.reloadData()
        //            })
        //        }
        
        DispatchQueue.global().async {
            weakSelf?.instanceData()
            DispatchQueue.main.async {
                weakSelf?.tableView.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    
    
    fileprivate func instanceData(){
        weak var weakSelf = self
        User.GetNowAuthorityDetailInfo({ (memberArr: [TeamMembers], teamArr: [MyTeamModel],areaArr1:String) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            weakSelf?.areaArr = areaArr1
            weakSelf?.myTeamData = teamArr
            weakSelf?.teamMembers = memberArr
            // ---
            weakSelf?.addUI()
        }) { (error:NSError) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            weakSelf?.navigationItem.rightBarButtonItem?.isEnabled = false
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
            
        }
    }
    
    fileprivate func instanceUI(){
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        self.title="我的团队"
        // UITableViewStyle.grouped
        tableView.backgroundColor = UIColor.groupTableViewBackground
        self.automaticallyAdjustsScrollViewInsets=false
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(WareHouseViewController.disMissBtn))
        tableView.separatorStyle=UITableViewCellSeparatorStyle.none
        tableView.register(GYTeamCell.self, forCellReuseIdentifier: "GYTeamCell")
    }
    
    func  addUI() {
        if bootomViewState {
            let booview = UIView()
            booview.frame = CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: 60)
            booview.backgroundColor = UIColor.groupTableViewBackground
            booview.addSubview(bootomBtn)
            bootomBtn.addTarget(self, action: #selector(MyTeamTableViewController.teamAction), for: UIControlEvents.touchUpInside)
            tableView.tableFooterView = booview
        }
    }
    
    func teamAction() {
        let modelTeam = myTeamData![0]
        if modelTeam.userself != "" {
            switch modelTeam.userselfMemberState! {
            case "审核失败","被封号了","审核中":
                let alertView=SCLAlertView()
                weak var weakSelf = self
                alertView.addButton("确定", action: {
                    MBProgressHUD.showAdded(to: weakSelf?.view.superview, animated: true)
                    User.RemoveTeamMember(Int(modelTeam.groupNumber!)!, success: {
                        print("取消成功")
                        MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
                        _ =  weakSelf?.navigationController?.popViewController(animated: true)
                    }, failure: { (NSError) in
                        MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
                        let alertView = SCLAlertView()
                        alertView.addButton("确定", action: {})
                        alertView.showError("温馨提示", subTitle: "取消失败请重试")
                    })
                })
                alertView.addButton("取消", action: {})
                alertView.showInfo("温馨提示", subTitle: "确定取消团队申请?")
                break
            case "审核成功":
                //退出当前团队，已成功
                let alertView = SCLAlertView()
                weak var weakSelf = self
                alertView.addButton("确定", action: {
                    MBProgressHUD.showAdded(to: weakSelf?.view.superview, animated: true)
                    User.RemoveTeamMember(Int(modelTeam.groupNumber!)!, success: {
                        print("退出成功")
                        MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
                        _ = weakSelf?.navigationController?.popViewController(animated: true)
                    }, failure: { (NSError) in
                        MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
                        let alertView = SCLAlertView()
                        alertView.addButton("确定", action: {})
                        alertView.showError("温馨提示", subTitle: "退出失败请重试")
                    })
                    
                })
                alertView.addButton("取消", action: {})
                alertView.showInfo("温馨提示", subTitle: "确认退出团队?")
            default:
                break
            }
        } else {
            switch modelTeam.memberState! {
            case "审核失败","被封号了","审核中":
                //取消创建团队申请.已成功
                let alertView = SCLAlertView()
                weak var weakSelf = self
                alertView.addButton("确定", action: {
                    MBProgressHUD.showAdded(to: weakSelf?.view.superview, animated: true)
                    User.DeleteTeamAll((Int(modelTeam.groupNumber!))!, success: {
                        MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
                        _ =  weakSelf?.navigationController?.popViewController(animated: true)
                    }, failure: { (NSError) in
                        MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
                        let alertView = SCLAlertView()
                        alertView.addButton("确定", action: {})
                        alertView.showError("温馨提示", subTitle: "取消申请失败请重试")
                    })
                    
                })
                alertView.addButton("取消", action: {})
                alertView.showInfo("温馨提示", subTitle: "确定取消创建团队申请?")
                break
            case "审核成功":
                //解散团队.已成功
                let alertView = SCLAlertView()
                weak var weakSelf = self
                alertView.addButton("确定", action: {
                    MBProgressHUD.showAdded(to: weakSelf?.view.superview, animated: true)
                    User.DeleteTeamAll(Int(modelTeam.groupNumber!)!, success: {
                        MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
                        _ = weakSelf?.navigationController?.popViewController(animated: true)
                    }, failure: { (NSError) in
                        MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
                        let alertView = SCLAlertView()
                        alertView.addButton("确定", action: {})
                        alertView.showError("温馨提示", subTitle: "解散失败请重试")
                    })
                })
                alertView.addButton("取消", action: {})
                alertView.showError("温馨提示", subTitle: "确定解散团队?")
                break
            default:
                break
            }
        }
    }
    
    func disMissBtn() {
        _ = navigationController?.popViewController(animated: true)
    }
    /**
     跳转到成员列表
     */
    func ToMemberList() {
        
        //        guard let userId = User.currentUser?.id else {
        //            let alertView = SCLAlertView()
        //            alertView.addButton("确定", action: {})
        //            alertView.showError("提示", subTitle: "未获取到当前用户ID")
        //            return
        //        }
//        User.MemberIdentifier(success: { (userIdentifier) in
//            // print("=======\(identifier)")
//            switch userIdentifier.identifier {
//            case "该用户为团队创建人"?:
//                // 小组列表界面
//                guard let groupId = userIdentifier.groupId else{
//                    let alertView = SCLAlertView()
//                    alertView.addButton("确定", action: {})
//                    alertView.showError("提示", subTitle: "未获取到当前团队ID")
//                    return
//                }
//                let groupListVC = RNGroupListViewController(groupId)
//                self.navigationController?.pushViewController(groupListVC, animated: true)
//                break
//            case "该用户为小组负责人"?, "该用户为小组成员"?, "该用户未在任何团队中"?:
//                guard let teamID = userIdentifier.groupId else{
//                    let alertView = SCLAlertView()
//                    alertView.addButton("确定", action: {})
//                    alertView.showError("提示", subTitle: "获取小组ID失败")
//                    return
//                }
//                let teamGroupVC = RNTeamGroupViewController(teamid: teamID, groupName: "成员列表")
//                self.navigationController?.pushViewController(teamGroupVC, animated: true)
//                break
//            default:
//                break
//            }
//            
//            
//        }) { (error) in
//            let alertView = SCLAlertView()
//            alertView.addButton("确定", action: {})
//            alertView.showError("提示", subTitle: error.localizedDescription)
//        }
        //        let modelTeam = myTeamData![0]
        //        let teamList  = TeamListTableViewController()
        //        //        teamList.memberList = teamMembers
        //        teamList.memScope = modelTeam.userself
        //        self.navigationController?.pushViewController(teamList, animated: true)
    }
    
    /// 底部按钮
    fileprivate lazy var bootomBtn: UIButton = {
        let lb = UIButton()
        lb.backgroundColor = UIColor.orange
        lb.frame = CGRect(x: 5, y: 10, width: WIDTH_SCREEN - 10, height: 40)
        lb.layer.masksToBounds = true
        lb.layer.cornerRadius = 5
        
        return lb
    }()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return localArr?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let arr = localArr![section]
        return arr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let imageHeadView = UIImageView(frame: CGRect(x: 0, y: 64, width: WIDTH_SCREEN, height: 185))
            imageHeadView.image = UIImage(named: "banner3")
            tableView.tableHeaderView = imageHeadView
        }
        let arr = localArr![indexPath.section]
        let arr2 = netArr![indexPath.section]
        
        if arr[indexPath.row] == "特权信息" {
            let lastCell = Bundle.main.loadNibNamed("GYTeamSecondCell", owner: self, options: nil)?.last as! GYTeamSecondCell
            lastCell.reloadUI(arr2)
            lastCell.selectionStyle = UITableViewCellSelectionStyle.none
            return lastCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GYTeamCell") as! GYTeamCell
        cell.reloadUI(arr[indexPath.row],str2: arr2[indexPath.row])
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UITableViewHeaderFooterView()
        view.frame = CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: 20)
        view.contentView.backgroundColor = UIColor.groupTableViewBackground
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GYTeamCell") as! GYTeamCell
        let arr2 = netArr![indexPath.section]
        
        print(arr2[indexPath.row])
        return cell.heightForText(arr2[indexPath.row] as NSString) + 17.5
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 20
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    convenience  init() {
        var nibNameOrNil = String?("MyTeamTableViewController")
        
        //考虑到xib文件可能不存在或被删，故加入判断
        
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
            
        {
            nibNameOrNil = nil
            
        }
        
        self.init(nibName: nibNameOrNil, bundle: nil)
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
}



//MARK: - alertView 响应事件
/*
 extension MyTeamTableViewController: UIAlertViewDelegate {
 
 func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
 switch buttonIndex {
 case 1:
 let modelTeam = myTeamData![0]
 weak var weakSelf = self
 if modelTeam.userself != "" {
 switch modelTeam.userselfMemberState! {
 case "审核失败","被封号了","审核中":
 //取消进入当前团队，已成功
 MBProgressHUD.showHUDAddedTo(view.superview, animated: true)
 User.RemoveTeamMember(Int(modelTeam.groupNumber!)!, success: {
 print("取消成功")
 MBProgressHUD.hideHUDForView(weakSelf!.view.superview, animated: true)
 weakSelf?.navigationController?.popViewControllerAnimated(true)
 }, failure: { (NSError) in
 MBProgressHUD.hideHUDForView(weakSelf!.view.superview, animated: true)
 let alert = UIAlertView(title: "温馨提示", message: "取消失败请重试", delegate: nil, cancelButtonTitle: "确定")
 alert.show()
 })
 break
 case "审核成功":
 //退出当前团队，已成功
 MBProgressHUD.showHUDAddedTo(view.superview, animated: true)
 User.RemoveTeamMember(Int(modelTeam.groupNumber!)!, success: {
 print("退出成功")
 MBProgressHUD.hideHUDForView(weakSelf!.view.superview, animated: true)
 weakSelf?.navigationController?.popViewControllerAnimated(true)
 }, failure: { (NSError) in
 MBProgressHUD.hideHUDForView(weakSelf!.view.superview, animated: true)
 let alert = UIAlertView(title: "温馨提示", message: "退出失败请重试", delegate: nil, cancelButtonTitle: "确定")
 alert.show()
 })
 default:
 break
 }
 } else {
 switch modelTeam.memberState! {
 case "审核失败","被封号了","审核中":
 //取消创建团队申请.已成功
 MBProgressHUD.showHUDAddedTo(view.superview, animated: true)
 User.DeleteTeamAll((Int(modelTeam.groupNumber!))!, success: {
 MBProgressHUD.hideHUDForView(weakSelf!.view.superview, animated: true)
 weakSelf?.navigationController?.popViewControllerAnimated(true)
 }, failure: { (NSError) in
 MBProgressHUD.hideHUDForView(weakSelf!.view.superview, animated: true)
 let alert = UIAlertView(title: "温馨提示", message: "取消申请失败请重试", delegate: nil, cancelButtonTitle: "确定")
 alert.show()
 })
 break
 case "审核成功":
 //解散团队.已成功
 MBProgressHUD.showHUDAddedTo(view.superview, animated: true)
 User.DeleteTeamAll(Int(modelTeam.groupNumber!)!, success: {
 MBProgressHUD.hideHUDForView(weakSelf!.view.superview, animated: true)
 weakSelf?.navigationController?.popViewControllerAnimated(true)
 }, failure: { (NSError) in
 MBProgressHUD.hideHUDForView(weakSelf!.view.superview, animated: true)
 let alert = UIAlertView(title: "温馨提示", message: "解散失败请重试", delegate: nil, cancelButtonTitle: "确定")
 alert.show()
 })
 break
 default:
 break
 }
 }
 break
 default:
 break
 }
 }
 
 }
 */

