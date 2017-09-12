//
//  ZLScrollTitleViewController.m
//  ZLPlayNews
//
//  Created by hezhonglin on 16/10/27.
//  Copyright © 2016年 TsinHzl. All rights reserved.
//

#import "ZLScrollTitleViewController.h"

#define ZLTitleFont [UIFont fontWithName:ZLPXingKaiFont size:16]
#define ZLTitleSelectedFont [UIFont fontWithName:ZLPXingKaiFont size:20]

static CGFloat const ZLTitleViewHeight = 40.0f;
static CGFloat const ZLAnimtionTimeInterval = 0.2f;
static CGFloat const ZLIndicatorViewHeight = 1.5f;

@interface ZLScrollTitleViewController()<UIScrollViewDelegate>

@property(nonatomic, strong)UIScrollView *titleView;
@property(nonatomic, strong)UIButton *selectedButton;
@property(nonatomic, weak)UIScrollView *contentView;
@property(nonatomic, weak)UIView *indicatorView;
//@property(nonatomic, assign)BOOL isSameWithButton;

@end

@implementation ZLScrollTitleViewController

#pragma mark - 懒加载
- (UIScrollView *)titleView {
    if (!_titleView) {
        UIScrollView *titleView = [[UIScrollView alloc] init];
        if (self.titleViewColor) {
            titleView.backgroundColor = self.titleViewColor;
        }else {
            titleView.backgroundColor = [UIColor clearColor];
        }
        titleView.frame = CGRectMake(0, 0, ZLScreebWidth, ZLTitleViewHeight);
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



#pragma mark - viewDidLoad初始化方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

#pragma mark - 初始化设置view方法

- (void)setupView {
    
    //    self.isSameWithButton = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTitleView];
    self.contentView.contentSize = CGSizeMake(ZLScreebWidth*self.titles.count, 0);
    
    NSInteger count = self.childViewControllers.count;
    for (NSInteger i = 0; i < count; i++) {
        UITableViewController *vc = (UITableViewController *)self.childViewControllers[i];
        [self addChildViewController:vc];
    }
}

/** 设置indicatorview **/

- (void)setupIndicatorView {
    UIView *indicatorView = [[UIView alloc] init];
    self.indicatorView = indicatorView;
    indicatorView.backgroundColor = self.titleSelectedColor;
    indicatorView.frame = CGRectMake(0, self.titleView.zl_height - ZLIndicatorViewHeight, 15, ZLIndicatorViewHeight);
    [self.titleView addSubview:indicatorView];
    
}

/** 设置titleview **/

- (void)setupTitleView {
    if (!self.titleColor) {
        self.titleColor = [UIColor whiteColor];
    }
    if (!self.titleSelectedColor) {
        self.titleSelectedColor = ZLPNavTextColor;
    }
    
    self.navigationItem.titleView = self.titleView;
    
    [self setupIndicatorView];
    
    NSInteger count = self.titles.count;
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = (ZLScreebWidth - 20)/(count>4 ? 5 : count);
    CGFloat btnH = self.titleView.zl_height;
    
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
        btn.titleLabel.font = ZLTitleFont;
        [self.titleView addSubview:btn];
        [btn addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.showsTouchWhenHighlighted = YES;
        if (0 == i) {
            self.selectedButton = btn;
            self.selectedButton.enabled = NO;
            self.selectedButton.titleLabel.font = ZLTitleSelectedFont;
            
            [self.selectedButton.titleLabel sizeToFit];
            self.indicatorView.zl_width = self.selectedButton.titleLabel.zl_width;
            self.indicatorView.zl_centerX = self.selectedButton.zl_centerX;
            
        }
    }
    [self scrollViewDidEndScrollingAnimation:self.contentView];
}

/** titleBuuton点击事件 **/
- (void)titleButtonClicked:(UIButton *)btn {
    self.selectedButton.enabled = YES;
    self.selectedButton.titleLabel.font = ZLTitleFont;
    self.selectedButton = btn;
    self.selectedButton.enabled = NO;
    self.selectedButton.titleLabel.font = ZLTitleSelectedFont;
    [self.selectedButton.titleLabel sizeToFit];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:ZLAnimtionTimeInterval animations:^{
        weakSelf.indicatorView.zl_width = weakSelf.selectedButton.titleLabel.zl_width;
        weakSelf.indicatorView.zl_centerX = weakSelf.selectedButton.zl_centerX;
        
        CGPoint contentOffset = weakSelf.contentView.contentOffset;
        contentOffset.x = btn.tag*ZLScreebWidth;
        [weakSelf.contentView setContentOffset:contentOffset animated:YES];
        [weakSelf scrollViewDidEndScrollingAnimation:weakSelf.contentView];
        [weakSelf setTitleViewContentOffsetWithButton:btn];
    } completion:^(BOOL finished) {
        
    }];
}

//
- (void)setTitleViewContentOffsetWithButton:(UIButton *)button {
    if (self.titles.count < 6) return;
    //设置当前选中的按钮在titleview的最中间位置
    //设置titleView的offset
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    ZLLog(@"+++scrollViewDidEndDecelerating+++");
    ZLLog(@"+++offset++%@",NSStringFromCGPoint(scrollView.contentOffset));
    //前两个view不是button所以要加2
    __block NSInteger count = (scrollView.contentOffset.x)/self.view.zl_width;
    count += 2;
    ZLLog(@"+++++%@",self.titleView.subviews);
    UIButton *btn = (UIButton *)self.titleView.subviews[count];
    [self titleButtonClicked:btn];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    ZLLog(@"---scrollViewDidEndScrollingAnimation---");
    /**
     *  设置滑动到的那个view的frame以及contentInset
     */
    NSInteger index = scrollView.contentOffset.x/ZLScreebWidth;
    
    CGFloat top = 0;
    CGFloat bottom = self.tabBarController.tabBar.zl_height;
    
    if ([self.childViewControllers[index] isKindOfClass:[UITableViewController class]]) {
        UITableViewController *vc = self.childViewControllers[index];
        
        //设置滚动条的inset
        vc.tableView.scrollIndicatorInsets = vc.tableView.contentInset;
        
        vc.tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
        
        vc.view.frame = CGRectMake(scrollView.contentOffset.x, 0, ZLScreebWidth, ZLScreenHeight - 64);
        [scrollView addSubview:vc.view];
    }else if ([self.childViewControllers[index] isKindOfClass:[UICollectionViewController class]]) {
        UICollectionViewController *vc = (UICollectionViewController *)self.childViewControllers[index];
        
        //设置滚动条的inset
        vc.collectionView.scrollIndicatorInsets = vc.collectionView.contentInset;
        
        vc.collectionView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
        
        vc.view.frame = CGRectMake(scrollView.contentOffset.x, 0, ZLScreebWidth, ZLScreenHeight - 64);
        [scrollView addSubview:vc.view];
    }
    
    ZLLog(@"---childVCs---%@",self.childViewControllers);
}


@end
