//
//  TapFirmware.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/2.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "CupFirmware.h"

@implementation CupFirmware
-(int)hexToint:(NSString*)str
{
    int nValude = 0;
    sscanf([[str dataUsingEncoding:NSASCIIStringEncoding] bytes],"%x",&nValude);
    return nValude;
}
-(void)load
{
    firmware=nil;
    NSFileManager *fm=[NSFileManager defaultManager];
    if (![fm fileExistsAtPath:firmwareFile])
    {
        [self.delegate firmwareUpdateDidFailure];
    }
    
    NSData* file=[NSData dataWithContentsOfFile:firmwareFile];
    Byte key[]={0x23, 0x23, 0x24, 0x24, 0x40, 0x40, 0x2a, 0x2a, 0x54, 0x61, 0x70, 0x00};
    int Size=(int)file.length;
    
    if (Size > 31 * 1024) Size = 31 * 1024;
    
    if ((Size % 128) != 0) {
        Size = (Size / 128) * 128 + 128;
    }
    
    Byte* bytes = alloca(Size);
    @try {
        memset(bytes, 0, Size);
        memcpy(bytes, [file bytes], file.length);
        
        int v_pos = 0;
        int myLoc1 = 0;
        int myLoc2 = 0;
        BOOL ver = false;

        for (int i = 0; i < Size - sizeof(key); i++) {
            ver = false;
            for (int x = 0; x < sizeof(key); x++) {
                if (key[x] == bytes[i + x]) {
                    ver = true;
                } else {
                    ver = false;
                    break;
                }
            }
            if (ver) {
                v_pos = i;
                break;
            }
        }

        for (int i = 0; i < Size - 6; i++) {
            if ((bytes[i] == 0x12) && (bytes[i + 1] == 0x34) && (bytes[i + 2] == 0x56)
                && (bytes[i + 3] == 0x65) && (bytes[i + 4] == 0x43) && (bytes[i + 5] == 0x21)) {
                if (myLoc1 == 0)
                    myLoc1 = i;
                else
                    myLoc2 = i;
            }
        }
        
        if (!ver) {
            @throw [NSException exceptionWithName:@"Firmware Exception" reason:@"文件错误" userInfo:nil];
        } else {
            int ver_pos = *((int*)(bytes+v_pos+16));
            if ((ver_pos < 0) || (ver_pos > Size))
                @throw [NSException exceptionWithName:@"Firmware Exception" reason:@"文件错误" userInfo:nil];
            
            int day_pos = *((int*)(bytes+v_pos+20));
            if ((day_pos < 0) || (day_pos > Size))
                @throw [NSException exceptionWithName:@"Firmware Exception" reason:@"文件错误" userInfo:nil];
            
            int time_pos = *((int*)(bytes+v_pos+24));
            if ((time_pos < 0) || (time_pos > Size))
                @throw [NSException exceptionWithName:@"Firmware Exception" reason:@"文件错误" userInfo:nil];
            NSString* verS=[[NSString alloc] initWithBytes:bytes+ver_pos length:3 encoding:NSASCIIStringEncoding];
            NSString* dayS=[[NSString alloc] initWithBytes:bytes+day_pos length:11 encoding:NSASCIIStringEncoding];
            NSString* timeS=[[NSString alloc] initWithBytes:bytes+time_pos length:8 encoding:NSASCIIStringEncoding];

            
            if ([verS isEqualToString:@""])
                @throw [NSException exceptionWithName:@"Firmware Exception" reason:@"文件错误" userInfo:nil];
            if ([dayS isEqualToString:@""])
                @throw [NSException exceptionWithName:@"Firmware Exception" reason:@"文件错误" userInfo:nil];
            if ([timeS isEqualToString:@""])
                @throw [NSException exceptionWithName:@"Firmware Exception" reason:@"文件错误" userInfo:nil];
            
            Platform=[NSString stringWithString:[verS substringWithRange:NSMakeRange(0, 3)]];
            if (!([Platform isEqualToString:@"T01"] ||
                  [Platform isEqualToString:@"T02"] ||
                  [Platform isEqualToString:@"T03"]))
            {
                @throw [NSException exceptionWithName:@"Firmware Exception" reason:@"文件错误" userInfo:nil];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
            [formatter setDateFormat:@"MMM dd yyyy HH:mm:ss"];
            NSString* t=[NSString stringWithFormat:@"%@ %@",dayS,timeS];
            Version=[formatter dateFromString:t];
        }
        if (myLoc1!=0)
        {
            bytes[myLoc1 + 5] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(0, 2)]];
            bytes[myLoc1 + 4] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(3, 2)]];
            bytes[myLoc1 + 3] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(6, 2)]];
            bytes[myLoc1 + 2] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(9, 2)]];
            bytes[myLoc1 + 1] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(12, 2)]];
            bytes[myLoc1] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(15, 2)]];
        }
        if (myLoc2 != 0) {
            bytes[myLoc2 + 5] = bytes[myLoc1];
            bytes[myLoc2 + 4] = bytes[myLoc1 + 1];
            bytes[myLoc2 + 3] = bytes[myLoc1 + 2];
            bytes[myLoc2 + 2] = bytes[myLoc1 + 3];
            bytes[myLoc2 + 1] = bytes[myLoc1 + 4];
            bytes[myLoc2] = bytes[myLoc1 + 5];
        }
        long temp = 0;
        frimwareCheckSum= 0;
        int len = Size / 4;
        for (int i = 0; i < len; i++) {
            temp += *((UInt32*)bytes+i*4);
        }
        long TempMask = 0x1FFFFFFFFL-0x100000000L;
        frimwareCheckSum = (int) (temp & TempMask);
        self->firmware=[NSData dataWithBytes:bytes length:Size];
    }
    @finally {
        free(bytes);
    }
}
#define  opCode_GetFirmwareSum  0xc5
#define  opCode_GetFirmwareSumRet  0xc5

