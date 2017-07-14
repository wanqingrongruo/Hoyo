//
//  OznerBlueManager.h
//  TestAnmial
//
//  Created by 赵兵 on 2016/10/24.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
typedef void (^OperateCallback)(NSError* error);
@interface OznerBlueManager : NSObject{
//    @public
//    CBCharacteristic* input;
//    CBCharacteristic* output;
    BabyBluetooth *baby;
    OperateCallback  callBack;
}
@property (nonatomic,strong)CBCharacteristic *characteristic;
@property (nonatomic,strong)CBPeripheral *currPeripheral;
/**
 * 单例构造方法
 * @return BabyBluetooth共享实例
 */
+ (instancetype)instance;

+ (instancetype)shareInstance;

-(void)newBabyDelegate;

// 提交数据
-(void)CommitData:(NSArray*)filter callBack: (OperateCallback)call;

-(void)linkBluetoothWithCallBack: (OperateCallback)call;

// 断开蓝牙连接
- (void)disConnectCurrentLink;

@end
