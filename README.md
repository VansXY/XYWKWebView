# XYWKWebView
iOS 12 弃用了UIWebView，自己封装一个WKWebView基类，便于以后使用。并介绍了在使用WKWebView可能遇到的坑

## JS调用OC（通过注册方法名的方式）
/// 注册的方法名
    [self registJavascriptBridge:@"" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@",data);
    }];
    
    
## OC调用JS(执行JS代码）
这里使用WKWebView实现OC调用JS方法跟WKWebView使用URL拦截是一样的，还是利用 
- evaluateJavaScript:completionHandler:方法：

// 将分享结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
    
## WKWebView可能遇到的坑
1. 默认的跳转行为，打开 iTuns、tel、mail、open 等

  - 在 UIWebView 上，如果超链接设置未 tel://00-0000 之类的值，点击会直接拨打电话，但在 WKWebView 上，该点击没有反应，类似的都被屏蔽了，通过打开浏览器跳转 AppStore 已然无法实现
  
这类情况只能在跳转询问中处理，校验 scheme 值通过 UIApplication 外部打开

2. NSURLProtocol 问题

  - UIWebView 是通过 NSURLConneciton 处理的 HTTP 请求，而通过Conneciton 发出的请求都会遵循 NSURLProtocol 协议，通过这个特性，我们可以代理 Web 资源的下载，做统一的缓存管理或资源管理
  
但在 WKWebView 上这个不可行了，因为 WKWebView 的载入在单独进程中进行，数据载入 app 无法干涉

3. 前端问题
- 页面退回上一页不会重新执行 Script 脚本，也不会触发 reload 事件    这个是因为 WKWebView 的页面管理和缓存机制导致的

- 页面键盘弹出会触发 resize 事件

- window.unload 只有刷新页面才会触发，退出或跳转到其它页都无法触发
