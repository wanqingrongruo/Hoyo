//
//  BaseOznerObject.m
//  MxChip
//
//  Created by Zhiyongxu on 15/11/30.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "BaseOznerObject.h"

@implementation BaseOznerObject
#define TimeoutException 1
-(instancetype)init
{
    if (self=[super init])
    {
        waitObject=[[NSCondition alloc] init];
        self->_runingMode=Foreground;
    }
    return self;
}

-(NSError*)wait:(NSTimeInterval)timeout
{
    [waitObject lock];
    @try {
        
        self->errorinfo=nil;
        if ([waitObject waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeout]])
        {
            return errorinfo;
        }else
        {
            return [NSError errorWithDomain:@"com.ozner.BaseOznerObject" code: TimeoutException userInfo:nil];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [waitObject unlock];
    }
   
}
-(void)set
{
    [waitObject lock];
    @try {
        errorinfo=nil;
        [waitObject signal];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [waitObject unlock];
    }

}
-(void)set:(NSError *)error
{
    self->errorinfo=[error copy];
    [waitObject signal];
}
@end
