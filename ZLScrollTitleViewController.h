//
//  ZLScrollTitleViewController.h
//  ZLPlayNews
//
//  Created by hezhonglin on 16/10/27.
//  Copyright © 2016年 TsinHzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLScrollTitleViewController : UIViewController

/** titlebutton的title */
@property(nonatomic, strong)NSArray<NSString *> *titles;
/** titlebutton的文字的颜色 */
@property(nonatomic, strong)UIColor *titleColor;
/** 选中的button的文字颜色 */
@property(nonatomic, strong)UIColor *titleSelectedColor;
/** 子控制器 */
@property(nonatomic, strong)NSArray *childViewControllers;
/* titleviewColor */
@property(nonatomic, strong)UIColor *titleViewColor;

/* 是否改变选中title的文字大小以及title的文字大小，如果不想改变非选中文字大小， titleFontSize 请传入0 */
- (void)setIsChangeSelectedTitleFont:(BOOL)isChangeSelectedTitleFont titleFontSize:(CGFloat)fontSize;

@end
