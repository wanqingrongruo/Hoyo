//
//  AirPurifierSensor.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/10.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#define AIR_PURIFIER_ERROR 0xffff

@interface BluetoothAirPurifierSensor : NSObject
@property (readonly,nonatomic)int Humidity;
@property (readonly,nonatomic)int PM25;
@property (readonly,nonatomic)int Temperature;
-(void)load:(NSData*)data;
-(void)reset;
@end
