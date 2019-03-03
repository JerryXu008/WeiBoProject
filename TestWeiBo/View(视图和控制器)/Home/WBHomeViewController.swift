//
//  WBHomeViewController.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/1/30.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit
/// 原创微博可重用 cell id
private let originalCellId = "originalCellId"
/// 被转发微博的 cellid
private let retweetedCellId = "retweetedCellId"
class WBHomeViewController: WBBaseViewController {

    //数据
    lazy var listViewModel = WBStatusListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(browserPhoto),
            name: NSNotification.Name(rawValue: WBStatusCellBrowserPhotoNotification),
            object: nil)
    }
    
    deinit {
        // 注销通知
        NotificationCenter.default.removeObserver(self)
    }
    /// 浏览照片通知监听方法
    @objc private func browserPhoto(n: Notification) {
        
        // 1. 从 通知的 userInfo 提取参数
        guard let selectedIndex = n.userInfo?[WBStatusCellBrowserPhotoSelectedIndexKey] as? Int,
            let urls = n.userInfo?[WBStatusCellBrowserPhotoURLsKey] as? [String],
            let imageViewList = n.userInfo?[WBStatusCellBrowserPhotoImageViewsKey] as? [UIImageView]
            else {
                return
        }
        
        // 2. 展现照片浏览控制器
        let vc = HMPhotoBrowserController.photoBrowser(
            withSelectedIndex: selectedIndex,
            urls: urls,
            parentImageViews: imageViewList)
        
        present(vc, animated: true, completion: nil)
    }
  
    @objc internal func showFriends(){
        let vc = WBDemoViewController()
        
         navigationController?.pushViewController(vc, animated: true)
    }
    
    //加载数据
    override func loadData(){
        print("开始刷新")
        refreshControl?.beginRefreshing()
        
        listViewModel.loadStatus(isPullup) { (isSuccess,shouldRefresh) in
                      // 结束刷新控件
                        self.refreshControl?.endRefreshing()
                        // 恢复上拉刷新标记
                        self.isPullup = false
               if(shouldRefresh) {
                self.tableView?.reloadData()
                
              }
        }
//        模拟测试数据
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//            for i in 0..<19 {
//                if(self.isPullup){
//                    self.statusList.append(i.description)
//                }
//                else {
//                    self.statusList.insert(i.description, at: 0)
//                }
//
//            }
//            // 结束刷新控件
//            self.refreshControl?.endRefreshing()
//            // 恢复上拉刷新标记
//            self.isPullup = false
//
//            self.tableView?.reloadData()
//        }
        
        
    }
    
}
// MARK: - 设置界面
extension WBHomeViewController {
    //只关心登录之后的逻辑，所以只重写这个方法
    override func setupTableView() {
        super.setupTableView()
        
 
    tableView?.register(UINib(nibName: "WBStatusNormalCell", bundle: nil), forCellReuseIdentifier: originalCellId)
    tableView?.register(UINib(nibName: "WBStatusRetweetedCell", bundle: nil), forCellReuseIdentifier: retweetedCellId)
       
    navItem.leftBarButtonItem =  UIBarButtonItem(title: "好友", target: self, action: #selector(showFriends))
   
        // 设置行高
        // 取消自动行高 自适应单元格的高度
       // tableView?.rowHeight = UITableViewAutomaticDimension
        //预估高度
        tableView?.estimatedRowHeight = 300
        
        tableView?.separatorStyle = .none
        
         setupNavTitle()
    }
    
    /// 设置导航栏标题
    private func setupNavTitle() {
         let title = WBNetworkManager.shared.userAccount.screen_name
         let button = WBTitleButton(title: title)
         navItem.titleView = button
         button.addTarget(self, action: #selector(clickTitleButton), for: .touchUpInside)
    }
    @objc func clickTitleButton(btn: UIButton) {
        
        // 设置选中状态
        btn.isSelected = !btn.isSelected
    }
}

// MARK: - 表格数据源方法，具体的数据源方法实现，不需要 super
extension WBHomeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count

    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //取出视图模型
        let vm = listViewModel.statusList[indexPath.row]
        let cellId = (vm.status.retweeted_status != nil) ? retweetedCellId : originalCellId
        //取cell
        //本身会调用代理方法（如果有）/
        // 如果没有 ，找到cell，按照自动布局的规则，从上向下计算，找到向下的约束，从而计算动态杭高
        //每次都要计算，对性能是有影响的
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WBStatusCell
     
        cell.viewModel = vm
        // --- 设置代理 ---
        // 如果用 block 需要在数据源方法中，给每一个 cell 设置 block
        // cell.completionBlock = { // ... }
        // 设置代理只是传递了一个指针地址
        cell.delegate = self
        
        return cell
    }
    
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       let vm = listViewModel.statusList[indexPath.row]
       //返回计算好的行高
       return vm.rowHeight
    }
}

extension WBHomeViewController :WBStatusCellDelegate {
    func statusCellDidSelectedURLString(cell: WBStatusCell, urlString: String){
        let vc = WBWebViewController()
        
        vc.urlString = urlString
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
