//
//  BaseOznerObject.h
//  MxChip
//
//  Created by Zhiyongxu on 15/11/30.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
enum RunningMode {Background, Foreground};
typedef void (^OperateCallback)(NSError* error);
@interface BaseOznerObject : NSObject
{
    NSCondition* waitObject;
    NSError* errorinfo;
    
}
@property (nonatomic,readonly) enum RunningMode runingMode;
-(NSError*)wait:(NSTimeInterval)timeout;
-(void)set;
-(void)set:(NSError*)errorinfo;
@end
