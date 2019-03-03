//
//  WBMainViewController.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/1/30.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit
import SVProgressHUD
class WBMainViewController: UITabBarController {
    // MARK: - 私有控件
    /// 撰写按钮
    internal lazy var composeButton: UIButton = UIButton.cz_imageButton(
        "tabbar_compose_icon_add",
        backgroundImageName: "tabbar_compose_button")
     //定时器
    internal var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false //防止tabbar 回退的时候跳动
        delegate = self
        setupChildControllers();
        setupComposeButton();
        //时间触发器
        setupTimer();
        
        // 设置新特性视图
         setupNewfeatureViews()
        
        // 注册通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userLogin),
            name: NSNotification.Name(rawValue: WBUserShouldLoginNotification),
            object: nil)
    }
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    /// 撰写微博
    internal func composeStatus() {
        // FIXME: 0> 判断是否登录
        
        // 1> 实例化视图
        let v = WBComposeTypeView.composeTypeView()
        
        // 2> 显示视图 - 注意闭包的循环引用！
        v.show { [weak v] (clsName) in
            print(clsName ?? "")
            
            // 展现撰写微博控制器
            guard let clsName = clsName,
                let cls = NSClassFromString(Bundle.main.namespace + "." + clsName) as? UIViewController.Type
                else {
                    v?.removeFromSuperview()
                    return
            }
            
            let vc = cls.init()
            let nav = UINavigationController(rootViewController: vc)
            
            // 让导航控制器强行更新约束 - 会直接更新所有子视图的约束！
            // 提示：开发中如果发现不希望的布局约束和动画混在一起，应该向前寻找，强制更新约束！
            nav.view.layoutIfNeeded()
            
            self.present(nav, animated: true) {
                v?.removeFromSuperview()
            }
        }
        
        
    }
    /**
     portrait    : 竖屏，肖像
     landscape   : 横屏，风景画
     
     - 使用代码控制设备的方向，好处，可以在在需要横屏的时候，单独处理！
     - 设置支持的方向之后，当前的控制器及子控制器都会遵守这个方向！
     - 如果播放视频，通常是通过 modal 展现的！
     */
    //Swift 3.0 中设置去掉了之前版本中设置当前控制器支持的旋转方向的方法:
//  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return .portrait
//    }
    private var _orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self._orientations }
        set { self._orientations = newValue }
    }
    
    // MARK: - 监听方法
    @objc private func userLogin(n: Notification) {
        print("用户登录通知 \(n)")
        var when = DispatchTime.now()
        //判断 object 是否有值，如果有值，提示用户重新登录
        if n.object != nil {
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.showInfo(withStatus: "用户登录超时，重新登录")
            
            when = DispatchTime.now() + 2
        }
        DispatchQueue.main.asyncAfter(deadline: when) {
            SVProgressHUD.setDefaultMaskType(.clear)
            let nav = UINavigationController(rootViewController: WBOAuthViewController())
            self.present(nav, animated: true) {
                
            }
        }
       
    }
}






// extension 类似于 OC 中的 分类，在 Swift 中还可以用来切分代码块
// 可以把相近功能的函数，放在一个 extension 中
// 便于代码维护
// 注意：和 OC 的分类一样，extension 中不能定义属性
// MARK: - 设置界面
extension WBMainViewController{
    //设置撰写按钮
    internal func setupComposeButton(){
        tabBar.addSubview(composeButton)
        
        let count = CGFloat(childViewControllers.count)
        //向内锁进的宽度
        let w = tabBar.bounds.width/count - 1 ;
        
        composeButton.frame = tabBar.bounds.insetBy(dx: 2*w, dy: 0)
        
        //监听
        composeButton.addTarget(self, action: #selector(composeStatus), for: .touchUpInside)
    }
    
     //设置所有子控制器
    internal func setupChildControllers(){
          //从内存加载
//        let array :[[String:Any]] = [
//            ["clsName": "WBHomeViewController","title":"首页","imageName":"home",
//             "visitorInfo":["imageName":"","message":"关注一些人"]
//             ],
//            ["clsName": "WBMessageViewController","title":"消息","imageName":"message_center",
//             "visitorInfo":["imageName":"visitordiscover_image_message","message":"登录后，别人评论会收到通知"]],
//            ["clsName": "NULL"],//撰写按钮
//            ["clsName": "WBDiscoverViewController","title":"发现","imageName":"discover",
//             "visitorInfo":["imageName":"visitordiscover_image_message","message":"登录后，最新最热微博不会和你擦肩而过"]],
//            ["clsName": "WBProfileViewController","title":"我","imageName":"profile",
//             "visitorInfo":["imageName":"visitordiscover_image_profile","message":"登录后，你的微博，相册展示给别人"]]
//        ]
       
        // 0. 获取沙盒 json 路径
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let jsonPath = (docDir as NSString).appendingPathComponent("main.json")
        
        // 加载 data
        var data = NSData(contentsOfFile: jsonPath)
        
        // 判断 data 是否有内容，如果没有，说明本地沙盒没有文件
        if data == nil {
            let path = Bundle.main.path(forResource: "main.json", ofType: nil)
            data = NSData(contentsOfFile: path!)
        }
        // data 一定会有一个内容，反序列化
        // 反序列化转换成数组
        guard let array = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [[String: Any]]
            else {
                return
         }
        
        var arrayM = [UIViewController]()
        for dict in array! {
            arrayM.append(controller(dict: dict))
        }
        viewControllers = arrayM
    }
    private func controller(dict: [String: Any])-> UIViewController {
        // 1. 取得字典内容
        guard let clsName = dict["clsName"] as? String,
           let title = dict["title"] as? String ,
           let imageName = dict["imageName"] as? String ,
           let cls = NSClassFromString(Bundle.main.namespace + "." + clsName) as? WBBaseViewController.Type,
           let visitorDict = dict["visitorInfo"] as? [String:String]
        
           else {
                
                return UIViewController()
        }
        
        let vc = cls.init()
        vc.title = title
        //传递访客视图内容
        vc.visitorInfoDictionary = visitorDict
        
        //设置图像
        vc.tabBarItem.image = UIImage(named: "tabbar_" + imageName)
        vc.tabBarItem.selectedImage = UIImage(named: "tabbar_" + imageName + "_selected")?.withRenderingMode(.alwaysOriginal)
        
        //设置tabbar的标题字体
        vc.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.orange], for: .highlighted)
        // // 系统默认是 12 号字，修改字体大小，要设置 Normal 的字体大小
        vc.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControl.State(rawValue: 0))
       
        let nav = WBNavigationController(rootViewController: vc)
        return nav
        
    }
}
// MARK: - UITabBarControllerDelegate
extension WBMainViewController: UITabBarControllerDelegate {
    /// 将要选择 TabBarItem
    ///
    /// - parameter tabBarController: tabBarController
    /// - parameter viewController:   目标控制器
    ///
    /// - returns: 是否切换到目标控制器
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
       
