//
//  TeamMemberInfoVC.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/3.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

 @objc protocol TeamMemberInfoVCDelegate {
    
    @objc optional func reloadUI()
    
}

class TeamMemberInfoVC: UIViewController {
    
    var memScope:String?
    var delegate: TeamMemberInfoVCDelegate?
    var memberInfo: TeamMembers?
    
    
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var leaveLable: UILabel!
    @IBOutlet var nickName: UILabel!
    @IBOutlet var areaLable: UILabel!
    @IBOutlet var phoneNumLb: UILabel!
    @IBOutlet var detailAreaLb: UILabel!
    
    @IBOutlet var agreeBtn: UIButton!
    @IBOutlet var refuseBtn: UIButton!
    @IBOutlet var removeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instanceUI()
        instaceView()
    }
    
    fileprivate func instanceUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(TeamMemberInfoVC.dismissAction))
        title = "成员信息"
    }
    
    fileprivate func instaceView(){
        let urlStr = SERVICEADDRESS + (memberInfo?.headimageurl!)!
        print("\(urlStr)")
        iconImage.sd_setImage(with: URL(string:urlStr))
        leaveLable.text = memberInfo?.Scope
        nickName.text = memberInfo?.nickname
        areaLable.text = memberInfo?.province
        detailAreaLb.text = (memberInfo?.province)! + "  " + (memberInfo?.city)!
        phoneNumLb.text = memberInfo?.mobile
        
        if memScope == "" {
            if memberInfo!.MemberState == "70000" {
                agreeBtn.isHidden = false
                refuseBtn.isHidden = false
            } else if memberInfo!.MemberState == "70002" || memberInfo!.MemberState == "70003"{
                removeBtn.isHidden = false
            } else {
                removeBtn.isHidden = false
            }
        }
        
    }
    
    /**
     同意
     */
    @IBAction func agreeGetMem(_ sender: AnyObject) {
        let params:NSDictionary = ["GroupNumber":Int((memberInfo?.GroupNumber)!)!,"userid":Int((memberInfo?.userid)!)!,"result":70001]
        weak var weakSelf = self
        MBProgressHUD.showAdded(to: view, animated: true)
        User.AuditGroupMember(params, success: {
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            weakSelf?.delegate?.reloadUI!()
          _ =  weakSelf?.navigationController?.popViewController(animated: true)
        }) { (error:NSError) in
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showInfo("温馨提示", subTitle: "审核失败,请重试!")
            
        }
    }
    
    /**
     拒绝
     */
    @IBAction func refuseBtn(_ sender: AnyObject) {
        
        let params:NSDictionary = ["GroupNumber":Int((memberInfo?.GroupNumber)!)!,"userid":Int((memberInfo?.userid)!)!,"result":70002]
        weak var weakSelf = self
        MBProgressHUD.showAdded(to: view, animated: true)
        User.AuditGroupMember(params, success: {
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            weakSelf?.delegate?.reloadUI!()
             _ = weakSelf?.navigationController?.popViewController(animated: true)
        }) { (error:NSError) in
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showInfo("温馨提示", subTitle: "审核失败,请重试!")
        }
        
        
    }
    /**
     移除
     */
    @IBAction func removeBtn(_ sender: AnyObject) {
        
        let alertView=SCLAlertView()
        weak var weakSelf = self
        alertView.addButton("确定") {
            MBProgressHUD.showAdded(to: weakSelf?.view, animated: true)
            User.RemoveCurrentTeamMember(Int((weakSelf?.memberInfo?.GroupNumber)!)!, useid: Int((weakSelf?.memberInfo?.userid)!)!, success: {
                MBProgressHUD.hide(for: weakSelf?.view, animated: true)
                
                weakSelf?.delegate?.reloadUI!()
               _ =  weakSelf?.navigationController?.popViewController(animated: true)
                
                
            }) { (error:NSError) in
                MBProgressHUD.hide(for: weakSelf?.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("确定",action: {})
                alertView.showInfo("温馨提示", subTitle: "移除失败,请重试!")
                
            }
            
        }
        alertView.addButton("取消", action:{})
        alertView.showInfo("温馨提示", subTitle: "确定移除该成员?")
        
    }
    func dismissAction() {
        _ = navigationController?.popViewController(animated: true)
        //
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

