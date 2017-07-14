//
//  WaterPurifierStatus.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseOznerObject.h"

typedef void (^onWaterPurifierStatusSetHandler) (NSData* data,OperateCallback cb);
@interface WaterPurifierStatus : NSObject
{
    onWaterPurifierStatusSetHandler callback;
}
-(instancetype)init:(onWaterPurifierStatusSetHandler)cb;

/*!
 @property power
 @discussion 电源
 */
@property (nonatomic,readonly) BOOL power;
/*!
 @property cool
 @discussion 制冷
 */
@property (nonatomic,readonly) BOOL cool;
/*!
 @property hot
 @discussion 加热
 */
@property (nonatomic,readonly) BOOL hot;
/*!
 @property sterilization
 @discussion 杀菌
 */
@property (nonatomic,readonly) BOOL sterilization;


-(void)setPower:(BOOL)power Callback:(OperateCallback)cb;
-(void)setSterilization:(BOOL)sterilization Callback:(OperateCallback)cb;
-(void)setCool:(BOOL)cool Callback:(OperateCallback)cb;
-(void)setHot:(BOOL)hot Callback:(OperateCallback)cb;

-(void)load:(BytePtr)bytes;

@end
