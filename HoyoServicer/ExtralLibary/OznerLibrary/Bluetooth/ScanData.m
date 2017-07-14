//
//  ScanData.m
//  OznerBluetooth
//
//  Created by zhiyongxu on 15/3/16.
//  Copyright (c) 2015年 zhiyongxu. All rights reserved.
//

#import "ScanData.h"
#import "OznerHeader.h"
@implementation ScanData
//typedef struct _RecordTime
//{
//    UInt8 year;
//    UInt8 month;
//    UInt8 day;
//    UInt8 hour;
//    UInt8 min;
//    UInt8 sec;
//}*lpRecordTime,TRecordTime;

typedef struct
{
    UInt8 Type;
    UInt8 Length;
    Byte Data[10];
}*pScanResponseData,ScanResponseData;

typedef struct
{
    unsigned char Platform[3];
    unsigned char Model[6];
    TRecordTime Firmware;
    ScanResponseData ScanResponseData;
}*pScan_RepData,Scan_RepData_T;

-(instancetype)init:(NSString*)model platform:(NSString*) platform advertisement:(NSData*) advertisementData
{
    if (self=[super init])
    {
        _model=[[NSString stringWithString:model] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _platform=[NSString stringWithString:platform];
        _scanResponesData=[[NSData alloc] initWithBytes:[advertisementData bytes] length:[advertisementData length]];
        _scanResponesType=1;
    }
    return self;
}
-(instancetype)init:(NSString*)model
           platform:(NSString*) platform
           firmware:(NSDate*)firmware
  mainboardPlatform:(NSString*)mainboardPlatform
  mainboardFirmware:(NSDate*)mainboardFirmware
      advertisement:(NSData*)advertisementData
   scanResponesType:(int)type
{
        if (self=[super init])
            {
                    _model=[[NSString stringWithString:model] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    _platform=[NSString stringWithString:platform];
                    _scanResponesData=[[NSData alloc] initWithBytes:[advertisementData bytes] length:[advertisementData length]];
            
                    _firmware=[NSDate dateWithTimeIntervalSince1970:[firmware timeIntervalSince1970]];
                    _mainboardFirmware=[NSDate dateWithTimeIntervalSince1970:[mainboardFirmware timeIntervalSince1970]];
                    _mainboardPlatform=[NSString stringWithString:mainboardPlatform];
                    _scanResponesType=type;
                    _scanResponesData=[[NSData alloc] initWithBytes:[advertisementData bytes] length:[advertisementData length]];
            
                }
        return self;
    }
-(instancetype)init:(NSData *)data
{
    if (self=[super init])
    {
        if ((!data)||([data length]!=sizeof(Scan_RepData_T)))
        {
            NSException *exception = [NSException exceptionWithName: @"DataIsNil"
                                                             reason: @"Scan Data is Nil or size Invate"
                                                           userInfo: nil];
            
            @throw exception;
        }
        
        if (data)
        {
            pScan_RepData srd=(pScan_RepData)[data bytes];
            _model=[[NSString alloc] initWithData:[NSData dataWithBytes:srd->Model length:6] encoding:NSASCIIStringEncoding];
            _model=[_model stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
            _platform=[[NSString alloc] initWithData:[NSData dataWithBytes:srd->Platform length:3]
                                            encoding:NSASCIIStringEncoding];
            NSString* date=[NSString stringWithFormat:@"%d-%d-%d %d:%d:%d",srd->Firmware.year+2000,srd->Firmware.month,
                            srd->Firmware.day,srd->Firmware.hour,srd->Firmware.min,srd->Firmware.sec];
    
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            _firmware=[formatter dateFromString:date];
            //int len=srd->CustomData.Length;
            _scanResponesType=srd->ScanResponseData.Type;
            _scanResponesData=[NSData dataWithBytes:srd->ScanResponseData.Data length:MIN(10, data.length-17)];
    
        }
    }
    return self;
}
@end
