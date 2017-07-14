//
//  WaterPurifierInfo.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaterPurifierInfo : NSObject

/**
 * 型号
 */
@property (copy,readonly) NSString*  Model;
/**
 * 机型
 */
@property (copy,readonly) NSString*  Type;
/**
 * 主板编号
 */
@property (copy,readonly) NSString*  MainBoard;
/**
 * 控制板编号
 */
@property (copy,readonly) NSString*  ControlBoard;
/**
 * 错误数量
 */
@property (readonly) int ErrorCount;
/**
 * 错误码
 */
@property (readonly) int Error;

-(void)load:(BytePtr)bytes;


@end
