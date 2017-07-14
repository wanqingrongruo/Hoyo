//
//  RNTableView.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNTableView: UIView {

    fileprivate let screenWidth = UIScreen.main.bounds.size.width
   // private let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    fileprivate let tableViewHeight = UIScreen.main.bounds.size.height * 0.5
    fileprivate let toolBarHeight = 44.0
    
    // toolBar
    fileprivate lazy var toolBar: RNToolBarView! = RNToolBarView()
    
    // closure of button
    internal typealias BtnAction = () -> Void
    
    fileprivate var cancelAction: BtnAction? = nil{
        didSet{
            toolBar.cancelAction = cancelAction
        }
    }
    
    
}
    
