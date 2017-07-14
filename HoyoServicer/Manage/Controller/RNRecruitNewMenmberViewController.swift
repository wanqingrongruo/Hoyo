//
//  RNRecruitNewMenmberViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/18.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//  容若的简书地址:http://www.jianshu.com/users/274775e3d56d/latest_articles
//  容若的新浪微博:http://weibo.com/u/2946516927?refer_flag=1001030102_&is_hot=1


import UIKit
import MonkeyKing
import IQKeyboardManager

class RNRecruitNewMenmberViewController: UIViewController , UITextViewDelegate{
    
    var scrollView: UIScrollView!
    var myTeamLabel: UILabel!
    var needLabel: UILabel!
    var contactTextView: UITextView!
    var leftImageView: UIImageView!
    var rightImageView: UIImageView!
    var noteLabel: UILabel!
    var logoImageView: UIImageView!
    
    
    var isFirstInput: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "招募成员"
        view.backgroundColor = UIColor(red: 40/255.0, green: 56/255.0, blue: 82/255.0, alpha: 1.0)

        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        navigationItem.rightBarButtonItem = createBarButtonItem("分享", target: self, action: #selector(shareAction(_:)))
        //view.backgroundColor = UIColor(patternImage: UIImage(named: "add_member_bg")!)
        //
        // view.backgroundColor = UIColor.whiteColor()
        
        setupUI()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        // IQKeyboardReturnKeyHandler.init().lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "memberbg"), for: UIBarPosition.any,barMetrics: UIBarMetrics.default)
       // navigationController?.navigationBar.setBackgroundImage(imageFromColor(COLORRGBA(60, g: 165, b: 210, a: 1)), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "blackImgOfNavBg"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage =  UIImage(named: "blackImgOfNavBg")
        navigationController?.navigationBar.titleTextAttributes=[NSForegroundColorAttributeName:UIColor.white]
        
        //修改
    }
    
//    override func viewWillLayoutSubviews() {
//        
////         let height = HEIGHT_SCREEN - HEIGHT_NavBar - contactTextView.frame.origin.y - contactTextView.frame.size.height
////         leftImageView.snp.updateConstraints { (make) in
////            make.top.equalTo(contactTextView.snp.bottom).offset(height-30-14-15-30+7+10)
////        }
////        noteLabel.snp.updateConstraints { (make) in
////             make.top.equalTo(contactTextView.snp.bottom).offset(height-30-14-15-30+10)
////        }
////        rightImageView.snp.updateConstraints { (make) in
////             make.top.equalTo(contactTextView.snp.bottom).offset(height-30-14-15-30+7+10)
////        }
//
//        //试图让scrollView稍微可以滑动
//        let tempHeight = HEIGHT_SCREEN - HEIGHT_NavBar - logoImageView.frame.origin.y - logoImageView.frame.size.height
//        scrollView.snp.updateConstraints { (make) in
//            make.bottom.equalTo(logoImageView.snp.bottom).offset(tempHeight+10)
//        }
//        
////        contactTextView.clipCornerRadiusForView(contactTextView, RoundingCorners: [UIRectCorner.TopLeft,UIRectCorner.TopRight,UIRectCorner.BottomLeft,UIRectCorner.BottomRight], Radii: CGSizeMake(10, 10))
////        
//    }

    
    //创建控件
    func setupUI(){
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            //make.bottom.equalTo(logoImageView.snp.bottom).offset(10)
        }

        
        let contrainerView = UIView()
        contrainerView.backgroundColor = UIColor(patternImage: UIImage(named: "memberbg")!)
        scrollView.addSubview(contrainerView)
        contrainerView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(scrollView.snp.width)
            make.height.greaterThanOrEqualTo(HEIGHT_SCREEN-64+10)
        }
        
        myTeamLabel = RNBaseUI.createLabel("我的团队", titleColor: UIColor.white, font: 24, alignment: NSTextAlignment.center)
        contrainerView.addSubview(myTeamLabel)
        myTeamLabel.snp.makeConstraints { (make) in
            make.top.equalTo(60)
//            make.leading.equalTo(view.snp.leading).offset(50)
//            make.trailing.equalTo(view.snp.trailing).offset(-50)
            make.centerX.equalTo(view.snp.centerX)
            make.height.equalTo(45)
        }
        
        needLabel = RNBaseUI.createLabel("需要您", titleColor: UIColor.white, font: 20, alignment: NSTextAlignment.center)
        needLabel.isHidden = true
        contrainerView.addSubview(needLabel)
        needLabel.snp.makeConstraints { (make) in
            make.top.equalTo(myTeamLabel.snp.bottom).offset(10)
            make.centerX.equalTo(myTeamLabel.snp.centerX).offset(80)
            make.height.equalTo(35)
        }
        
        contactTextView = RNBaseUI.creatTextView(UIKeyboardType.default, returnKeyType: UIReturnKeyType.done)
        contactTextView.delegate = self
       // print("hhhhhhh:\(UIFont.familyNames())")
        contactTextView.font = UIFont(name: "Blackoak Std", size: 14)
        contactTextView.font = UIFont.systemFont(ofSize: 18)
        contactTextView.textColor = UIColor.white
        contactTextView.backgroundColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 0.2)
        contactTextView.tintColor = COLORRGBA(60, g: 165, b: 210, a: 1)
        contactTextView.text = "请输入招募文字(200字以内)"
       // contactTextView.scrollEnabled = false
        contrainerView.addSubview(contactTextView)
        contactTextView.snp.makeConstraints { (make) in
            make.top.equalTo(needLabel.snp.bottom).offset(60)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo((MainScreenBounds.size.width-60)*10/18.0)
        }
        
        contactTextView.layer.masksToBounds = true
        contactTextView.layer.cornerRadius = 10

        
        var vSpace = MainScreenBounds.size.height - 64 - 140 - 60 - (MainScreenBounds.size.width-60)*10/18.0 - 60 - 20
        if vSpace < 30 {
            vSpace = 30
            
            contactTextView.snp.updateConstraints { (make) in
                make.top.equalTo(needLabel.snp.bottom).offset(30)
            }
            
        }
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.clear
        contrainerView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.height.equalTo(60)
            make.bottom.equalTo(contrainerView.snp.bottom).offset(-30)
            //make.top.lessThanOrEqualTo(contactTextView.snp.bottom).offset(vSpace)
        }

        
        leftImageView = RNBaseUI.createImageView(nil, backgroundColor: UIColor.white)
        bottomView.addSubview(leftImageView)
        leftImageView.snp.makeConstraints { (make) in
            make.top.equalTo(7)
            make.leading.equalTo(0)
            make.width.equalTo(70)
            make.height.equalTo(1)
        }
        
        noteLabel = RNBaseUI.createLabel("服务家售后团队火热招募中", titleColor: UIColor.white, font: 15, alignment: NSTextAlignment.center)
        noteLabel.adjustsFontSizeToFitWidth = true
        bottomView.addSubview(noteLabel)
        noteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.leading.equalTo(leftImageView.snp.trailing).offset(5)
            make.height.equalTo(15)
        }
        
        
        rightImageView = RNBaseUI.createImageView(nil, backgroundColor: UIColor.white)
        bottomView.addSubview(rightImageView)
        rightImageView.snp.makeConstraints { (make) in
            make.top.equalTo(7)
            make.leading.equalTo(noteLabel.snp.trailing).offset(5)
            make.trailing.equalTo(0)
            make.width.equalTo(70)
            make.height.equalTo(1)
        }
        
        logoImageView = RNBaseUI.createImageView("HoyoLogoOfHead", backgroundColor: nil)
        logoImageView.contentMode = UIViewContentMode.scaleAspectFit
        contrainerView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.top.equalTo(noteLabel.snp.bottom).offset(15)
            make.centerX.equalTo(view.snp.centerX)
            make.height.equalTo(30)
            make.bottom.equalTo(contrainerView.snp.bottom).offset(-30)
        }

    }
    
    //barItem
    func  createBarButtonItem(_ title:String?,target:AnyObject?,action:Selector) -> UIBarButtonItem{
        
        let btn = UIButton()
        if title != nil {
            btn.setTitle(title, for: UIControlState())
        }
        
        
        btn.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        btn.sizeToFit()
        
        return UIBarButtonItem(customView: btn)
        
    }
    
    //纯色转图片
    func imageFromColor(_ color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsGetCurrentContext()
        return image!
    }

}


