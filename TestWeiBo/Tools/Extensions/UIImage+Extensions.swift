//
//  UIImage+Extensions.swift
//  传智微博
//
//  Created by 刘凡 on 2016/7/5.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 创建头像图像
    ///
    /// - parameter size:      尺寸
    /// - parameter backColor: 背景颜色
    ///
    /// - returns: 裁切后的图像
    func cz_avatarImage(size: CGSize?, backColor: UIColor = UIColor.white, lineColor: UIColor = UIColor.lightGray) -> UIImage? {
        
        var size = size
        if size == nil {
            size = self.size
        }
        let rect = CGRect(origin: CGPoint(), size: size!)
        //true 表示不透明 false 表示透明 ，不透明性能好，GPU不用进行混合计算
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        //背景颜色填充，因为如果设置为不透明，四个角会变成黑色，不信可以屏蔽试试
        backColor.setFill()
        UIRectFill(rect)
        
        //添加一个圆形，添加一个裁切路径
        let path = UIBezierPath(ovalIn: rect)
        //在这之后，所画的所有图像都是在这个路径里面
        path.addClip()
        
        draw(in: rect)
        
        //画图像边框
        let ovalPath = UIBezierPath(ovalIn: rect)
        ovalPath.lineWidth = 2
        lineColor.setStroke()
        ovalPath.stroke()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result
    }
    
    /// 生成指定大小的不透明图象
    ///
    /// - parameter size:      尺寸
    /// - parameter backColor: 背景颜色
    ///
    /// - returns: 图像
    func cz_image(size: CGSize? = nil, backColor: UIColor = UIColor.white) -> UIImage? {
        
        var size = size
        if size == nil {
            size = self.size
        }
        let rect = CGRect(origin: CGPoint(), size: size!)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        backColor.setFill()
        UIRectFill(rect)
        
        draw(in: rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result
    }
}
