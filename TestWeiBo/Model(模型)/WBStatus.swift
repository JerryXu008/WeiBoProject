//
//  WBStatus.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/2/12.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit
import YYModel
class WBStatus: NSObject {
    var id: Int64 = 0
    //微博信息内容
    var text: String?
    
    var user: WBUser?
    
    /// 被转发的原创微博
    var retweeted_status: WBStatus?
    
    /// 转发数
    var reposts_count: Int = 0
    /// 评论数
    var comments_count: Int = 0
    /// 点赞数
    var attitudes_count: Int = 0
   
    /// 微博配图模型数组
    var pic_urls: [WBStatusPicture]?
    
    
    /// 微博创建日期
    var createdDate: Date?
    
    /// 微博来源 - 发布微博使用的客户端
    var source: String? {
        didSet {
            // 重新计算来源并且保存
            // 在 didSet 中，给 source 再次设置值，不会调用 didSet
            source = "来自于 " + (source?.cz_href()?.text ?? "")
        }
    }
    
    /// 微博创建时间字符串
    var created_at: String? {
        didSet {
            createdDate = Date.cz_sinaDate(string: created_at ?? "")
        }
    }
    
    
    
    /// 类函数 -> 告诉第三方框架 YY_Model 如果遇到数组类型的属性，数组中存放的对象是什么类？
    /// NSArray 中保存对象的类型通常是 `id` 类型
    /// OC 中的泛型是 Swift 推出后，苹果为了兼容给 OC 增加的
    /// 从运行时角度，仍然不知道数组中应该存放什么类型的对象
    class func modelContainerPropertyGenericClass() -> [String: AnyClass] {
        return ["pic_urls": WBStatusPicture.self]
    }
    
    override var description: String {
        return yy_modelDescription()
    }
}
