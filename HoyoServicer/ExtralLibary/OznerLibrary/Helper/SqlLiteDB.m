//
//  MySQLLite.m
//  cups
//
//  Created by Zhiyongxu on 14-9-18.
//  Copyright (c) 2014年 Zhiyongxu. All rights reserved.
//

#import "SqlLiteDB.h"

@implementation SqlLiteDB

-(id)init:(NSString *)DBName Version:(int)Version
{
    if (self=[super init])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documents = [paths objectAtIndex:0];
        NSString *database_path = [documents stringByAppendingPathComponent:DBName];
        if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
            sqlite3_close(db);
            NSLog(@"数据库打开失败");
        }
    }
    return self;
}
-(NSString*) ExecSQLOneRet:(NSString*)SQL params:(NSArray*)param
{
    NSArray* ret=[self ExecSQL:SQL params:param];
    if ([ret count]>0)
    {
        return [[ret objectAtIndex:0] objectAtIndex:0];
    }else
        return NULL;
}

-(NSArray*) ExecSQL:(NSString*)SQL params:(NSArray*)param
{
    sqlite3_stmt *statement;
    NSMutableArray* rets=[[NSMutableArray alloc] init];
    if (sqlite3_prepare_v2(db, [SQL UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if(param)
            for (int i=0;i<[param count];i++)
            {
                NSObject* o=param[i];
                if (o)
                    sqlite3_bind_text(statement, i+1, [[o description] UTF8String], -1, NULL);
                else
                {
                    sqlite3_bind_null(statement, i+1);
                }
            }
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int colCount= sqlite3_column_count(statement);
            NSMutableArray* vals=[[NSMutableArray alloc] init];
            for (int i=0;i<colCount;i++)
            {
                NSString *val=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, i) encoding:NSUTF8StringEncoding];
                [vals addObject:val];
            }
            [rets addObject:vals];
        }
        sqlite3_finalize(statement);
    }
    return rets;
}

-(BOOL) ExecSQLNonQuery:(NSString*)SQL params:(NSArray*)param
{
    char *errorMsg;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [SQL UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if(param)
        for (int i=0;i<[param count];i++)
        {
            NSObject* o=param[i];
            if (o)
                sqlite3_bind_text(statement, i+1, [[o description] UTF8String], -1, NULL);
            else
            {
                sqlite3_bind_null(statement, i+1);
            }
        }
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
             NSLog(@"%s ok.",errorMsg);
        }
        sqlite3_finalize(statement);
        return true;
    }else
    {
        return false;
    }
}

-(void) close
{
    if (db)
    {
        sqlite3_close(db);
        db=NULL;
    }
}

- (void)dealloc
{
    [self close];
}

@end
