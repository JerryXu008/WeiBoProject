//
//  WBOAuthViewController.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/2/13.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit
import SVProgressHUD
class WBOAuthViewController: UIViewController {
   private lazy var webView = UIWebView()
    
    override func loadView() {
        view = webView
        webView.delegate = self
        webView.backgroundColor = UIColor.white
        webView.scrollView.isScrollEnabled = false
        // 设置导航栏
        title = "登录新浪微博"
        // 导航栏按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", target: self, action: #selector(close), isBack: true)
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", target: self, action: #selector(autoFill))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加载授权页面
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(WBAppKey)&redirect_uri=\(WBRedirectURI)"
        
        // 1> URL 确定要访问的资源
        guard let url = URL(string: urlString) else {
            return
        }
        
        // 2> 建立请求
        let request = URLRequest(url: url)
        
        // 3> 加载请求
        webView.loadRequest(request)
    }
    // MARK: - 监听方法
    /// 关闭控制器
    @objc  func close() {
        SVProgressHUD.dismiss()
        
        dismiss(animated: true, completion: nil)
    }
    /// 自动填充 - WebView 的注入，直接通过 js 修改 `本地浏览器中` 缓存的页面内容
    /// 点击登录按钮，执行 submit() 将本地数据提交给服务器！
    @objc private func autoFill() {
        
        // 准备 js
        let js = "document.getElementById('userId').value = '18201508709'; " +
        "document.getElementById('passwd').value = '7882273';"
        
        // 让 webview 执行 js
        webView.stringByEvaluatingJavaScript(from: js)
    }
}
extension WBOAuthViewController : UIWebViewDelegate {
    /// webView 将要加载请求
    ///
    /// - parameter webView:        webView
    /// - parameter request:        要加载的请求
    /// - parameter navigationType: 导航类型
    ///
    /// - returns: 是否加载 request
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // 确认思路：
        // 1. 如果请求地址包含 http://baidu.com 不加载页面 ／ 否则加载页面
        // request.url?.absoluteString?.hasPrefix(WBRedirectURI) 返回的是可选项 true/false/nil
        if request.url?.absoluteString.hasPrefix(WBRedirectURI) == false {
            return true
        }
        
        // print("加载请求 --- \(request.url?.absoluteString)")
        // query 就是 URL 中 `?` 后面的所有部分
        // print("加载请求 --- \(request.url?.query)")
        // 2. 从 http://baidu.com 回调地址的`查询字符串`中查找 `code=`
        //    如果有，授权成功，否则，授权失败
        if request.url?.query?.hasPrefix("code=") == false {
            
            print("取消授权")
            close()
            
            return false
        }
        
        // 3. 从 query 字符串中取出 授权码
        // 代码走到此处，url 中一定有 查询字符串，并且 包含 `code=`
        // code=15be12d79321e474c599210ef637c978
        let code = request.url?.query?.substring(from: "code=".endIndex) ?? ""
        
        print("授权码 - \(code)")
        // 4. 使用授权码获取[换取] AccessToken
        WBNetworkManager.shared.loadAccessToken(code) { (isSuccess) in
            if !isSuccess {
                SVProgressHUD.showInfo(withStatus: "网络请求失败")
            } else {
                //SVProgressHUD.showInfo(withStatus: "登录成功")
                // 下一步做什么？跳转`界面` 通过通知发送登录成功消息
                // 1> 发送通知 - 不关心有没有监听者
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: WBUserLoginSuccessedNotification),
                    object: nil)
                
                
                self.close()
            }
        }
        
        return false
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
