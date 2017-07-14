//
//  OznerDevice.hpp
//  MxChip
//
//  Created by Zhiyongxu on 15/12/4.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//


@interface OznerDevice ()
-(void)doSensorUpdate;
-(void)doStatusUpdate;
-(void)doSetDeviceIO:(BaseDeviceIO *)oldio NewIO:(BaseDeviceIO *)newio;
@end
