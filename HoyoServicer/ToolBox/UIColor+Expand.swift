//
//  UIColor+ Expand.swift
//  OznerServer
//
//  Created by 赵兵 on 16/2/26.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

//
func COLORRGBA(_ r:Int,g:Int,b:Int,a:CGFloat)->UIColor
{
    return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a))
}
