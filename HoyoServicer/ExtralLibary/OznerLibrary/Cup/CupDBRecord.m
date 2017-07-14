//
//  DBRecord.m
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/12.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import "CupDBRecord.h"

@implementation CupDBRecord

-(instancetype)initWithArray:(NSArray*)array
{
    if (self=[super init])
    {
        _time=[[NSDate alloc] initWithTimeIntervalSince1970: [[array objectAtIndex:0] intValue]];
        _tds=[[array objectAtIndex:1] intValue];
        _volume=[[array objectAtIndex:2] intValue];
        _temperature=[[array objectAtIndex:3] intValue];
        _updated=[[array objectAtIndex:4] boolValue];
    }
    return self;
}


@end