-(void)run
{
    @try {
        [self.delegate firmwareUpdateDidStart];
        [self load];
        if (!firmware)
        {
            [self.delegate firmwareUpdateDidFailure];
            return;
        }
        if (firmware.length > 31 * 1024) {
            [self.delegate firmwareUpdateDidFailure];
            return;
        }
        if ([Version isEqualToDate:bluetooth.firmwareVersion]) {
            [self.delegate firmwareUpdateDidFailure];
            return;
        }
        BytePtr bytes=(BytePtr)[firmware bytes];
        Byte buffer[20];
        buffer[0]=0x89;
        memset(buffer, 0, sizeof(buffer));
        for (int i = 0; i < firmware.length; i += 8) {
            int p = i + 0x17c00;
            *((int*)buffer+1)=p;
            memcpy(buffer+5, bytes, 8);
            NSData* data=[NSData dataWithBytesNoCopy:buffer length:20];
            if (![bluetooth send:data])
            {
                [self.delegate firmwareUpdateDidFailure];
                return;
            }else
            {
                [self.delegate firmwareUpdatePostion:i Size:(int)firmware.length];
            }
        }
        sleep(1);
        Byte checkSumBuffer[5];
        checkSumBuffer[0] = opCode_GetFirmwareSum;
        *((int*)checkSumBuffer+1)=(int)firmware.length;
        
        if ([bluetooth send:[NSData dataWithBytesNoCopy:checkSumBuffer length:sizeof(checkSumBuffer)]])
        {
            sleep(0.2f);
            NSData* lastPack=[bluetooth lastRecvPacket];
            if(!lastPack)
            {
                [self.delegate firmwareUpdateDidFailure];
                return;
            }
            BytePtr bytes=(BytePtr)[lastPack bytes];
            if (*bytes==opCode_GetFirmwareSumRet)
            {
                UInt32 checksum=*((UInt32*)bytes);
                if (checksum==frimwareCheckSum)
                {
                    Byte update[5];
                    update[0]=0xc3;
                    *((int*)update+1)=(int)firmware.length;
                    if ([bluetooth send:[NSData dataWithBytesNoCopy:update length:sizeof(update)]])
                    {
                        [self.delegate firmwareUpdateDidComplete];
                    }else
                        [self.delegate firmwareUpdateDidFailure];
                }else
                {
                    [self.delegate firmwareUpdateDidFailure];
                    return;
                }
            }else
            {
                [self.delegate firmwareUpdateDidFailure];
                return;
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"firmware:%@",[exception debugDescription]);
        [self.delegate firmwareUpdateDidFailure];
    }
    @finally {
        
    }
}



@end
