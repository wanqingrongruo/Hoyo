//
//  MainViewController.swift
//  OznerServer
//
//  Created by 赵兵 on 16/2/25.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class ExampleBasicContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        textColor = UIColor.init(red: 61/255.0, green: 206/255.0, blue: 193/255.0, alpha: 1.0)
//        highlightTextColor = UIColor.init(red: 252/255.0, green: 13/255.0, blue: 27/255.0, alpha: 1.0)
//        iconColor = UIColor.init(red: 61/255.0, green: 206/255.0, blue: 193/255.0, alpha: 1.0)
//        highlightIconColor = UIColor.init(red: 252/255.0, green: 13/255.0, blue: 27/255.0, alpha: 1.0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


class ExampleBackgroundContentView: ExampleBasicContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        textColor = UIColor.init(red: 61/255.0, green: 206/255.0, blue: 193/255.0, alpha: 1.0)
//        highlightTextColor = UIColor.init(red: 252/255.0, green: 13/255.0, blue: 27/255.0, alpha: 1.0)
//        iconColor = UIColor.init(red: 61/255.0, green: 206/255.0, blue: 193/255.0, alpha: 1.0)
//        highlightIconColor = UIColor.init(red: 252/255.0, green: 13/255.0, blue: 27/255.0, alpha: 1.0)
//        backdropColor = UIColor.init(red: 37/255.0, green: 39/255.0, blue: 42/255.0, alpha: 1.0)
//        highlightBackdropColor = UIColor.init(red: 22/255.0, green: 24/255.0, blue: 25/255.0, alpha: 1.0)
    }
    
    public convenience init(specialWithAutoImplies implies: Bool) {
        self.init(frame: CGRect.zero)
        textColor = .white
        highlightTextColor = .white
        iconColor = .white
        highlightIconColor = .white
        backdropColor = UIColor.init(red: 17/255.0, green: 86/255.0, blue: 136/255.0, alpha: 1.0)
        highlightBackdropColor = UIColor.init(red: 22/255.0, green: 24/255.0, blue: 25/255.0, alpha: 1.0)
        if implies {
            let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ExampleBackgroundContentView.playImpliesAnimation(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .commonModes)
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func playImpliesAnimation(_ sender: AnyObject?) {
        if self.selected == true || self.highlighted == true {
            return
        }
        let view = self.imageView
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.15, 0.8, 1.15]
        impliesAnimation.duration = 0.3
        impliesAnimation.calculationMode = kCAAnimationCubic
        impliesAnimation.isRemovedOnCompletion = true
        view.layer.add(impliesAnimation, forKey: nil)
    }
}


class ExampleAnimateTipsContentView: ExampleBackgroundContentView {
    
    var duration = 0.3
    
    override func badgeChangedAnimation(animated: Bool, completion: (() -> ())?) {
        super.badgeChangedAnimation(animated: animated, completion: nil)
        notificationAnimation()
    }
    
    func notificationAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        impliesAnimation.values = [0.0 ,-8.0, 4.0, -4.0, 3.0, -2.0, 0.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}


class ExampleAnimateTipsContentView2: ExampleAnimateTipsContentView {
    
    override func notificationAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        self.badgeView.layer.add(impliesAnimation, forKey: nil)
    }
}

class MainViewController: ESTabBarController {
    
   // let myTabBarController = ESTabBarController()
    
    let c3=NewsTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//       DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
//            if JPUSHService.registrationID() != nil {
//                User.BingJgNotifyId(JPUSHService.registrationID(), success: {
//                    print("绑定极光通知成功")
//                }) { (error:NSError) in
//                    print("极光错误:"+"\(error)")
//                }
//            }
//        }
        
