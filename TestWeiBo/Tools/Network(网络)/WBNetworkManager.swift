//
//  WBNetworkManager.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/2/12.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit
import AFNetworking
enum WBHTTPMethod {
    case GET
    case POST
}
/**
 - 如果日常开发中，发现网络请求返回的状态码是 405，不支持的网络请求方法
 - 首先应该查找网路请求方法是否正确
 */
class WBNetworkManager: AFHTTPSessionManager {

    /// 静态区／常量／闭包
    /// 在第一次访问时，执行闭包，并且将结果保存在 shared 常量中
    static let shared: WBNetworkManager = {
        let instance = WBNetworkManager()
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        return instance
    }()
    lazy var userAccount = WBUserAccount()
    
    /// 用户登录标记[计算型属性]
    var userLogon: Bool {
        return userAccount.access_token != nil
    }
    
//    //token 访问令牌
//    var access_token: String? //= "2.00fVB6dHrsgOiB7d8179cb30E1OOrB"
   
    
    
    /// 专门负责拼接token的网络请求方法
    /// 专门负责拼接 token 的网络请求方法
    ///
    /// - parameter method:     GET / POST
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter name:       上传文件使用的字段名，默认为 nil，不上传文件
    /// - parameter data:       上传文件的二进制数据，默认为 nil，不上传文件
    /// - parameter completion: 完成回调
    func tokenRequest(method: WBHTTPMethod = .GET,URLString: String,parameters: [String: AnyObject]?, name: String? = nil, data: Data? = nil,
                      competion:@escaping (_ json: Any?, _ isSuccess: Bool)->()){
         //判断token是否为nil
        guard let token = userAccount.access_token else {
            print("没有 token，需要登录")
             //  发送通知
             NotificationCenter.default.post(name: Notification.Name(rawValue: WBUserShouldLoginNotification), object: nil)
            competion(nil,false)
            return
        }
        //判断字典是否存在
        var parameters = parameters
        if parameters == nil
        {
            parameters = [String: AnyObject]()
        }
        parameters!["access_token"] = token as AnyObject
        // 3> 判断 name 和 data
        if let name = name, let data = data {
            // 上传文件
            upload(URLString: URLString, parameters: parameters, name: name, data: data, completion: competion)
        } else {
            //真正网络请求
            request(method: method,URLString: URLString, parameters: parameters, competion: competion)
        }
     
        
    }
    // MARK: - 封装 AFN 方法
    /// 上传文件必须是 POST 方法，GET 只能获取数据
    /// 封装 AFN 的上传文件方法
    ///
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter name:       接收上传数据的服务器字段(name - 要咨询公司的后台) `pic`
    /// - parameter data:       要上传的二进制数据
    /// - parameter completion: 完成回调
    func upload(URLString: String, parameters: [String: AnyObject]?, name: String, data: Data, completion: @escaping (_ json: Any?,_ isSuccess: Bool)->()) {
        
        post(URLString, parameters: parameters, constructingBodyWith: { (formData) in
            
            // 创建 formData
            /**
             1. data: 要上传的二进制数据
             2. name: 服务器接收数据的字段名
             3. fileName: 保存在服务器的文件名，大多数服务器，现在可以乱写
             很多服务器，上传图片完成后，会生成缩略图，中图，大图...
             4. mimeType: 告诉服务器上传文件的类型，如果不想告诉，可以使用 application/octet-stream
             image/png image/jpg image/gif
             */
            formData.appendPart(withFileData: data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
            
        }, progress: nil, success: { (_, json) in
            
            completion(json, true)
      
        }) { (task, error) in
            
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("Token 过期了")
                
                // 发送通知，提示用户再次登录(本方法不知道被谁调用，谁接收到通知，谁处理！)
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: WBUserShouldLoginNotification),
                    object: "bad token")
            }
            
            print("网络请求错误 \(error)")
            
            completion(nil,false)
        }
    }
    ///网络请求
    /// 封装 AFN 的 GET / POST 请求
    ///
    /// - parameter method:     GET / POST
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter completion: 完成回调[json(字典／数组), 是否成功]
    
    func request(method: WBHTTPMethod = .GET,URLString: String,parameters: [String: Any]?,
                 competion:@escaping (_ json: Any?, _ isSuccess: Bool)->()) {
        let success = {(task: URLSessionDataTask , json : Any?)->() in
             competion(json,true)
        }
        let failure = {(task: URLSessionDataTask?, error: Error)->() in
            //针对403 处理token过期
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("token 过期了")
                //  发送通知
                NotificationCenter.default.post(name: Notification.Name(rawValue: WBUserShouldLoginNotification), object: "bad token")
            }
            competion(nil,false)
        }
        if method == .GET {
            get(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
        else {
            post(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
}























