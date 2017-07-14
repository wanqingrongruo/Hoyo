//
//  BluetoothIOMgr.m
//  MxChip
//
//  Created by Zhiyongxu on 15/11/30.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "BluetoothIOMgr.h"
#import "ScanData.h"
#import "BluetoothSynchronizedObject.h"
#import "../Device/IOManager.hpp"
#import <UIKit/UIKit.h>
@interface BluetoothIOMgr()
{
    NSMutableArray* scanRespParseres;
}
@end

@implementation BluetoothIOMgr

#define iOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    
}

-(void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    
}

-(instancetype)init
{
    if (self=[super init])
    {
        scanRespParseres=[[NSMutableArray alloc] init];
        [BluetoothSynchronizedObject initSynchronizedObject];
        const char *queueName = [@"bluetooth_queue" UTF8String];
        queue=dispatch_queue_create(queueName, NULL);
        centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:queue];
        centralManager.delegate=self;
        addressList=[[NSMutableDictionary alloc] init];
        
    }
    return self;
}
-(void)registerScanResponseParser:(id<ScanResponseParserDelegate>)delgeate;
{
    for (id parser in scanRespParseres)
    {
        if (parser==delgeate) return;
    }
    [scanRespParseres addObject:delgeate];
}
-(bool)isScanning
{
    if (iOS9)
    {
        return centralManager.isScanning;
    }else
    {
        return bleScaning;
    }
    
}
-(void)scanThreadProc
{
    while (![[NSThread currentThread] isCancelled])
    {
        @synchronized([BluetoothSynchronizedObject synchronizedObject]) {
            if (![self isScanning])
            {
                bleScaning=true;
                [centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:UUID_Service]]
                                                       options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            }
            sleep(2.0f);
            [centralManager stopScan];
            bleScaning=false;
        }
        sleep(1.0f);
    }
    NSLog(@"exit");
}

-(void)stopTimeScan
{
    [centralManager stopScan];
}


-(NSString*)getIdentifier:(CBPeripheral*)peripheral
{
    @synchronized(addressList) {
        NSString* identifier=[addressList objectForKey:[peripheral.identifier UUIDString]];
        if (!identifier)
        {
            return [peripheral.identifier UUIDString];
        }
        return identifier;
    }
}


-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString* name=[peripheral name];
    if (!name)
    {
        NSLog(@"found nil name");
    }
    ScanData* scanData;
    if ([advertisementData objectForKey:CBAdvertisementDataServiceDataKey])
    {
        NSDictionary* dict=[advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
        CBUUID* uuid=[CBUUID UUIDWithString:@"FFF0"];
        NSData* data=[dict objectForKey:uuid];
        @try {
            if (scanRespParseres.count>0)
            {
                for (id parser in scanRespParseres)
                {
                    scanData=[parser parserScanData:peripheral data:data];
                    if (scanData) break;
                }
            }
            if (!scanData)
                scanData=[[ScanData alloc] init:data];
        }
        @catch (NSException *exception) {
            return;
        }
        
    }
    //    NSLog(@"found:%@",peripheral.name);
    if (scanData==nil)
    {
        if ([advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey])
        {
            if ([name isEqualToString:@"Ozner Cup"])
            {
                scanData=[[ScanData alloc] init:@"CP001" platform:@"C01" advertisement:[advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey]];
            }
        }else
            return ;
        
    }
    
    if (scanData)
    {
        NSString* identifier=[self getIdentifier:peripheral];
        
        if (![name isEqualToString:@"Ozner Cup"]) {
            
            if ([advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey])
            {
                NSData* data=[advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
                
                BytePtr bytes=(BytePtr)[data bytes];
                identifier =[NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                             bytes[7],bytes[6],bytes[5],bytes[4],bytes[3],bytes[2]];
                //NSString* address=[
            }
        }
        
        BluetoothIO* io=(BluetoothIO*)[self getAvailableDevice:identifier];
        if (!io)
        {
            io=[[BluetoothIO alloc] initWithPeripheral:peripheral Address:identifier CentralManager:centralManager BluetoothData:scanData];
            @synchronized(addressList) {
                //设置mac和identifier uuid对应关系
                [addressList setObject:[NSString stringWithString:io.identifier] forKey:[peripheral.identifier UUIDString]];
            }
            io.name=peripheral.name;
        }
        
        [io updateScarnResponse:scanData.scanResponesType Data:scanData.scanResponesData];
        [self doAvailable:io];
    }
    
}



-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    BluetoothIO* io=(BluetoothIO*)[self getAvailableDevice:[self getIdentifier:peripheral]];
    NSLog(@"didConnectPeripheral:%@",io.identifier);
    [io updateConnectStatus:Connecting];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral:%@",[error debugDescription]);
    BluetoothIO* io=(BluetoothIO*)[self getAvailableDevice:[self getIdentifier:peripheral]];
    [io updateConnectStatus:Disconnect];
    [self doUnavailable:io];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral:%@",[error debugDescription]);
    BluetoothIO* io=(BluetoothIO*)[self getAvailableDevice:[self getIdentifier:peripheral]];
    [io updateConnectStatus:Disconnect];
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManpagerDidUpdateState Status:%d",(int)central.state);
    switch ([central state]) {
        case CBCentralManagerStatePoweredOn:
            if (!scanThread)
            {
                bleScaning=false;
                scanThread=[[NSThread alloc] initWithTarget:self selector:@selector(scanThreadProc) object:nil];
                [scanThread start];
            }
            break;
            
        case CBCentralManagerStatePoweredOff:
            if (scanThread)
            {
                [scanThread cancel];
                scanThread=nil;
            }
            break;
            
        case CBCentralManagerStateUnauthorized:
            break;
        case CBCentralManagerStateUnsupported:
            break;
        default:
            break;
    }
}

@end
