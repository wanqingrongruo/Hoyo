//
//  OznerBlueManager.m
//  TestAnmial
//
//  Created by 赵兵 on 2016/10/24.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

#import "OznerBlueManager.h"
#define channelOnPeropheralView @"peripheralView"
#define channelOnCharacteristicView @"CharacteristicView"
@implementation OznerBlueManager


//单例模式
OznerBlueManager* blueManager=nil;
+(instancetype)instance
{
    if (!blueManager)
    {
        blueManager=[[OznerBlueManager alloc] init];
    }
    return blueManager;
}
- (instancetype)init {
    
    if (self = [super init]) {
        
        //初始化BabyBluetooth 蓝牙库
        baby = [BabyBluetooth shareBabyBluetooth];
        //设置蓝牙委托
        [self babyDelegate];
        blueManager=self;
        //timer=[NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(timerTask) userInfo:nil repeats:NO];
    }
    return self;
    
}

+(instancetype)shareInstance{
    if (!blueManager)
    {
        blueManager=[[OznerBlueManager alloc] initY];
    }
    return blueManager;
}

- (instancetype)initY {
    
    if (self = [super init]) {
        
        //初始化BabyBluetooth 蓝牙库
        baby = [BabyBluetooth shareBabyBluetooth];
        blueManager=self;
        //timer=[NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(timerTask) userInfo:nil repeats:NO];
    }
    return self;
    
}

NSTimer *timer;

NSArray* filterData;
bool writeSuccess=false;
-(void)CommitData:(NSArray*)filter callBack: (OperateCallback)call{
    filterData=filter;
    callBack=call;
    callBack([[NSError alloc] initWithDomain:@"开始扫描设备" code:1 userInfo:nil]);
    writeSuccess=false;
    //停止之前的连接
    [baby cancelAllPeripheralsConnection];
    //停止之前的定时任务
    [self cancelTimerTask];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.scanForPeripherals().begin().stop(10);
    //启动一个定时任务
    timer=[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerTask) userInfo:nil repeats:NO];
    
    
}

- (void)disConnectCurrentLink{
    //停止之前的连接
    [baby cancelAllPeripheralsConnection];

}


-(void)timerTask{
        callBack([[NSError alloc] initWithDomain:@"连接设备超时，请检查设备连接状态后重试" code:-1 userInfo:nil]);
}
-(void)cancelTimerTask{
    if (timer.isValid) {
        [timer invalidate];
    }
    timer=nil;
}


-(void)linkBluetoothWithCallBack: (OperateCallback)call {
    
    callBack=call;
    callBack([[NSError alloc] initWithDomain:@"开始扫描设备" code:1 userInfo:nil]);
    //停止之前的连接
    [baby cancelAllPeripheralsConnection];
    //停止之前的定时任务
    [self cancelTimerTask];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.scanForPeripherals().begin().stop(10);
    //启动一个定时任务
    timer=[NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(timerTask) userInfo:nil repeats:NO];
}


#pragma mark -蓝牙配置和操作

//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    __strong typeof(self) strongSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state != CBCentralManagerStatePoweredOn) {
            strongSelf->callBack([[NSError alloc] initWithDomain:@"手机蓝牙未打开" code:-2 userInfo:nil]);
        }else{
            strongSelf->callBack([[NSError alloc] initWithDomain:@"手机蓝牙已打开" code:2 userInfo:nil]);
        }
    }];
    
   
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        
        //停止扫描
        [strongSelf->baby cancelScan];
        strongSelf->callBack([[NSError alloc] initWithDomain:@"搜索到了设备，开始连接设备" code:3 userInfo:nil]);
        strongSelf.currPeripheral=peripheral;
        [strongSelf babyDelegate2];
        [strongSelf performSelector:@selector(connectDevice) withObject:nil afterDelay:2];
        
    }];
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        if ([advertisementData objectForKey:CBAdvertisementDataServiceDataKey])
        {
            NSDictionary* dict=[advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
            CBUUID* uuid=[CBUUID UUIDWithString:@"FFF0"];
            NSData* data=[dict objectForKey:uuid];
            if (data) {
                @try {
                    
                    NSString* model=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    
                    // WG-001
                    if ([model containsString:@"WG-001"]) {
                        return YES;
                    }
                }
                @catch (NSException *exception) {
                    
                }
            }
        }
        return NO;
        
    }];
    //222222222222
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        
        strongSelf->callBack([[NSError alloc] initWithDomain:@"设备连接成功" code:3 userInfo:nil]);
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        strongSelf->callBack([[NSError alloc] initWithDomain:@"设备连接失败" code:-3 userInfo:nil]);
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        strongSelf->callBack([[NSError alloc] initWithDomain:@"设备断开连接" code:-4 userInfo:nil]);
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        for (CBCharacteristic* characteristic in service.characteristics)
        {
            if ([[[characteristic UUID] UUIDString] isEqualToString:@"FFF2"])
            {
                
                
                strongSelf.characteristic=characteristic;
                
                //读取服务
                strongSelf->baby.channel(channelOnCharacteristicView).characteristicDetails(strongSelf.currPeripheral,strongSelf.characteristic);
                [NSTimer scheduledTimerWithTimeInterval:1 target:strongSelf selector:@selector(writeData) userInfo:nil repeats:NO];
                
                
            }
            if ([[[characteristic UUID] UUIDString] isEqualToString:@"FFF1"])
            {
                
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
        
        
    }];
    //3333333333333
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        
        [weakSelf loadData:characteristics.value];
        
        
    }];
    
    
    
    //设置写数据成功的block
    
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
        if (!writeSuccess) {
            strongSelf->callBack([[NSError alloc] initWithDomain:@"写数据成功" code:5 userInfo:nil]);
            writeSuccess=true;
            [strongSelf cancelTimerTask];//取消以前的定时任务
        }
        
    }];
    
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    
}


