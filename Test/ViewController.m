//
//  ViewController.m
//  Test
//
//  Created by IOS-Sun on 16/4/20.
//  Copyright © 2016年 IOS-Sun. All rights reserved.
//

#import "ViewController.h"

#import "NSString+Extension.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    File *file = [[File alloc] init];
    [file sayHappy];
    
    NSString *num = @"23561223435454634.234343";
    NSString *new = [NSString returnMillonString:num];
    NSString *newDouble = [num convert:[num doubleValue]];
    NSLog(@"new:%@",new);
    NSLog(@"newDouble:%@",newDouble);
    
    NSString *num1 = @"23343";
    NSString *new1 = [NSString returnMillonString:num1];
    NSString *new1Double = [num1 convert:[num1 doubleValue]];
    NSLog(@"new1:%@",new1);
    NSLog(@"new1Double:%@",new1Double);
    
    NSString *num2 = @"-23343.144532";
    NSString *new2 = [NSString returnMillonString:num2];
    NSString *new2Double = [num2 convert:[num2 doubleValue]];
    NSLog(@"new2:%@",new2);
    NSLog(@"new2Double:%@",new2Double);
    
    NSString *num3 = @"-233";
    NSString *new3 = [NSString returnMillonString:num3];
    NSString *new3Double = [num3 convert:[num3 doubleValue]];
    NSLog(@"new3:%@",new3);
    NSLog(@"new3Double:%@",new3Double);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
