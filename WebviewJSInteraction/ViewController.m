//
//  ViewController.m
//  WebviewJSInteraction
//
//  Created by ccd on 2018/8/10.
//  Copyright © 2018年 CCD. All rights reserved.
//

#import "ViewController.h"
#import "PersonObject.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "WKWebViewController.h"

@interface ViewController ()<UIWebViewDelegate>

@property(nonatomic,strong) UIWebView *webView;
@property(nonatomic,strong) JSContext *context;
@property(nonatomic,strong) PersonObject * person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    /**  深入浅出 JavaScriptCore: http://www.cocoachina.com/ios/20170720/19958.html
         iOS中JavaScript 与OC交互: https://www.jianshu.com/p/59242a92d4f2
         iOS下JS与原生OC互相调用(总结): https://www.cnblogs.com/lynna/p/7680731.html
     
     JSContext
     一个JSContext实例代表着一个js运行时环境，js代码都需要在一个context上下文内执行，而且JSContext还负责管理js虚拟机中所有对象的生命周期
     JSValue
     表示一个JavaScript的实体，一个JSValue可以表示很多JavaScript原始类型例如boolean, integers, doubles，甚至包括对象和函数。我们对JS的操作都是通过它，并且每个JSValue都强引用一个context。同时，OC和JS对象之间的转换也是通过它
     JSExport: 这是一个协议，可以用这个协议来将原生对象导出给JavaScript，这样原生对象的属性或方法就成为了JavaScript的属性或方法，非常神奇。
     
     JavaScript 与 Objective-C 交互主要通过2种方式：
        Block : 第一种方式是使用block，block也可以称作闭包和匿名函数，使用block可以很方便的将OC中的单个方法暴露给JS调用，具体实现我们稍后再说。
        JSExport 协议 : 第二种方式，是使用JSExport协议，可以将OC的中某个对象直接暴露给JS使用，而且在JS中使用就像调用JS的对象一样自然。
     */
    [self createWebView];
}
- (void)createWebView
{
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"jsInteraction" withExtension:@"html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}
- (void)jsCallOC
{
    __weak typeof(self) weakSelf = self;
    [self.person setPushToWKWebViewBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf pushToNext];
        });
    }];
}
# pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // JS调用OC方法
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _person = [[PersonObject alloc] init];
    _context[@"ttf"] = self.person;
    
    // OC调用js 使用JavaScriptCore库来做JS交互。
//    NSString * textJS = @"testI('jessie')";
//    [_context evaluateScript:textJS];
    
    [self jsCallOC];
}
- (void)pushToNext
{
    WKWebViewController * vc = [[WKWebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