//蓝牙网关初始化和委托方法设置
-(void)newBabyDelegate{
    
    __weak typeof(self) weakSelf = self;
    __strong typeof(self) strongSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state != CBCentralManagerStatePoweredOn) {
            strongSelf->callBack([[NSError alloc] initWithDomain:@"手机蓝牙未打开" code:-2 userInfo:nil]);
        }else{
            strongSelf->callBack([[NSError alloc] initWithDomain:@"手机蓝牙已打开" code:2 userInfo:nil]);
        }
    }];
    
    
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        
        //停止扫描
        [strongSelf->baby cancelScan];
        strongSelf->callBack([[NSError alloc] initWithDomain:@"搜索到了设备，开始连接设备" code:3 userInfo:nil]);
        strongSelf.currPeripheral=peripheral;
        [strongSelf babyDelegate2];
        [strongSelf performSelector:@selector(connectDevice) withObject:nil afterDelay:2];
        
    }];
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        if ([advertisementData objectForKey:CBAdvertisementDataServiceDataKey])
        {
            NSDictionary* dict=[advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
            CBUUID* uuid=[CBUUID UUIDWithString:@"FFF0"];
            NSData* data=[dict objectForKey:uuid];
            if (data) {
                @try {
                    
                    NSString* model=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    
                    // WG-001
//                    if ([model containsString:@"Ozner RO"]) {
//                        return YES;
//                    }
                }
                @catch (NSException *exception) {
                    
                }
            }
        }
        return NO;
        
    }];
    //222222222222
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        
        strongSelf->callBack([[NSError alloc] initWithDomain:@"设备连接成功" code:3 userInfo:nil]);
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        strongSelf->callBack([[NSError alloc] initWithDomain:@"设备连接失败" code:-3 userInfo:nil]);
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        strongSelf->callBack([[NSError alloc] initWithDomain:@"设备断开连接" code:-4 userInfo:nil]);
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        for (CBCharacteristic* characteristic in service.characteristics)
        {
            if ([[[characteristic UUID] UUIDString] isEqualToString:@"FFF2"])
            {
                
                
                strongSelf.characteristic=characteristic;
                
                //读取服务
                strongSelf->baby.channel(channelOnCharacteristicView).characteristicDetails(strongSelf.currPeripheral,strongSelf.characteristic);
                [NSTimer scheduledTimerWithTimeInterval:1 target:strongSelf selector:@selector(writeData) userInfo:nil repeats:NO];
                
                
            }
            if ([[[characteristic UUID] UUIDString] isEqualToString:@"FFF1"])
            {
                
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
        
        
    }];
    //3333333333333
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        
        [weakSelf loadData:characteristics.value];
        
        
    }];
    
    
    
//    //设置写数据成功的block
//    
//    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
//        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
//        if (!writeSuccess) {
//            strongSelf->callBack([[NSError alloc] initWithDomain:@"写数据成功" code:5 userInfo:nil]);
//            writeSuccess=true;
//            [strongSelf cancelTimerTask];//取消以前的定时任务
//        }
//        
//    }];
    
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    
}




//开始的
//2

//babyDelegate
-(void)babyDelegate2{
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
}


