//
//  ZLScrollTitleViewController.m
//  ZLPlayNews
//
//  Created by hezhonglin on 16/10/27.
//  Copyright © 2016年 TsinHzl. All rights reserved.
//

#import "ZLScrollTitleViewController.h"
#import "UIScrollView+ZLGestureConflict.h"

#pragma mark - 宏定义

#define ZLSColorWithRGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

#define kZLNavBarHeight (ZLScreenHeight >= 812.f ? 88.f : 64.f)

#define ZLSScreenW [UIScreen mainScreen].bounds.size.width
#define ZLSScreenH [UIScreen mainScreen].bounds.size.height
#define ZLSScreenB [UIScreen mainScreen].bounds

#define ZLTitleFont [UIFont systemFontOfSize:15.0]
#define ZLTitleSelectedFont [UIFont systemFontOfSize:18.0]
//#define ZLNavTextColor ZLSColorWithRGB(231.0,50.0,80.0)

static CGFloat const ZLTitleViewHeight = 40.0f;
static CGFloat const ZLAnimtionTimeInterval = 0.2f;
static CGFloat const ZLIndicatorViewHeight = 1.5f;

@interface ZLScrollTitleViewController()<UIScrollViewDelegate>

@property(nonatomic, strong)UIScrollView *titleView;
@property(nonatomic, strong)UIButton *selectedButton;
@property(nonatomic, weak)UIScrollView *contentView;
@property(nonatomic, weak)UIView *indicatorView;

/* title选中文字大小 */
@property(nonatomic, strong)UIFont *titleSelectedFont;
/* title文字大小 */
@property(nonatomic, strong)UIFont *titleFont;
/* titleView两个button之间的中心距离 */
@property (assign, nonatomic) CGFloat buttonCenterDistance;
/* 上次scrollView的contentOffsetX */
@property (assign, nonatomic) CGFloat lastContentOffsetX;
/* indicatorViewW */
@property (assign, nonatomic) CGFloat indicatorViewW;

@end

@implementation ZLScrollTitleViewController

#pragma mark - 外部属性设置

- (void)setIsChangeSelectedTitleFont:(BOOL)isChangeSelectedTitleFont titleFontSize:(CGFloat)fontSize {
    
    self.titleFont = fontSize ? [UIFont systemFontOfSize:fontSize] : ZLTitleFont;
    
    if (isChangeSelectedTitleFont) {
        
        self.titleSelectedFont = fontSize ? [UIFont systemFontOfSize:fontSize + 3] : ZLTitleSelectedFont;
    }else {
        self.titleSelectedFont = self.titleFont;
    }
}



#pragma mark - 懒加载
- (UIScrollView *)titleView {
    if (!_titleView) {
        UIScrollView *titleView = [[UIScrollView alloc] init];
        if (self.titleViewColor) {
            titleView.backgroundColor = self.titleViewColor;
        }else {
            titleView.backgroundColor = [UIColor clearColor];
        }
        titleView.frame = CGRectMake(0, kNavBarH, ZLSScreenW, ZLTitleViewHeight);
        titleView.showsHorizontalScrollIndicator = NO;
        self.titleView = titleView;
    }
    return _titleView;
}

- (NSArray<NSString *> *)titles {
    if (!_titles) {
        self.titles = @[@"test1",@"test2",@"test3",@"test4",@"test5",@"test6",@"test7",@"test8",@"test9"];
    }
    return _titles;
}

- (UIScrollView *)contentView {
    if (!_contentView) {
        UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        self.contentView = contentView;
        contentView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:contentView];
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.pagingEnabled = YES;
        contentView.bounces = NO;
        contentView.delegate = self;
    }
    return _contentView;
}

- (UIFont *)titleFont {
    if (!_titleFont) {
        _titleFont = ZLTitleFont;
    }
    return _titleFont;
}

- (UIFont *)titleSelectedFont {
    if (!_titleSelectedFont) {
        _titleSelectedFont = ZLTitleSelectedFont;
    }
    return _titleSelectedFont;
}
#pragma mark - viewDidLoad初始化方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

