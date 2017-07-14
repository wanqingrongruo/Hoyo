//
//  RNAchievementViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/24.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//  容若的简书地址:http://www.jianshu.com/users/274775e3d56d/latest_articles
//  容若的新浪微博:http://weibo.com/u/2946516927?refer_flag=1001030102_&is_hot=1


import UIKit

protocol RNAchievementViewControllerDelegate {
    
    // 切换本月和历史
    func switchCurrentAndHistory()
}


class RNAchievementViewController: YZDisplayViewController {
    
    var currentOrHistory = true // 本月排行:true,历史排行: false
    
    // 本月
    let monthVC = RNMonthViewController()
    let monthVC02 = RNMonth02ViewController()
    
    // 历史
    let todayVC = RNTodayViewController()
    let weekVC = RNWeekViewController()
    
    
    var rightView:UIView! // 导航右侧
    
    var rightButton:UIButton! // 导航右侧按钮
    var currentLabel:UILabel! // 本月
    var historyLabel:UILabel! // 历史
    
    var delegate:RNAchievementViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "绩效排行榜"
        //navigationController?.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        space.width = -10
        navigationItem.setRightBarButtonItems([space,createBarButtonItem("本月",  title02:"历史", target: self, action: #selector(shareAction(_:)))], animated: true)
                
        setupAllControllers()
        settingTitleEffects()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
       // navigationController?.navigationBar.translucent = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
     //    navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
       // rightView.removeFromSuperview()
    }
    
    
    // 重写返回方法
    
//    override func popToLastWhenSlideLeftest() {
//        super.popToLastWhenSlideLeftest()
//        
//       _ = navigationController?.popViewController(animated: true)
//    }
    

   
    //创建此控制器下的多个控制器
    func setupAllControllers() {
//        
//        if currentOrHistory {
//            
//            if self.childViewControllers.count > 0 {
//                
//                todayVC.removeFromParentViewController()
//                weekVC.removeFromParentViewController()
//            }
////            monthVC.title = "团队排名"
////            self.addChildViewController(monthVC)
////            
////            //全国
////            
////            monthVC02.title = "全国排名"
////            self.addChildViewController(monthVC02)
//        }else{
//            
//            
//            if self.childViewControllers.count > 0 {
//                
//                monthVC.removeFromParentViewController()
//                monthVC02.removeFromParentViewController()
//            }

            
            //团队
            todayVC.title = "团队排名"
            self.addChildViewController(todayVC)
            
            //全国
           
            weekVC.title = "全国排名"
            self.addChildViewController(weekVC)

      //  }
        
        
    }
    
    //设置标题效果
    func settingTitleEffects(){
        
        //**********************************************************//
        //#warnning: 为了符合设计,将宽度等分了---需要更改在这里改(这里是标题) -- 还需要到YZDisplayViewController.m文件中更改下划线宽度
        //***********************************************************//
        
        let width = UIScreen.main.bounds.width/2.0
        
        self.titleScrollViewColor = UIColor(patternImage: UIImage(named: "blackImgOfNavBg")!)
        self.isShowUnderLine = true // 是否显示下滑线
        self.norColor = UIColor.white // 正常情况标题颜色
        self.selColor = UIColor.white // 选中情况标题颜色
        self.underLineColor = COLORRGBA(59, g: 166, b: 169, a: 1) // 下滑线颜色
        self.titleFont = UIFont.systemFont(ofSize: 20)
        self.titleWidths.addObjects(from: [width,width,width])
        self.isfullScreen = false
        
    }
    
    //barItem
    func  createBarButtonItem(_ title01: String?,title02: String?, target:AnyObject?,action:Selector) -> UIBarButtonItem{
        
//        let btn = UIButton()
//        if title != nil {
//            btn.setTitle(title, forState: UIControlState.Normal)
//        }
//        
//        
//        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
//        btn.sizeToFit()
//        
//        rightButton = btn
        
        rightView = UIView(frame: CGRect(x: WIDTH_SCREEN-82,y: 20,width: 82,height: 44))
        rightView.backgroundColor = UIColor.clear
        
        currentLabel = RNBaseUI.createLabel(title01!, titleColor: UIColor.red,font: 18, alignment: NSTextAlignment.center)
        currentLabel.frame = CGRect(x: 0, y: 5, width: 37, height: 34)
        rightView.addSubview(currentLabel)
        
        let l = RNBaseUI.createLabel("/", titleColor: UIColor.white, font: 18, alignment: NSTextAlignment.center)
        l.frame = CGRect(x: 37, y: 5, width: 8, height: 34)
        rightView.addSubview(l)
        
        historyLabel = RNBaseUI.createLabel(title02!, titleColor: UIColor.white, font: 14, alignment: NSTextAlignment.center)
        historyLabel.frame = CGRect(x: 45, y: 5, width: 37, height: 34)
        rightView.addSubview(historyLabel)
       
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(shareAction(_:)))
        rightView.addGestureRecognizer(tap)
        
        
        return UIBarButtonItem(customView: rightView)
        
    }


}

// MARK: - event response

extension RNAchievementViewController{
    
    //左边按钮
    func disMissBtn(){
       _ = navigationController?.popViewController(animated: true)
    }
    
    
    //右边按钮
    func shareAction(_ sender: UIButton) {
        
        if currentOrHistory {
            //当前本月---点击切换历史
            
            todayVC.type = "0"
            weekVC.type = "1"
            currentLabel.textColor = UIColor.white
            currentLabel.font = UIFont.systemFont(ofSize: 14)
            historyLabel.textColor = UIColor.red
            historyLabel.font = UIFont.systemFont(ofSize: 18)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "HISTORY"), object: nil,userInfo: nil)
        }else{
            //当前历史---点击切换本月
            todayVC.type = "3"
            weekVC.type = "4"
            currentLabel.textColor = UIColor.red
            currentLabel.font = UIFont.systemFont(ofSize: 18)
            historyLabel.textColor = UIColor.white
            historyLabel.font = UIFont.systemFont(ofSize: 14)
            //rightButton.setTitle("本月", forState: UIControlState.Normal)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "CURRENT"), object: nil,userInfo: nil)
        }
        
        currentOrHistory = !currentOrHistory
//        
//        
//        setupAllControllers()
    
            
          //  delegate?.switchCurrentAndHistory()
        
       // NSNotificationCenter.defaultCenter().postNotification("")
    }
    
}

