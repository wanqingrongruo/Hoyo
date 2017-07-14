//
//  CupGravity.m
//  OznerCup
//
//  Created by Zhiyongxu on 14/12/4.
//  Copyright (c) 2014年 Zhiyongxu. All rights reserved.
//

#import "CupGravity.h"

@implementation CupGravity
-(id)initWithData:(NSData*) data;
{
    if (self=[super init])
    {
        lpGravity gravity=(lpGravity)[data bytes];
        int tx = gravity->x;
        if (tx > 16384)
            tx = 16384;
        if (tx < -16384)
            tx = -16384;
        int ty = gravity->y;
        if (ty > 16384)
            ty = 16384;
        if (ty < -16384)
            ty = -16384;
        int tz = gravity->z;
        if (tz > 16384)
            tz = 16384;
        if (tz < -16384)
            tz = -16384;
        self->_x = (float) (asin(tx / 16384.0) * 180 / M_PI);
        self->_y = (float) (asin(ty / 16384.0) * 180 / M_PI);
        self->_z = (float) (acos(tz / 16384.0) * 180 / M_PI);
    }
    return self;
}
-(BOOL)IsHandstand
{
    return (_z >= 150 && _z <= 190);
}
@end
