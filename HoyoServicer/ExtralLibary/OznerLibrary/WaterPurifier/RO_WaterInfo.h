//
//  RO_WaterInfo.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 2016/10/25.
//  Copyright © 2016年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RO_WaterInfo : NSObject
@property (readonly) int TDS1;
@property (readonly)  int TDS2;
@property (readonly)  int TDS1_RAW;
@property (readonly)  int TDS2_RAW;
@property (readonly)  int TDS_Temperature;

-(void)load:(NSData*)data;
-(void)reset;
@end