         // 1> 获取控制器在数组中的索引
        let idx = (childViewControllers as NSArray).index(of: viewController)
        // 2> 判断当前索引是首页，同时 idx 也是首页，重复点击首页的按钮
        if selectedIndex == 0 && idx == selectedIndex {
            // 3> 让表格滚动到顶部
            // a) 获取到控制器
            let nav = childViewControllers[0] as! UINavigationController
            let vc = nav.childViewControllers[0] as! WBHomeViewController
             // b) 滚动到顶部
            vc.tableView?.setContentOffset(CGPoint(x: 0, y: -44), animated: true)
            // 4> 刷新数据 － 增加延迟，是保证表格先滚动到顶部再刷新
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                 vc.loadData()
            }
           // 5> 清除 tabItem 的 badgeNumber
            vc.tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        
        // 判断目标控制器是否是 UIViewController,就是中间的按钮
        return !viewController.isMember(of: UIViewController.self)
    }
}
// MARK: - 时钟相关方法
extension WBMainViewController {
    func setupTimer()  {
        timer = Timer(timeInterval: 60, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    ///时钟回调
   @objc private func updateTimer() {
    if !WBNetworkManager.shared.userLogon {
        return
    }
    WBNetworkManager.shared.unreadCount { (count) in
        print("监测到 \(count) 条新微博")
        self.tabBar.items?[0].badgeValue = count > 0 ? "\(count)" : nil
        // 设置 App 的 badgeNumber，从 iOS 8.0 之后，要用户授权之后才能够显示
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
   }
}
// MARK: - 新特性视图处理
extension WBMainViewController {
    
    /// 设置新特性视图
    /**
     版本号
     - 在 AppStore 每次升级应用程序，版本号都需要增加，不能递减
     
     - 组成 主版本号.次版本号.修订版本号
     - 主版本号：意味着大的修改，使用者也需要做大的适应
     - 次版本号：意味着小的修改，某些函数和方法的使用或者参数有变化
     - 修订版本号：框架／程序内部 bug 的修订，不会对使用者造成任何的影响
     */
     func setupNewfeatureViews() {
        // 0. 判断是否登录
        if !WBNetworkManager.shared.userLogon {
            return
        }
        // 1. 如果更新，显示新特性，否则显示欢迎
        let v = isNewVersion ? WBNewFeatureView() : WBWelcomeView.welcomeView()
        //let v = false ? WBNewFeatureView.newFeatureView() : WBWelcomeView.welcomeView()
        v.frame = view.bounds
        // 2. 添加视图
        view.addSubview(v)
    }
    /// extesions 中可以有计算型属性，不会占用存储空间
    /// 构造函数：给属性分配空间
    private var isNewVersion: Bool {
        
        // 1. 取当前的版本号 1.0.2
        // print(Bundle.main().infoDictionary)
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        print("当前版本" + currentVersion)
        
        // 2. 取保存在 `Document(iTunes备份)[最理想保存在用户偏好]` 目录中的之前的版本号 "1.0.2"
        let path: String = ("version" as NSString).cz_appendDocumentDir()
        let sandboxVersion = (try? String(contentsOfFile: path)) ?? ""
        print("沙盒版本" + sandboxVersion)
        
        // 3. 将当前版本号保存在沙盒 1.0.2
         try? currentVersion.write(toFile: path, atomically: true, encoding: .utf8)
        
        // 4. 返回两个版本号`是否一致` not new
        return currentVersion != sandboxVersion
       // return false
        
    }
}
