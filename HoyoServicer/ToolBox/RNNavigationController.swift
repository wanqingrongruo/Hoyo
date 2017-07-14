//
//  RNNavigationController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/7/5.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//  容若的简书地址:http://www.jianshu.com/users/274775e3d56d/latest_articles
//  容若的新浪微博:http://weibo.com/u/2946516927?refer_flag=1001030102_&is_hot=1


import UIKit

class RNNavigationController: UINavigationController {

    // MARK: - Lift Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.interactivePopGestureRecognizer?.delegate = self

    }

}

// MARK: - Gesture Recognizer Delegate

extension RNNavigationController: UIGestureRecognizerDelegate{
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // 当导航栈中的视图控制器熟练小于等于1时,忽略 pop 手势
        if viewControllers.count <= 1{
            return false
        }
        
        return true
    }
}
