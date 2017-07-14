//
//  BluetoothAirPurifierFilterStatus.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/17.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BluetoothAirPurifierFilterStatus : NSObject

@property (copy,nonatomic) NSDate* lastTime;
@property (copy,nonatomic) NSDate* stopTime;
@property (nonatomic) int workTime;
@property (nonatomic) int maxWorkTime;
//-(void)load:(NSData*)data;
//-(void)reset;
@end