#pragma mark - 初始化设置view方法

- (void)setupView {
    
    self.view.backgroundColor = ZLSColorWithRGB(245, 245, 245);
    [self setupTitleView];
    self.contentView.contentSize = CGSizeMake(ZLSScreenW*self.titles.count, 0);
    
    NSInteger count = self.childViewControllers.count;
    for (NSInteger i = 0; i < count; i++) {
        UIViewController *vc = (UIViewController *)self.childViewControllers[i];
        [self addChildViewController:vc];
    }
    [self.view bringSubviewToFront:self.titleView];
}

/** 设置indicatorview **/

- (void)setupIndicatorView {
    UIView *indicatorView = [[UIView alloc] init];
    self.indicatorView = indicatorView;
    indicatorView.backgroundColor = self.titleSelectedColor;
    indicatorView.frame = CGRectMake(0, self.titleView.zl_height - ZLIndicatorViewHeight, 15.f, ZLIndicatorViewHeight);
    [self.titleView addSubview:indicatorView];
    
}

/** 设置titleview **/

- (void)setupTitleView {
    if (!self.titleColor) {
        self.titleColor = [UIColor whiteColor];
    }
    if (!self.titleSelectedColor) {
        self.titleSelectedColor = ZLNavTextColor;
    }
    
    [self.view addSubview:self.titleView];
    
    [self setupIndicatorView];
    
    NSInteger count = self.titles.count;
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = ZLSScreenW/(count>4 ? 5 : count);
    CGFloat btnH = self.titleView.zl_height;
    self.buttonCenterDistance = btnW;
    self.lastContentOffsetX = 0;
    if (count > 5) {
        self.titleView.contentSize = CGSizeMake(btnW * count, 0);
    }
    
    //添加titleButton
    for (NSInteger i = 0; i < count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn setTitle:self.titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:self.titleColor forState:UIControlStateNormal];
        [btn setTitleColor:self.titleSelectedColor forState:UIControlStateDisabled];
        btnX = i*btnW;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        btn.titleLabel.font = self.titleFont;
        [self.titleView addSubview:btn];
        [btn addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.showsTouchWhenHighlighted = YES;
        if (0 == i) {
            self.selectedButton = btn;
            self.selectedButton.enabled = NO;
            self.selectedButton.titleLabel.font = self.titleSelectedFont;
            
            [self.selectedButton.titleLabel sizeToFit];
            self.indicatorView.zl_width = self.selectedButton.titleLabel.zl_width;
            self.indicatorViewW = self.indicatorView.zl_width;
            self.indicatorView.zl_centerX = self.selectedButton.zl_centerX;
            
        }
    }
    [self scrollViewDidEndScrollingAnimation:self.contentView];
}

/** titleBuuton点击事件 **/
- (void)titleButtonClicked:(UIButton *)btn {
    self.selectedButton.enabled = YES;
    self.selectedButton.titleLabel.font = self.titleFont;
    self.selectedButton = btn;
    self.selectedButton.enabled = NO;
    self.selectedButton.titleLabel.font = self.titleSelectedFont;
    [self.selectedButton.titleLabel sizeToFit];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:ZLAnimtionTimeInterval animations:^{
//        weakSelf.indicatorView.zl_width = weakSelf.selectedButton.titleLabel.zl_width;
//        weakSelf.indicatorView.zl_centerX = weakSelf.selectedButton.zl_centerX;
        
        CGPoint contentOffset = weakSelf.contentView.contentOffset;
        contentOffset.x = btn.tag*ZLSScreenW;
        [weakSelf.contentView setContentOffset:contentOffset animated:YES];
        [weakSelf scrollViewDidEndScrollingAnimation:weakSelf.contentView];
        [weakSelf setTitleViewContentOffsetWithButton:btn];
    } completion:^(BOOL finished) {
        
    }];
}

