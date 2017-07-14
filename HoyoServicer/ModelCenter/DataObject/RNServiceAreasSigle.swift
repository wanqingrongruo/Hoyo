//
//  RNServiceAreasSigle.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/11/7.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNServiceAreasSigle: NSObject {

    fileprivate static let sharedInstance = RNServiceAreasSigle()
    
    class var sharedManager: RNServiceAreasSigle{
        return sharedInstance
    }
    
    
    internal lazy var serviceAreas = {
        return [RNServiceAreasModel]()
    }()
   
}
