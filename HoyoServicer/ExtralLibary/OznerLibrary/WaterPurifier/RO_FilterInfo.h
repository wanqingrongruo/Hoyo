//
//  RO_FilterInfo.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 2016/10/25.
//  Copyright © 2016年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RO_FilterInfo : NSObject
@property (readonly) int Filter_A_Time;
@property (readonly) int Filter_B_Time;
@property (readonly) int Filter_C_Time;

@property (readonly) int Filter_A_Percentage;
@property (readonly) int Filter_B_Percentage;
@property (readonly) int Filter_C_Percentage;
-(void)load:(NSData*)data;
-(void)reset;
@end
