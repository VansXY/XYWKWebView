# XYWKWebView
iOS 12 弃用了UIWebView，自己封装一个WKWebView基类，便于以后使用。并介绍了在使用WKWebView可能遇到的坑。

## 如何使用
1. 集成基类 XYWKWebViewController，实现方法
```
- (void)loadWebPage {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:@"xxxx"]];
    [self.webView loadRequest:urlRequest];
}
```

2. 如果有交互，在ViewDidLoad方法里面需要注册方法
```
    [self registJavascriptBridge:@"xxxxxxx" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@",data);
    }];
```


## Native 与 JS 是怎么交互的

#### 1. JS调用OC（JS 调用 Native，UIWebView 通过 JavaScriptCore 库，内部有一个 JSContext 对象，可实现共享，WKWebView 通过 Web 的 window 对象提供 WebKit 对象实现共享。WKWebView 绑定共享对象，是通过特定的构造方法实现，参考代码，通过指定 UserContentController 对象的 ScriptMessageHandler 经过 Configuration 参数构造时传入）

```
    [self registJavascriptBridge:@"" handler:^(id data, WVJBResponseCallback responseCallback) {
        /// data的数据类型可以是json串，也可以是json格式，和web协商好就可以
        NSLog(@"%@",data);
    }];
``` 
    
#### 2. OC调用JS(Native 调用 JS，这个完全依靠 WebView 提供的接口实现，WKWebView 提供的接口和 UIWebView 命名上较为类似，区别是 WKWebView 的这个接口是异步的，而 UIWebView 是同步接口）
```
    NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
```


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