// MARK: - event response

extension RNRecruitNewMenmberViewController{
    
    //左边按钮
    func disMissBtn(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    //分享
    func shareAction(_ sender: UIButton) {
        
        MonkeyKing.registerAccount(.weChat(appID:ShareIDAndKey.Wechat.appID, appKey: ShareIDAndKey.Wechat.appKey))
        
        //跳转的url
        let shareURL = URL(string: "http://www.ozner.net")
        
        var desc: String = "浩优期待您的加入"
        
        if !contactTextView.text.isEmpty && !(contactTextView.text as NSString).isEqual(to: "请输入招募文字(200字以内)"){
            desc = contactTextView.text
        }
        
        let info = MonkeyKing.Info(
            title: "浩泽服务家",
            description: desc,
            thumbnail: UIImage(named: "manage_member"),
            media: .url(shareURL!)
        )
        
        
        //微信好友
        let sessionMessage = MonkeyKing.Message.weChat(.session(info: info))
        let weChatSessionActivity = AnyActivity(
            type: UIActivityType(rawValue: "com.ozner.WeChat.Session"),
            title: NSLocalizedString("微信好友", comment: ""),
            image: UIImage(named: "wechat_session")!,
            message: sessionMessage,
            completionHandler: { (result) in
                print("Session success: \(result)")
        })
        //朋友圈
        let timelineMessage = MonkeyKing.Message.weChat(.timeline(info: info))
        let weChatTimelineActivity = AnyActivity(
            type: UIActivityType(rawValue: "com.ozner.WeChat.Timeline"),
            title: NSLocalizedString("朋友圈", comment: ""),
            image: UIImage(named: "wechat_timeline")!,
            message: timelineMessage,
            completionHandler: { (result) in
                print("Timeline success: \(result)")
        })
        
        let activityViewController = UIActivityViewController(activityItems: [shareURL!], applicationActivities: [weChatSessionActivity,weChatTimelineActivity])
        activityViewController.excludedActivityTypes = [UIActivityType.mail,UIActivityType.message,UIActivityType.addToReadingList,UIActivityType.postToTwitter,UIActivityType.postToFacebook,UIActivityType.print,UIActivityType.assignToContact,UIActivityType.postToTwitter,UIActivityType.airDrop,UIActivityType.postToWeibo]
        present(activityViewController, animated: true, completion: nil)
        
    }


}

// MARK: - UITextViewDelegate

extension RNRecruitNewMenmberViewController{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text as NSString).isEqual(to: "\n") {
            textView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if isFirstInput {
            contactTextView.text = nil
            isFirstInput = false
        }
       
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            contactTextView.text = "请输入招募文字(200字以内)"
            isFirstInput = true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if (textView.text as NSString).length > 200 {
            textView.text = (textView.text as NSString).substring(to: 200)
            textView.resignFirstResponder()
            let alertView=SCLAlertView()
            alertView.addButton("ok", action: {})
            alertView.showError("错误提示", subTitle: "输入不能超过200个字")
        }
    }
}

//extension RNRecruitNewMenmberViewController: UIScrollViewDelegate{
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//       let contentOffset =  targetContentOffset.pointee
//        contentOffset.x
//        
//        
//    }
//}

