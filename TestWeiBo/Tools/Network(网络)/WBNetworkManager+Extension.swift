//
//  WBNetworkManager+Extension.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/2/12.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit

extension WBNetworkManager {
   
    
    // since_id: 返回ID比他大的微博
    // max_id: 返回id比max_id 小于等于的微博
    func statusList(since_id: Int64 = 0,max_id: Int64 = 0 ,completion: @escaping (_ list: [[String: AnyObject]]? ,_ isSuccess: Bool)->()) {
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        let params = ["since_id":"\(since_id)","max_id":"\(max_id > 0 ? max_id - 1 : 0)"]
        //let params = ["since_id":"\(since_id)","max_id":"\(max_id)"]
        WBNetworkManager.shared.tokenRequest(URLString:urlString , parameters:params as [String : AnyObject] ) { (json, isSuccess) in
           //o从json 中获取statuses字典数组
            let result = (json as  AnyObject) ["statuses"] as? [[String: AnyObject]]
            completion(result,isSuccess)
        }
        
    }
     /// 返回微博的未读数量 - 定时刷新，不需要提示是否失败！
    func unreadCount(completion: @escaping (_ count: Int)->()){
        let uid2: String? = userAccount.uid
        guard let uid = uid2 else {
            return
        }
        let urlString = "https://rm.api.weibo.com/2/remind/unread_count.json"
        
        let params = ["uid": uid]
        
        tokenRequest(URLString: urlString, parameters: params as [String : AnyObject]) { (json, isSuccess) in
            let dict = json as? [String: AnyObject]
            let count = dict?["status"] as? Int
            completion(count ?? 0)
        }
    }
}
// MARK: - 用户信息
extension WBNetworkManager {
    /// 加载当前用户信息 - 用户登录后立即执行
    func loadUserInfo(completion: @escaping (_ dict: [String: AnyObject])->()) {
        
        guard let uid = userAccount.uid else {
            return
        }
        
        let urlString = "https://api.weibo.com/2/users/show.json"
        
        let params = ["uid": uid]
        
        // 发起网络请求
        tokenRequest(URLString: urlString, parameters: params as [String : AnyObject]) { (json, isSuccess) in
            // 完成回调
            completion( (json as? [String: AnyObject]) ?? [:])
        }
    }
}
// MARK: - 发布微博
extension WBNetworkManager {
    
    /// 发布微博
    ///
    /// - parameter text:       要发布的文本
    /// - parameter image:      要上传的图像，为 nil 时，发布纯文本微博
    /// - parameter completion: 完成回调
    func postStatus(text: String, image: UIImage?, completion: @escaping (_ result: [String: AnyObject]?, _ isSuccess: Bool)->()) -> () {
        
        // 1. url
        let urlString: String
        
        // 根据是否有图像，选择不同的接口地址
        if image == nil {
            urlString = "https://api.weibo.com/2/statuses/update.json"
        } else {
            urlString = "https://upload.api.weibo.com/2/statuses/upload.json"
        }
        
        // 2. 参数字典
        let params = ["status": text]
        
        // 3. 如果图像不为空，需要设置 name 和 data
        var name: String?
        var data: Data?
        
        if image != nil {
            name = "pic"
            data = UIImagePNGRepresentation(image!)
        }
        
        // 4. 发起网络请求
        tokenRequest(method: .POST, URLString: urlString, parameters: params as [String : AnyObject], name: name, data: data) { (json, isSuccess) in
            completion(json as? [String: AnyObject], isSuccess)
        }
    }
}




// MARK: - OAuth相关方法
extension WBNetworkManager {
  
    func loadAccessToken(_ code : String , _ completion: @escaping (_ isSuccess: Bool)->()){
        let urlString = "https://api.weibo.com/oauth2/access_token"
        
        let params = ["client_id": WBAppKey,
                      "client_secret": WBAppSecret,
                      "grant_type": "authorization_code",
                      "code": code,
                      "redirect_uri": WBRedirectURI]
        request(method: .POST, URLString:urlString, parameters: params) { (json, isSuccess) in
            self.userAccount.yy_modelSet(with: json as? [String:AnyObject] ?? [:] )
            print(self.userAccount.expires_in)
            
            // 加载当前用户信息
            self.loadUserInfo(completion: { (dict) in
                // 使用用户信息字典设置用户账户信息(昵称和头像地址)
                self.userAccount.yy_modelSet(with: dict)
                
                // 保存模型
                self.userAccount.saveAccount()
                
                print(self.userAccount)
                
                // 用户信息加载完成再，完成回调
                completion(isSuccess)
            })
        }
    }
}


