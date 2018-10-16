//
//  UIScrollView+ZLGestureConflict.m
//
//  Created by MacBook on 2018/9/25.
//  Copyright © 2018 MacBook. All rights reserved.
//

#import "UIScrollView+ZLGestureConflict.h"

@implementation UIScrollView (ZLGestureConflict)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    // 首先判断otherGestureRecognizer是不是系统pop手势
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
        // 再判断系统手势的state是began还是fail，同时判断scrollView的位置是不是正好在最左边
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan /*&& self.contentOffset.x == 0*/) {
            return YES;
        }
    }
    return NO;
}


@end
