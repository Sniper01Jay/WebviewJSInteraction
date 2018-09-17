//
//  PersonObject.m
//  WebviewJSInteraction
//
//  Created by ccd on 2018/8/10.
//  Copyright © 2018年 CCD. All rights reserved.
//

#import "PersonObject.h"

@implementation PersonObject

- (void)nslog:(NSString *)str
{
    NSLog(@"%@",str);
}
- (void)pushToWebView:(NSString *)str
{
    if (self.pushToWKWebViewBlock) {
        self.pushToWKWebViewBlock();
    }
}

@end
