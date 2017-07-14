//
//  MyCenterTableViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD

class MyCenterTableViewController: UIViewController {
    
    
    var tableView: UITableView!
    
    lazy var dataSource:Array<RNMYCenterModel> = {
        
        var arr = [RNMYCenterModel]()
        let desc = ["实名认证","我的考试","我的网点","我的评价","我的车辆","服务直通车"]
        let logo = ["my_auth","my_exam","my_parter","my_site","my_car","my_exam"]
        for i in 0...5{
            let model = RNMYCenterModel()
            model.logo = logo[i]
            model.desc = desc[i]
            arr.append(model)
        }
        return arr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "我的"
        
        //        // 导航转场动画代理
        //        navigationController?.delegate = self
        
        view.backgroundColor = COLORRGBA(245, g: 245, b: 245, a: 1)
        
        initView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentUserDidChange), name: NSNotification.Name(rawValue: CurrentUserDidChangeNotificationName), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden=false
        NotificationCenter.default.addObserver(self, selector: #selector(MyCenterTableViewController.tabbarSelect), name: NSNotification.Name(rawValue: OrderPushNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyCenterTableViewController.selectTabbarAction), name: NSNotification.Name(rawValue: OrderPushNotificationString), object: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(OrderPushNotification)
        NotificationCenter.default.removeObserver(CurrentUserDidChangeNotificationName)
        NotificationCenter.default.removeObserver(OrderPushNotificationString)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - custom methods
    
    func initView(){
        
        
        // 初始化tableView的数据
        self.tableView=UITableView(frame:CGRect(x: 0, y: 0, width: WIDTH_SCREEN,height: HEIGHT_SCREEN-HEIGHT_NavBar),style:UITableViewStyle.grouped)
        // 设置tableView的数据源
        self.tableView!.dataSource=self
        // 设置tableView的委托
        self.tableView!.delegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero )
        self.tableView.register(UINib(nibName:"RNHeadViewTableViewCell", bundle:nil), forCellReuseIdentifier:"RNHeadViewTableViewCell")
        self.tableView.register(UINib(nibName: "RNDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "RNDetailTableViewCell")
        self.view.addSubview(self.tableView!)
        
    }
    
    
    func selectTabbarAction() {
        tabBarController?.selectedIndex = 2
    }
    
    
    func tabbarSelect() {
        tabBarController?.selectedIndex = 0
    }
    
    func CurrentUserDidChange() {
        self.tableView.reloadData()
    }
    
    
}

// MARK: - private mothods

extension MyCenterTableViewController {
    
    fileprivate func chooseTeam() {
        
        guard let userid = User.currentUser?.id else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "未获取到用户id")
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        User.MemberIdentifier(userid: userid, success: { (userIdentifier) in
            // print("=======\(identifier)")
            MBProgressHUD.hide(for: self.view, animated: true)
            switch userIdentifier.identifier {
            case "1"?:
                
                self.checkState(identifier: "1", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到团队编号", refuseDes: "团队创建申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case "2"?:
                self.checkState(identifier: "2", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到小组编号", refuseDes: "小组创建申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case "3"?:
                self.checkState(identifier: "3", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到小组编号", refuseDes: "加入申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case  "4"?:
                let joinUsVC = RNJoinUsViewController()
                self.navigationController?.pushViewController(joinUsVC, animated: true)
            default:
                break
            }
            
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
        
        
        
    }
    
    func checkState(identifier: String, state: String?, groupId: String?, GroupDes: String, refuseDes: String, waitDes: String){
        
        
        guard let state = state else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "未获取到审核状态")
            return
        }
        if state == "70001" {
            // 通过
            guard let groupId = groupId else{
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: GroupDes)
                return
                
            }
            
            if identifier == "1" {
                let groupListVC = RNGroupListViewController(groupId, identifier: identifier)
                self.navigationController?.pushViewController(groupListVC, animated: true)
                
            }else{
                let teamGroupVC = RNTeamGroupViewController(teamid: groupId, groupName: "成员列表", identifier: identifier)
                self.navigationController?.pushViewController(teamGroupVC, animated: true)
            }
            
            
        }else if state == "70003" {
            // 待审核
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: waitDes)
            
        }else{
            
            // 拒绝
            let joinUsVC = RNJoinUsViewController()
            joinUsVC.msg = refuseDes
            self.navigationController?.pushViewController(joinUsVC, animated: true)
            
        }
        
    }
    
}

// MARK: - UITableViewDelegate && UITableViewDataSoure

extension MyCenterTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != 1 {
            return 1
        }else {
            
            return dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            return 84
        }else{
            
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 20
        }else{
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "RNHeadViewTableViewCell") as! RNHeadViewTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            
            if User.currentUser?.headimageurl != nil
            {
                var tmpUrl = User.currentUser?.headimageurl
                if (tmpUrl!.contains("http"))==false {
                    tmpUrl!=(NetworkManager.defaultManager?.website)!+tmpUrl!
                }
                
                cell.headImageView.sd_setImage(with: URL(string: tmpUrl!))
                //e(data: (User.currentUser?.headimageurl)!)
                
            }
            
            cell.phoneLabel.text=User.currentUser?.mobile
            cell.idLabel.text="(工号:"+(User.currentUser?.id)!+")"
            cell.nameLabel.text=User.currentUser?.name
            
            return cell
            
        }else {
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "RNDetailTableViewCell") as! RNDetailTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            
            if indexPath.section == 1 {
                
                var model = RNMYCenterModel()
                model = dataSource[indexPath.row]
                cell.config(model, index: indexPath)
            }else{
                
                let model = RNMYCenterModel()
                model.desc = "设置"
                model.logo = "my_setup"
                cell.config(model, index: indexPath)
            }
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            self.navigationController?.pushViewController(UserInfoViewController(), animated: true)
        }else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                present(AuthenticationController(dissCall: nil), animated: true, completion: nil)
                
            case 1:
                self.navigationController?.pushViewController(MyExamViewController(), animated: true)
            case 2:
                
                chooseTeam()
            case 3:
                
                self.navigationController?.pushViewController(MyEvaluatTableViewController(), animated: true)
            case 4:
                
                self.navigationController?.pushViewController(RNMyCarViewController(), animated: true)
                // print("我的车辆")
                
            case 5:
                
                //设置扫码区域参数
                var style = LBXScanViewStyle()
                style.centerUpOffset = 44;
                style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner;
                style.photoframeLineW = 3;
                style.photoframeAngleW = 18;
                style.photoframeAngleH = 18;
                style.isNeedShowRetangle = false;
                
                style.anmiationStyle = LBXScanViewAnimationStyle.LineMove;
                
                //qq里面的线条图片
                style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
                
                let vc = ScanCodeViewController()
                vc.title="扫一扫"
                vc.scanStyle = style
                vc.hidesBottomBarWhenPushed=true
                self.navigationController?.pushViewController(vc, animated: true)
                
            // print("服务直通车")
            default:
                break
            }
            
            
        }else{
            
            self.navigationController?.pushViewController(SettingViewController(), animated: true)
            // print("设置")
        }
        
    }
    
}

// MARK: - UINavigationControllerDelegate

extension MyCenterTableViewController: UINavigationControllerDelegate{
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = RNSimpleTrasition()
        return transition
    }
}

