//
//  CupGravity.h
//  OznerCup
//
//  Created by Zhiyongxu on 14/12/4.
//  Copyright (c) 2014年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef struct _Gravitv
{
    short x;
    short y;
    short z;
}*lpGravity;
@interface CupGravity : NSObject
-(id)initWithData:(NSData*) data;
@property (readonly) float x;
@property (readonly) float y;
@property (readonly) float z;
-(BOOL) IsHandstand;
@end