//
- (void)setTitleViewContentOffsetWithButton:(UIButton *)button {
    if (self.titles.count < 6) return;
    CGPoint offset = self.titleView.contentOffset;
    offset.x = button.zl_x - 2*button.zl_width;
    if (offset.x < 0) {
        offset.x = 0;
    }
    if (offset.x > self.titleView.contentSize.width - self.titleView.zl_width) {
        offset.x = self.titleView.contentSize.width - self.titleView.zl_width;
    }
    [self.titleView setContentOffset:offset];
}

#pragma mark - 外部方法


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    ZLLog(@"+++scrollViewDidScroll+++");
    ZLLog(@"contentOffsetX = %f",scrollView.contentOffset.x);
    
//    NSString *string = [NSString stringWithFormat:@"%f",scrollView.contentOffset.x/ZLSScreenW];
//    string = [[string componentsSeparatedByString:@"."] lastObject];
//    string = [NSString stringWithFormat:@"0.%@",string];
//    CGFloat rate = string.floatValue;
//    if (rate > 0.5) {
//        rate = 1.f - 0.5f;
//    }
//    self.indicatorView.zl_width = self.indicatorViewW*(1.f + rate);
    
    self.indicatorView.zl_centerX += self.buttonCenterDistance*((scrollView.contentOffset.x - self.lastContentOffsetX)/ZLSScreenW);
//    if (scrollView.contentOffset.x - self.lastContentOffsetX < 0) {
//        self.indicatorView.zl_centerX -= self.indicatorViewW*rate/2.f;
//    }
    
    self.lastContentOffsetX = scrollView.contentOffset.x;
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    ZLLog(@"+++scrollViewDidEndDecelerating+++");
    ZLLog(@"+++offset++%@",NSStringFromCGPoint(scrollView.contentOffset));
    //前两个view不是button所以要加2
    __block NSInteger count = (scrollView.contentOffset.x)/self.view.zl_width;
    count += 1;
    ZLLog(@"+++++%@",self.titleView.subviews);
    UIButton *btn = (UIButton *)self.titleView.subviews[count];
    [self titleButtonClicked:btn];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    ZLLog(@"---scrollViewDidEndScrollingAnimation---");
    /**
     *  设置滑动到的那个view的frame以及contentInset
     */
    NSInteger index = scrollView.contentOffset.x/ZLSScreenW;
    
    CGFloat top = 0;
    CGFloat bottom = 0;
    //self.tabBarController.tabBar.zl_height;
    
    if ([self.childViewControllers[index] isKindOfClass:[UITableViewController class]]) {
        UITableViewController *vc = self.childViewControllers[index];
        
        //设置滚动条的inset
        vc.tableView.scrollIndicatorInsets = vc.tableView.contentInset;
        
        vc.tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
        
        CGRect f = CGRectMake(scrollView.contentOffset.x, 0, ZLSScreenW, ZLSScreenH - kZLNavBarHeight - self.titleView.zl_height);
        vc.view.frame = f;
        [scrollView addSubview:vc.view];
    }else if ([self.childViewControllers[index] isKindOfClass:[UICollectionViewController class]]) {
        UICollectionViewController *vc = (UICollectionViewController *)self.childViewControllers[index];
        
        //设置滚动条的inset
        vc.collectionView.scrollIndicatorInsets = vc.collectionView.contentInset;
        
        vc.collectionView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
        
        vc.view.frame = CGRectMake(scrollView.contentOffset.x, 0, ZLSScreenW, ZLSScreenH - kZLNavBarHeight);
        [scrollView addSubview:vc.view];
    }else {
        UIViewController *vc = self.childViewControllers[index];
        CGRect f = CGRectMake(scrollView.contentOffset.x, self.titleView.zl_height, ZLSScreenW, ZLSScreenH - kZLNavBarHeight - self.titleView.zl_height);
        vc.view.frame = f;
        [scrollView addSubview:vc.view];
    }
    
    ZLLog(@"---childVCs---%@",self.childViewControllers);
}

@end
