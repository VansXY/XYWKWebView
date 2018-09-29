//
//  XYWKWebViewController.h
//  XYWKWebView
//
//  Created by 肖扬 on 2018/9/29.
//  Copyright © 2018年 肖扬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKWebViewJavascriptBridge.h"

@interface XYWKWebViewController : UIViewController

/// 用于加载一个新的URLRequest
@property (nonatomic, strong, readonly) WKWebView *webView;

/// 页面URL
@property (nonatomic, copy) NSString *pageUrl;


/// 页面title， 可以不传
@property (nonatomic, copy) NSString *pageTitle;

/**
 注册js回调
 
 @param handlerName js 名称
 @param handler 回到方法
 */
- (void)registJavascriptBridge:(NSString *)handlerName handler:(WVJBHandler)handler;

/**
 调用js
 
 @param handlerName js 名称
 @param data 数据
 */
- (void)callHandler:(NSString *)handlerName data:(id)data;

/**
 加载第三方H5页面需要重写此方法
 */
- (void)loadWebPage;

/**
 重新加载页面
 */
- (void)reloadPage;

@end
