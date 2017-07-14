//
//  MXChipIO.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/8.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../../Device/BaseDeviceIO.h"
#import "MQTTProxy.h"

@class MXChipIO;
@protocol MXChipIOStatusDelegate <NSObject>
@required
-(void)IOClosed:(MXChipIO *)io;
@end

@interface MXChipIO : BaseDeviceIO
{

    MQTTProxy* proxy;
    NSString* outKey;
    NSString* inKey;
    NSThread* runThread;
}
@property (weak,nonatomic) id<MXChipIOStatusDelegate> statusDelegate;
-(void)setSecureCode:(NSString*)secureCode;
-(instancetype)init:(NSString *)identifier MQTT:(MQTTProxy*)proxy Type:(NSString *)type;
-(BOOL)runJob:(nonnull SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait;
@end
