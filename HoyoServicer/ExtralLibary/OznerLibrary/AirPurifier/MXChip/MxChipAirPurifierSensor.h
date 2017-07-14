//
//  AirPurifierSensor.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AIR_PURIFIER_ERROR 0xffff

@interface MxChipAirPurifierSensor : NSObject
{
     NSDictionary* propertys;
}
-(instancetype)init:(NSDictionary*)propertys;

@property (readonly,nonatomic,getter=getHumidity)int Humidity;
@property (readonly,nonatomic,getter=getPM25)int PM25;
@property (readonly,nonatomic,getter=getTemperature)int Temperature;
@property (readonly,nonatomic,getter=getVOC)int VOC;
@property (readonly,nonatomic,getter=getLight)int Light;
@property (readonly,nonatomic,getter=getTotalClean)int TotalClean;

@end
