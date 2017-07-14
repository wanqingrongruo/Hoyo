//
//  RNDebugOptional.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/4/1.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import Foundation

//: ## 两个调试 optional 的小技巧


// 1. 打印提示让自己死个明白
infix operator !! // infix 定义中序操作符

func !!<T>(optional: T?, errorMsg: @autoclosure () -> String) -> T{
    
    if let value = optional {
        return value
    }
    
    fatalError(errorMsg)
}


// 2. 进一步改进 force unwrapping 的安全性
// 把调试日志只留在debug mode，并在release mode，为force unwrapping到nil的情况提供一个默认值。就像之前我们提到过的??类似

infix operator !?

// ExpressibleByStringLiteral 将类型约束为 string
func !?<T:ExpressibleByStringLiteral & ExpressibleByDictionaryLiteral & ExpressibleByBooleanLiteral & ExpressibleByIntegerLiteral & ExpressibleByFloatLiteral & ExpressibleByArrayLiteral & ExpressibleByNilLiteral & ExpressibleByUnicodeScalarLiteral & ExpressibleByExtendedGraphemeClusterLiteral>(optional: T?, nilDefault: @autoclosure () -> (errorMsg: String, value: T)) -> T {
    
    assert(optional != nil, nilDefault().errorMsg) // 仅在 debug mode 生效
    
    return optional ?? nilDefault().value
}

// 由于Swift并没有提供类似ExpressibleByVoidLiteral这样的protocol，为了方便调试Optional<Void>，我们只能再手动重载一个非泛型版本的!?
func !?(optional: Void?, errorMsg: @autoclosure () -> String) {
    assert(optional != nil, errorMsg())
}
