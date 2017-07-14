//
//  MySQLLite.h
//  cups
//
//  Created by Zhiyongxu on 14-9-18.
//  Copyright (c) 2014年 Zhiyongxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface SqlLiteDB : NSObject
{
    sqlite3* db;
}
-(id)init:(NSString*)DBName Version:(int)Version;
-(NSArray*) ExecSQL:(NSString*)SQL params:(NSArray*)param;
-(NSString*) ExecSQLOneRet:(NSString*)SQL params:(NSArray*)param;
-(BOOL) ExecSQLNonQuery:(NSString*)SQL params:(NSArray*)param;

@end
