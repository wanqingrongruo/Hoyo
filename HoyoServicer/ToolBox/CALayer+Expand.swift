//
//  categoryzb.swift
//  OZner
//
//  Created by 赵兵 on 16/3/11.
//  Copyright © 2016年 sunlinlin. All rights reserved.
//

import Foundation

extension CALayer
{
    var borderColorWithUIColor:UIColor{
        set{
            self.borderColor = newValue.cgColor
        }
        get{
            return UIColor(cgColor: self.borderColor!)
        }
    }
}
