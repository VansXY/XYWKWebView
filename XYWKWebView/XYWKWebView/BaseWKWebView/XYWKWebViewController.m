//
//  XYWKWebViewController.m
//  XYWKWebView
//
//  Created by 肖扬 on 2018/9/29.
//  Copyright © 2018年 肖扬. All rights reserved.
//

#import "XYWKWebViewController.h"
#import <WebKit/WebKit.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface XYWKWebViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

//js 代理
@property (nonatomic, strong) WKWebViewJavascriptBridge *jsBridge;

@property (nonatomic, assign) BOOL loadResult;

@end

@implementation XYWKWebViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    
    if(self.pageTitle) {
        self.title = self.pageTitle;
    }
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:(NSKeyValueObservingOptionNew) context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self loadWebPage];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

#pragma mark 注册js回调
- (void)registJavascriptBridge:(NSString *)handlerName handler:(WVJBHandler)handler {
    [self.jsBridge registerHandler:handlerName handler:handler];
}

#pragma mark 调用js
- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self.jsBridge callHandler:handlerName data:data];
}

#pragma mark - Action
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        //        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    }
}

#pragma mark webView初始化
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [[WKUserContentController alloc] init];
        
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preferences;
        float iPhoneXNavBarMargin = (ScreenHeight == 812) ? 88 : 64;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, iPhoneXNavBarMargin, ScreenWidth, ScreenHeight - iPhoneXNavBarMargin) configuration:configuration];
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _webView;
}

#pragma mark jsBridge初始化
- (WKWebViewJavascriptBridge *)jsBridge {
    if (!_jsBridge) {
        [WKWebViewJavascriptBridge enableLogging];
        _jsBridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView handler:^(id data, WVJBResponseCallback responseCallback) {
        }];
    }
    return _jsBridge;
}

#pragma mark 加载页面
- (void)loadWebPage {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:self.pageUrl]];
    [self.webView loadRequest:urlRequest];
}

#pragma mark 重新加载页面
- (void)reloadPage {
    self.webView.hidden = YES;
    self.loadResult = NO;
    [self.webView reload];
}

@end
