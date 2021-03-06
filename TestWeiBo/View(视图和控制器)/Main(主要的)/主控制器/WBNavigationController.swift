//
//  WBNavigationController.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/1/30.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit

class WBNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 隐藏默认的 NavigationBar
         navigationBar.isHidden = true
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // 如果不是栈底控制器才需要隐藏，根控制器不需要处理
        if childViewControllers.count > 0 {
            // 隐藏底部的 TabBar
            viewController.hidesBottomBarWhenPushed = true
           
            
            // 判断控制器的类型
            if let vc = viewController as? WBBaseViewController {
                var title = "返回"
                // 判断控制器的级数，只有一个子控制器的时候，显示栈底控制器的标题
                if childViewControllers.count == 1 {
                    // title 显示首页的标题
                    title = childViewControllers.first?.title ?? "返回"
                }
                
//                vc.navItem.leftBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(popToParent))
                vc.navItem.leftBarButtonItem = UIBarButtonItem(title: title, target: self, action: #selector(popToParent), isBack: true)
            }
        }
        super.pushViewController(viewController, animated: animated)
    }
    /// POP 返回到上一级控制器
    @objc private func popToParent() {
        popViewController(animated: true)
    }

}
