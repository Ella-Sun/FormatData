//
//  NSString+Extension.m
//  Test
//
//  Created by IOS-Sun on 16/5/4.
//  Copyright © 2016年 IOS-Sun. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

+ (NSString *)returnMillonString:(NSString *)str {
    
    NSString *testStr = [NSString stringWithString:str];
    BOOL isNav = NO;
    if ([str integerValue] < 0) {
        isNav = YES;
        testStr = [testStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    NSArray *compantStrs = [testStr componentsSeparatedByString:@"."];
    
    if ((compantStrs.count == 0) || (compantStrs.count > 2)) {
        return str;
    }
    NSString *opeStr = compantStrs[0];
    NSInteger len = opeStr.length;
    if (len <= 3) {
        return str;
    }
    
    NSInteger milCount = len/3;
    if (len%3 == 0) {
        milCount -= 1;
    }
    
    NSMutableString *newStr = [NSMutableString stringWithString:opeStr];
    for (int i = 1; i <= milCount; i++) {
        [newStr insertString:@"," atIndex:len-3*i];
    }
    if (compantStrs.count == 2) {
        NSString *dec = compantStrs[1];
        [newStr insertString:@"." atIndex:newStr.length];
        [newStr insertString:dec atIndex:newStr.length];
    }
    if (isNav) {
        [newStr insertString:@"-" atIndex:0];
    }
    
    return newStr;
}

//保留两位小数
//千分位
-(NSString *)convert:(double)number
{
    //格式化
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    //添加千分位分隔符，小数点后有多少位保留多少位
//    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setPositiveFormat:@"###,##0.00;"];
    //.00保留两位小数，添加千分位分隔符
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:number]];
    return formattedNumberString;
}


@end
