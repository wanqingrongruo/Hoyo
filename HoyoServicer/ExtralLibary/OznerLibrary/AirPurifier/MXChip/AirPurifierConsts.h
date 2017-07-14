//
//  AirPurifierConsts.h
//  MxChip
//
//  Created by Zhiyongxu on 15/12/9.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#ifndef AirPurifierConsts_h
#define AirPurifierConsts_h
#define CMD_SET_PROPERTY 0x2
#define CMD_REQUEST_PROPERTY 0x1
#define CMD_RECV_PROPERTY 0x4


#define PROPERTY_POWER   0x00
#define PROPERTY_SPEED   0x01
#define PROPERTY_LIGHT   0x02
#define PROPERTY_LOCK   0x03
#define PROPERTY_POWER_TIMER   0x04
#define PROPERTY_PM25   0x11
#define PROPERTY_TEMPERATURE   0x12
#define PROPERTY_VOC   0x13
#define PROPERTY_LIGHT_SENSOR   0x14
#define PROPERTY_HUMIDITY   0x18

#define PROPERTY_TOTAL_CLEAN 0x19
#define PROPERTY_WIFI 0x1a

#define PROPERTY_FILTER   0x15
#define PROPERTY_TIME   0x16
#define PROPERTY_PERIOD 0x17

#define PROPERTY_MODEL   0x21

#define PROPERTY_DEVICE_TYPE   0x22
#define PROPERTY_MAIN_BOARD   0x23
#define PROPERTY_CONTROL_BOARD   0x24
#define PROPERTY_MESSAGES   0x25
#define PROPERTY_VERSION   0x26

#endif /* AirPurifierConsts_h */
