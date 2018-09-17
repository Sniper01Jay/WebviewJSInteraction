//
//  WKWebViewController.m
//  WebviewJSInteraction
//
//  Created by ccd on 2018/8/13.
//  Copyright © 2018年 CCD. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>

@interface WKWebViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property(nonatomic,strong) WKWebView *webView;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWebView];
    
//    https://blog.csdn.net/u010105969/article/details/77414033
    /*********************************************************
     WKWebView与JS交互 https://www.jianshu.com/p/4d12d593ba60
     
     WKWebView的使用之JS调用OC:https://www.jianshu.com/p/9b4f7f6d47da
     
     WKWebView使用之OC调用JS: https://www.jianshu.com/p/ae61a2201d7a
     
     ****** 详细介绍 ****** js调用oc
     WKWebView OC 与 JS 交互学习：https://www.cnblogs.com/someonelikeyou/p/6890587.html
     WKWebView与Js实战(OC版)：https://www.cnblogs.com/jiang-xiao-yan/p/5345893.html
     */
}
- (void)initWebView
{
//    js与oc原生WKWebView方法注入及交互传值: https://blog.csdn.net/one_person_one_life/article/details/78563205
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
    // 设置偏好设置
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 30;
    config.preferences.javaScriptEnabled = YES;
    // 在ios上默认为NO，表示不能自动通过窗口打开
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
//    WKUserContentController是用于给JS注入对象的，注入对象后，JS端就可以使用：
    config.userContentController = [[WKUserContentController alloc] init];
    // web内容处理池，由于没有属性可以设置，也没有方法可以调用，不用手动创建
    config.processPool = [[WKProcessPool alloc] init];
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    // 加载本地HTML内容
    NSString * urlStr = [[NSBundle mainBundle] pathForResource:@"jsInteraction.html" ofType:nil];
    // 加载本地的html文件
    [self.webView loadFileURL:[NSURL fileURLWithPath:urlStr] allowingReadAccessToURL:[NSURL fileURLWithPath:urlStr]];
    
    /**
     总的来说，要实现JS调用OC方法，重点就是三项：
     1.必须在html中预留接口，格式是固定的：window.webkit.messageHandlers.ActionName.postMessage('parameter');
     2.陪着WKWebViewConfiguration，并通过WKUserContentController注册html中预留的方法；
     3.实现WKScriptMessageHandler协议的- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message方法。
     
     */
    
    // 添加注入js方法，oc与js端对应
    //设置addScriptMessageHandler与name.并且设置<WKScriptMessageHandler>协议与协议方法
    // 注入JS对象名称collectsendKey，当JS通过collectsendKey来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:self name:@"collectsendKey"];
    
    
}
- (void)collectsendKey:(NSString *)msg
{
    NSLog(@"js调用oc了: %@",msg);
}
# pragma mark - WKScriptMessageHandler
/**
 要想让OC能够响应JS的方法，我们光配置WKWebViewConfiguration，给其WKUserContentController添加ScriptMessageHandler还是不够的，我们还需要用到WKScriptMessageHandler协议的
 */
// 处理js调用oc的方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"method name: %@",message.body);
//    当JS通过collectsendKey发送数据到iOS端时，会在代理中收到：
    if ([message.name isEqualToString:@"collectsendKey"]) {
        [self collectsendKey:@"123"];
    }
}
# pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // oc调js方法
    NSString * jsStr = [NSString stringWithFormat:@"testI('%@')",@"jackie"];
    [webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"执行完毕");
    }];
}
//在JS端调用alert函数时，会触发此代理方法。与上面组合使用
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"message: %@",message);
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alert = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler();
    }];
    [alertVC addAction:alert];
    [self presentViewController:alertVC animated:YES completion:nil];
    completionHandler();
}
# pragma mark - WKNavigationDelegate
// 在发送请求后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // 如果实现了这个代理方法，就必须得调用decisionHandler这个block，否则会导致app 崩溃。block参数是个枚举类型，WKNavigationActionPolicyCancel代表取消加载，相当于UIWebView的代理方法return NO的情况；WKNavigationActionPolicyAllow代表允许加载，相当于UIWebView的代理方法中 return YES的情况。
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
