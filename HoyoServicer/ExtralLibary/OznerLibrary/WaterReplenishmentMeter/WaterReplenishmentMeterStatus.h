//
//  WaterReplenishmentMeterStatus.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/21.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WaterReplenishmentMeterStatus : NSObject

-(instancetype)init;
@property (readonly) BOOL power;
@property (readonly) float battery;
@property (readonly) BOOL testing;
@property (readonly) float moisture;
@property (readonly) float oil;

-(void)load:(NSData*)data;
-(void)loadTest:(int)adc;
-(void)startTest;
-(void)reset;
@end
