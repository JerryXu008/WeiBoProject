//
//  CZEmoticonPackage.swift
//  004-表情包数据
//
//  Created by apple on 16/7/10.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit
import YYModel

/// 表情包模型
class CZEmoticonPackage: NSObject {

    /// 表情包的分组名
    var groupName: String?
    /// 背景图片名称
    var bgImageName: String?
    
    /// 表情包目录，从目录下加载 info.plist 可以创建表情模型数组
    var directory: String? {
        didSet {
            // 当设置目录时，从目录下加载 info.plist
            guard let directory = directory,
                let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
               let bundle = Bundle(path: path),
                let infoPath = bundle.path(forResource: "info.plist", ofType: nil, inDirectory: directory),
                let array = NSArray(contentsOfFile: infoPath) as? [[String: String]],
                let models = NSArray.yy_modelArray(with: CZEmoticon.self, json: array) as? [CZEmoticon]
            
                else {
                return
            }
            
            // 遍历 models 数组，设置每一个表情符号的目录
            for m in models {
                m.directory = directory
            }
            
            // 设置表情模型数组
            emoticons += models
        }
    }
    
    /// 懒加载的表情模型的空数组
    /// 使用懒加载可以避免后续的解包
    lazy var emoticons = [CZEmoticon]()
    
    /// 表情页面数量
    var numberOfPages: Int {
        return (emoticons.count - 1) / 20 + 1
    }
    
    /// 从懒加载的表情包中，按照 page 截取最多 20 个表情模型的数组
    /// 例如有 26 个表情
    /// page == 0，返回 0~19 个模型
    /// page == 1，返回 20~25 个模型
    func emoticon(page: Int) -> [CZEmoticon] {
        
        // 每页的数量
        let count = 20
        let location = page * count
        var length = count
        
        // 判断数组是否越界
        if location + length > emoticons.count {
            length = emoticons.count - location
        }
        
        let range = NSRange(location: location, length: length)
        
        // 截取数组的子数组
        let subArray = (emoticons as NSArray).subarray(with: range)
        
        return subArray as! [CZEmoticon]
    }
    
    override var description: String {
        return yy_modelDescription()
    }
}