        DispatchQueue.global().async {
            if JPUSHService.registrationID() != nil {
                User.BingJgNotifyId(JPUSHService.registrationID(), success: {
                    print("绑定极光通知成功")
                }) { (error:NSError) in
                    print("极光错误:"+"\(error)")
                }
            }
        }

        
        
//        let c1=HomeTableViewController()
//        c1.tabBarItem.title="首页"
//        c1.tabBarItem.image=UIImage(named: "HomeIcon")
//        c1.tabBarItem.selectedImage=UIImage(named: "HomeIcon_on")
//        c1.tabBarItem.badgeValue=nil
//        let nav1=RNNavigationController(rootViewController: c1)
//        nav1.navigationBar.loadBlackBgBar()
//        let c2=ManageTableViewController()
//        c2.tabBarItem.title="管理"
//        c2.tabBarItem.image=UIImage(named: "ManageIcon")
//        c2.tabBarItem.selectedImage=UIImage(named: "ManageIcon_on")
//        c2.tabBarItem.badgeValue=nil
//        let nav2=RNNavigationController(rootViewController: c2)
//        nav2.navigationBar.loadBlackBgBar()
//        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.notice(_:)), name: NSNotification.Name(rawValue: messageNotification), object: nil)
//        c3.tabBarItem.title="消息"
//        c3.tabBarItem.image=UIImage(named: "NewsIcon")
//        c3.tabBarItem.selectedImage=UIImage(named: "NewsIcon_on")
//        getBadge()
//        let nav3=RNNavigationController(rootViewController: c3)
//        nav3.navigationBar.loadBlackBgBar()
//        let c4=MyCenterTableViewController()
//        c4.tabBarItem.title="我的"
//        c4.tabBarItem.image=UIImage(named: "MyCenterIcon")
//        c4.tabBarItem.selectedImage=UIImage(named: "MyCenterIcon_on")
//        c4.tabBarItem.badgeValue=nil
//        let nav4=RNNavigationController(rootViewController: c4)
//        nav4.navigationBar.loadBlackBgBar()
//        
//        self.viewControllers=[nav1,nav2,nav3,nav4]
        
        if let tBar = tabBarController?.tabBar as? ESTabBar {
            tBar.itemCustomPositioning = .fillIncludeSeparator
        }
        let c1 = HomeTableViewController()
        let c2 = ManageTableViewController()
        let c4 = MyCenterTableViewController()
        
        let nav1 = RNNavigationController(rootViewController: c1)
        nav1.navigationBar.loadBlackBgBar()
        let nav2 = RNNavigationController(rootViewController: c2)
        nav2.navigationBar.loadBlackBgBar()
        let nav3 = RNNavigationController(rootViewController: c3)
        nav3.navigationBar.loadBlackBgBar()
        let nav4 = RNNavigationController(rootViewController: c4)
        nav4.navigationBar.loadBlackBgBar()
        
        c1.tabBarItem = ESTabBarItem.init(ExampleAnimateTipsContentView2(), title: "首页", image: UIImage(named: "HomeIcon"), selectedImage: UIImage(named: "HomeIcon_on"))
        c2.tabBarItem = ESTabBarItem.init(ExampleAnimateTipsContentView2(), title: "管理", image: UIImage(named: "ManageIcon"), selectedImage: UIImage(named: "ManageIcon_on"))
        c3.tabBarItem = ESTabBarItem.init(ExampleAnimateTipsContentView2(), title: "消息", image: UIImage(named: "NewsIcon"), selectedImage: UIImage(named: "NewsIcon_on"))
        c4.tabBarItem = ESTabBarItem.init(ExampleAnimateTipsContentView2(), title: "我的", image: UIImage(named: "MyCenterIcon"), selectedImage: UIImage(named: "MyCenterIcon_on"))
        
        self.viewControllers=[nav1,nav2,nav3,nav4]
        
       // self.delegate = c1 // 设置 c1 为 tabBarController 的代理, 用于专场动画动画
        
        getBadge()

    }
    
    func notice(_ sender: AnyObject) {
        getBadge()
    }
    
    func getBadge() {
        var num:String = "0"
        
        let arr: [MessageModel] = (MessageModel.allCachedObjects() as? [MessageModel])! 
        
        for item in arr {
            num = String(Int(num)! + Int(MessageModel.userMessageNum(item.sendUserid!, entityName: ""))!)
        }
       //  print(num)
        
        if num != "0" {
           // c3.tabBarItem.badgeValue = num
            if let tabBarItem = c3.tabBarItem as? ESTabBarItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 ) {
                    tabBarItem.badgeValue = num
                }
            }
        } else {
            c3.tabBarItem.badgeValue = nil
        }

    }
    
    deinit {
        NotificationCenter.default.removeObserver(messageNotification)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //测试用途
//        let tmpMap=ZBMapViewController(location: CLLocationCoordinate2D(latitude: 39.931203, longitude: 116.395573), locationString: "上海浦东新区金桥镇1315")
//        self.presentViewController(tmpMap, animated: true, completion: nil)
    }
    
    
    
}
