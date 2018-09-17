//
//  PersonObject.h
//  WebviewJSInteraction
//
//  Created by ccd on 2018/8/10.
//  Copyright © 2018年 CCD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

/**
  宏JSExportAs，它的作用是：给JSCore在JS中为OC方法生成的对应方法指定名字
 */
@protocol PersonJSExport<JSExport>

JSExportAs(nslog, -(void)nslog:(NSString *)str);
JSExportAs(pushToWKWebView, -(void)pushToWebView:(NSString*)str);

@end

@interface PersonObject : NSObject<PersonJSExport>

@property(nonatomic,copy) void(^pushToWKWebViewBlock)(void);

- (void)nslog:(NSString *)str;
- (void)pushToWebView:(NSString *)str;

@end