-(void)connectDevice{
    
    baby.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    
}
//3
//临时
-(void)writeData{
    //[self requestSenior];
    //[self requestFilter];
    
    for (int i=0; i<filterData.count; i++) {
        
        [self writeFilter:[filterData objectAtIndex:i]];
        sleep(0.5f);
        [self requestFilter:i];
    }
    
    
    
}
//读滤芯
-(void)requestFilter:(int)index{
    Byte bytes[2];
    bytes[0]=0x11;
    bytes[1]=index;
    NSData* timeData=[NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    [self.currPeripheral writeValue:timeData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}
//读传感器
-(void)requestSenior{
    Byte bytes[1];
    bytes[0]=0x10;
    NSData* timeData=[NSData dataWithBytes:bytes length:1];
    [self.currPeripheral writeValue:timeData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}
//写滤芯
-(void)writeFilter:(NSDictionary*)dic{
    Byte bytes[19];
    bytes[0]=0x12;
    bytes[1]=[[dic objectForKey:@"index"] intValue];//滤芯index
    bytes[2]=0;
    long time=[[dic objectForKey:@"time"] longLongValue];
    bytes[3] = (Byte) (time & 0x000000FF >> 0);
    bytes[4] = (Byte) ((time & 0x0000FF00) >> 8);
    bytes[5] = (Byte) ((time & 0x00FF0000) >> 16);
    bytes[6] = (Byte) ((time & 0xFF000000) >> 24);
    int workTime=0;
    bytes[7] = (Byte) (workTime & 0x000000FF >> 0);
    bytes[8] = (Byte) ((workTime & 0x0000FF00) >> 8);
    bytes[9] = (Byte) ((workTime & 0x00FF0000) >> 16);
    bytes[10] = (Byte) ((workTime & 0xFF000000) >> 24);
    int maxTime=[[dic objectForKey:@"maxTime"] intValue];
    bytes[11] = (Byte) (maxTime & 0x000000FF >> 0);
    bytes[12] = (Byte) ((maxTime & 0x0000FF00) >> 8);
    bytes[13] = (Byte) ((maxTime & 0x00FF0000) >> 16);
    bytes[14] = (Byte) ((maxTime & 0xFF000000) >> 24);
    int mlDrink=[[dic objectForKey:@"maxVol"] intValue];
    bytes[15] = (Byte) (mlDrink & 0x000000FF >> 0);
    bytes[16] = (Byte) ((mlDrink & 0x0000FF00) >> 8);
    bytes[17] = (Byte) ((mlDrink & 0x00FF0000) >> 16);
    bytes[18] = (Byte) ((mlDrink & 0xFF000000) >> 24);
    
    NSData* timeData=[NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self.currPeripheral writeValue:timeData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}
//解析数据
-(void)loadData:(NSData*)data{
    if (!data) {
        return;
    }
    BytePtr bytes=(BytePtr)[data bytes];
    switch (bytes[0]) {
        case 0xa0:
            callBack([[NSError alloc] initWithDomain: [[NSString alloc] initWithFormat:@"请求传感器数据成功tds_in_raw:%f,tds_in:%f,tds_out_raw:%f,tds_out:%f,vol:%f", [self getShort:bytes IndexT:1],
                                                       [self getShort:bytes IndexT:3],
                                                       [self getShort:bytes IndexT:5],
                                                       [self getShort:bytes IndexT:7]
                                                       ,[self getShort:bytes IndexT:9]] code:6 userInfo:nil]);
            
            
            break;
        case 0xa1:
            callBack([[NSError alloc] initWithDomain: [[NSString alloc] initWithFormat:@"返回滤芯信息index:%d,rev:%d,time:%d,workTime:%d,maxTime:%d,maxVol:%d",
                                                       bytes[1],
                                                       bytes[2],
                                                       [self getInt:bytes IndexT:3],
                                                       [self getInt:bytes IndexT:7],
                                                       [self getInt:bytes IndexT:11],
                                                       [self getInt:bytes IndexT:15]] code:7 userInfo:nil]);
            break;
        default:
            NSLog(@"返回其他信息");
            break;
    }
}
-(int)getInt:(BytePtr)bytes IndexT:(int)index {
    return (((bytes[index + 3] & 0xff) << 24)
            | ((bytes[index + 2] & 0xff) << 16)
            | ((bytes[index + 1] & 0xff) << 8) | ((bytes[index] & 0xff) << 0));
}
-(double)getShort:(BytePtr)bytes IndexT:(int)index
{
    return (double) (((bytes[index + 1] & 0xFF) << 8) + (bytes[index] & 0xFF));
}

@end
