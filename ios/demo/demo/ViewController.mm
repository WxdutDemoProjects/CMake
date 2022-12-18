//
//  ViewController.m
//  demo
//
//  Created by hiwang on 2021/5/20.
//

#import "ViewController.h"
#import <wxdut/wxdut.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    wxdut::testOpenCV();
}

@end
