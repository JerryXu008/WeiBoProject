//
//  WBBaseViewController.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/1/30.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit

class WBBaseViewController: UIViewController {

    /// 访客视图信息字典
    var visitorInfoDictionary: [String: String]?
    
    /// 表格视图 - 如果用户没有登录，就不创建
    var tableView: UITableView?
    /// 刷新控件
    var refreshControl: CZRefreshControl?
    /// 上拉刷新标记
    var isPullup = false
    
    //自定义导航条，解决滑动融合问题
    lazy var navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.cz_screenWidth(), height:64))
    /// 自定义的导航条目 - 以后设置导航栏内容，统一使用 navItem
    public lazy var navItem = UINavigationItem()
    
    /// 重写 title 的 didSet
    override var title: String? {
        didSet {
            navItem.title = title
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupUI()
        
        WBNetworkManager.shared.userLogon ?  loadData() : ()
        
        // 注册通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loginSuccess),
            name: NSNotification.Name(rawValue: WBUserLoginSuccessedNotification),
            object: nil)
    }
    
    public func loadData(){
        refreshControl?.endRefreshing()
    }
}
//MARK: - 设置界面
extension WBBaseViewController{
    //这个不需要子类重写
    internal func setupUI() {
        view.backgroundColor = UIColor.white
        // 取消自动缩进 - 如果隐藏了导航栏，会缩进 20 个点
        //暂时不起作用，可能与自定义navBar有关系，以后再看
        if #available(iOS 11.0, *) {
            tableView?.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
                
        }
       
       //设置tableview
        WBNetworkManager.shared.userLogon ? setupTableView() : setupVisitorView()
       //设置导航栏
        setupNavigationBar()
    }
    /// 设置访客视图
    private func setupVisitorView(){
         let visitorView = WBVisitorView(frame: view.bounds)
         // 设置数据
         visitorView.visitorInfo = visitorInfoDictionary
         //设置监听方法
        visitorView.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        visitorView.registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        // 3. 设置导航条按钮
        navItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(register))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .plain, target: self, action: #selector(login))
        
        view.insertSubview(visitorView, belowSubview: navigationBar)
    }
    /// 设置tableview
  internal  func setupTableView(){
        tableView = UITableView(frame: view.bounds, style: .plain)
      //  view.addSubview(tableView!)
        view.insertSubview(tableView!, belowSubview: navigationBar)
        // 设置数据源&代理 -> 目的：子类直接实现数据源方法
        tableView?.dataSource = self
        tableView?.delegate = self
    
        // 设置内容缩进
//        tableView?.contentInset = UIEdgeInsets(top: navigationBar.bounds.height,
//                                               left: 0,
//                                               bottom: tabBarController?.tabBar.bounds.height ?? 49,
//                                               right: 0)
        tableView?.contentInset = UIEdgeInsets(top:24,
                                                       left: 0,
                                                       bottom: tabBarController?.tabBar.bounds.height ?? 49,
                                                       right: 0)
       //tableView?.backgroundColor = UIColor.red
    
        //修改指示器的缩进 强行解包是为了拿到一个必有得 inset
      //  tableView?.scrollIndicatorInsets = tableView!.contentInset
        
        // 设置刷新控件
        // 1> 实例化控件
        refreshControl = CZRefreshControl()
        // 2> 添加到表格视图
        tableView?.addSubview(refreshControl!)
        // 3> 添加监听方法
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    //设置导航条
    private func  setupNavigationBar() {
        view.addSubview(navigationBar)
         
        navigationBar.items = [navItem]
        //设置背景颜色[减少透明度]
        navigationBar.barTintColor = UIColor.cz_color(withHex: 0xF6F6F6)
        //设置 navVar 的字体颜色[中间的]
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
        //设置系统按钮的文字渲染颜色[左右系统按钮颜色]
        navigationBar.tintColor = UIColor.orange
    }
    
    
}
// MARK: - 访客视图监听方法
extension WBBaseViewController {
    /// 登录成功处理
    @objc  func loginSuccess(n: Notification) {
        
        print("登录成功 \(n)")
        
        // 登录前左边是注册，右边是登录
        navItem.leftBarButtonItem = nil
        navItem.rightBarButtonItem = nil
        
        // 更新 UI => 将访客视图替换为表格视图
        // 需要重新设置 view
        // 在访问 view 的 getter 时，如果 view == nil 会调用 loadView -> viewDidLoad
        view = nil
        
        // 注销通知 -> 重新执行 viewDidLoad 会再次注册！避免通知被重复注册
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc  func login() {
         print("用户登录")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: nil, userInfo: nil)
    }
    
    @objc  func register() {
        print("用户注册")
    }
}
// MARK: UITableViewDelegate , UITableViewDataSource
extension WBBaseViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    // 基类只是准备方法，子类负责具体的实现
    // 子类的数据源方法不需要 super
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 只是保证没有语法错误！
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    //上拉刷新
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 1. 判断 indexPath 是否是最后一行
        // (indexPath.section(最大) / indexPath.row(最后一行))
        // 1> row
        let row = indexPath.row
        // 2> section
        let section = tableView.numberOfSections - 1
        
        if row < 0 || section < 0 {
            return
        }
        // 3> 行数
        let count = tableView.numberOfRows(inSection: section)
        
        // 如果是最后一行，同时没有开始上拉刷新
        if row == (count - 1) && isPullup == false {
            
            print("上拉刷新")
            isPullup = true
            
            // 开始刷新
            loadData()
        }
    }
    
}
