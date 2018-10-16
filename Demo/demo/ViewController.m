//
//  ViewController.m
//  demo
//
//  Created by MacBook on 2018/10/16.
//  Copyright © 2018 MacBook. All rights reserved.
//

#import "ViewController.h"
#import "ZLScrollTitleViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor cyanColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self presentSVc];
}


- (void)presentSVc {
    ZLScrollTitleViewController *sVc = [[ZLScrollTitleViewController alloc] init];
    NSMutableArray *childVcs = [NSMutableArray array];
    NSMutableArray *titles = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i++) {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor magentaColor];
        [childVcs addObject:vc];
        [titles addObject:@"lalala"];
    }
    sVc.childViewControllers = childVcs;
    sVc.titles = titles;
    
    [self presentViewController:sVc animated:YES completion:nil];
}

@end
