//
//  PopoverView.h
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/23.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PopoverBlock)(NSInteger index);

@interface PopoverView : UIView

// 菜单列表集合
@property (nonatomic, copy) NSArray *menuTitles;

@property (nonatomic, strong) UIColor *tableViewBackgroundColor; // tableView 背景颜色
@property (nonatomic, strong) UIColor *tableViewSeparatorColor; // 分割线颜色
@property (nonatomic, strong) UIColor *cellColor; // cell 背景颜色
@property (nonatomic, strong) UIColor *textLabelColor; // textLabel.textColor

/*!
 *  @author lifution
 *
 *  @brief 显示弹窗
 *
 *  @param aView    箭头指向的控件
 *  @param selected 选择完成回调
 */
- (void)showFromView:(UIView *)aView selected:(PopoverBlock)selected;

// 点击透明层隐藏

- (void)hide ;

@end


@interface PopoverArrow : UIView

@end

@interface PopoverArrow02 : UIView

@end
