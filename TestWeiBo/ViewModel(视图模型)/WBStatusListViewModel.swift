//
//  WBStatusListViewModel.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/2/12.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import Foundation
import SDWebImage
/// 微博数据列表视图模型
/*
 父类的选择
 
 - 如果类需要使用 `KVC` 或者字典转模型框架设置对象值，类就需要继承自 NSObject
 - 如果类只是包装一些代码逻辑(写了一些函数)，可以不用任何父类，好处：更加轻量级
 - 提示：如果用 OC 写，一律都继承自 NSObject 即可
 
 使命：负责微博的数据处理
 1. 字典转模型
 2. 下拉／上拉刷新数据处理
 */

class WBStatusListViewModel {
    
    //listviewmodel 不直接管理 status，改为管理viewmodel
   // lazy var statusList = [WBStatus]()
    //微博视图模型数组懒加载
     lazy var statusList = [WBStatusViewModel]()
    var pullupErrorTimes = 0
    var maxPullupTryTImes = 3
    ///加载微博列表
    func loadStatus(_ pullup: Bool , completion: @escaping (_ isSuccess: Bool,_ shouldRefresh: Bool)->()) {
         //判断是否是上拉刷新，同时检查刷新错误次数
        if pullup && pullupErrorTimes > maxPullupTryTImes {
            completion(true, false)
            return
        }
        
        //取出数组第一条微博的 id
        let since_id = pullup ? 0 : (statusList.first?.status.id ?? 0)
        //上拉刷新，取出数组的最后一条微博的 id
        let max_id = !pullup ? 0 : (statusList.last?.status.id ?? 0)
         //加一个数据访问层，有缓存先从缓存加载
         WBStatusListDAL.loadStatus(since_id: since_id, max_id: max_id){ (list,
        // WBNetworkManager.shared.statusList(since_id:since_id,max_id: max_id) { (list,
            isSuccess) in
            //判断网络加载是否成功
            if !isSuccess {
                //直接回调返回
                completion(false,false)
                return
            }
            var array = [WBStatusViewModel]()
            //便利服务器返回的字典数组，字典转模型
            for dict in list ?? [] {
                guard let model = WBStatus.yy_model(with: dict) else {
                    continue
                }
                //将 视图模型 添加到数组
                //WBStatusViewModel的构造函数开始执行，在构造函数里各个位置已经处理好了
                array.append(WBStatusViewModel(model: model))
            }
            //字典转模型(废弃)
//            guard let array = NSArray.yy_modelArray(with: WBStatus.self, json: list ?? []) as? [WBStatus] else {
//                completion(isSuccess,false)
//                return
//            }
            
            //拼接数据
            if pullup {
                self.statusList += array
            }
            else{
                self.statusList = array + self.statusList
            }
            //判读上拉刷新的数据量
            if pullup && array.count == 0
            {
                self.pullupErrorTimes += 1
                completion(isSuccess,false)
            }
            else {
            //完成回调
                self.cacheSingleImage(list: array,finished: completion)
                //这个不用了，要在单张缓存图片完成之后，再回调
               // completion(isSuccess,true)
                
            }
        }
    }
    
    /// 缓存本次下载微博数据数组中的单张图像
    ///
    /// - 应该缓存完单张图像，并且修改过配图是的大小之后，再回调，才能够保证表格等比例显示单张图像！
    ///
    /// - parameter list: 本次下载的视图模型数组
    private func cacheSingleImage(list: [WBStatusViewModel],finished: @escaping (_ isSuccess: Bool,_ shouldRefresh: Bool)->()) {
        // 调度组
        let group = DispatchGroup()
        
        // 记录数据长度
        var length = 0
        
        
        //便利数组，查找微博数据中有单张图像的 ，进行缓存
        for vm in list { //option + command + 左 ：折叠
            // 判断 图像数量
            if vm.picURLs?.count != 1 {
                continue
            }
            //代码执行到此，数组中有且仅有一张图片
            guard let pic = vm.picURLs?[0].thumbnail_pic,
                let url = URL(string: pic) else {
                continue
            }
           // print("缓存的URL是 \(url)")
            // 3> 下载图像
            // 1) downloadImage 是 SDWebImage 的核心方法
            // 2) 图像下载完成之后，会自动保存在沙盒中，文件路径是 URL 的 md5
            // 3) 如果沙盒中已经存在缓存的图像，后续使用 SD 通过 URL 加载图像，都会加载本地沙盒地图像
            // 4) 不会发起网路请求，同时，回调方法，同样会调用！
            // 5) 方法还是同样的方法，调用还是同样的调用，不过内部不会再次发起网路请求！
            // *** 注意点：如果要缓存的图像累计很大，要找后台要接口！
            // A> 入组，就会监听后面的block
            group.enter()
            
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: [], progress: nil, completed: { (image, _, _, _) in
                
              print(Thread.current)
                
                // 将图像转换成二进制数据
                if let image = image,
                    let data = UIImagePNGRepresentation(image) {
                    
                    // NSData 是 length 属性
                    length += data.count
                    
                    // 图像缓存成功，更新配图视图的大小，默认是九宫格的方式，单张图片要修改 高度
                      vm.updateSingleImageSize(image: image)
                }
                
              //  print("缓存的图像是 \(image) 长度 \(length)")
                
                // B> 出组 - 放在回调的最后一句
                 group.leave()
            })
            
          
        }
        // C> 监听调度组情况
        group.notify(queue: DispatchQueue.main) {
            print("图像缓存完成 \(length / 1024) K")
            
            // 执行闭包回调
            finished(true,true)
        }
    }
}
