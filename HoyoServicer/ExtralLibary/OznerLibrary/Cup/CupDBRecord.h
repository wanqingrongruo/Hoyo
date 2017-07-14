//
//  DBRecord.h
//  OznerLibraryDemo
//
//  Created by Zhiyongxu on 15/12/12.
//  Copyright © 2015年 Ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface CupDBRecord : NSObject
{
}
@property (copy) NSDate* time;
@property (nonatomic) int tds;
@property (nonatomic) int volume;
@property (nonatomic) int temperature;
@property (nonatomic) BOOL updated;
-(instancetype)initWithArray:(NSArray*)array;
@end
