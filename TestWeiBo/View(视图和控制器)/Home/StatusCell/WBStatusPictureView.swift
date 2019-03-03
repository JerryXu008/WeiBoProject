//
//  WBStatusPictureView.swift
//  传智微博
//
//  Created by apple on 16/7/5.
//  Copyright © 2016年 itcast. All rights reserved.
//

import UIKit

class WBStatusPictureView: UIView {
    @IBOutlet weak var heightCons: NSLayoutConstraint!
   
    var viewModel: WBStatusViewModel?
    {
        didSet {
            calcViewSize()
            urls = viewModel?.picURLs
        }
        
    }
    // 根据视图模型的配图视图大小，调整显示内容
     private func calcViewSize() {
       // h处理宽度
        // 1 单图，根据配图视图的大小，修改 subviews[0]的宽高
        if viewModel?.picURLs?.count == 1 {
            let viewSize = viewModel?.pictureViewSize ?? CGSize()
            // 获取第0哥图像视图
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: WBStatusPictureViewOutterMargin, width: viewSize.width, height: viewSize.height - WBStatusPictureViewOutterMargin )
        }
        else {
            // 多图  回复 第一个view的高度，保证九宫格布局的完整
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: WBStatusPictureViewOutterMargin, width: WBStatusPictureItemWidth, height: WBStatusPictureItemWidth)
        }
        //修改高度约束（这玩意控制 cell的高度）
        heightCons.constant = viewModel?.pictureViewSize.height ?? 0
        
        
    }
    /// 配图视图的数组
   var urls: [WBStatusPicture]? {
        didSet {
            
            // 隐藏所有imageview
            for v in subviews {
                v.isHidden = true
            }
            //便利url数组，顺序设置图像
            var index = 0
            for url in urls ?? [] {
              //获得索引的imageview
               let iv  = subviews[index] as! UIImageView
                //4 张图像处理
                if index == 1 && urls?.count == 4 {
                    index += 1
                }
                
               // 设置图像
                iv.cz_setImage(urlString: url.thumbnail_pic, placeholderImage: nil)
                
                // 判断是否是 gif，根据扩展名
                iv.subviews[0].isHidden = (((url.thumbnail_pic ?? "") as NSString).pathExtension.lowercased() != "gif")
                
                //显示图像
                iv.isHidden = false
                
                index += 1
            }
            
        }
    }
    
    override func awakeFromNib() {
        setupUI()
    }
    
    // MARK: - 监听方法
    /// @param selectedIndex    选中照片索引
    /// @param urls             浏览照片 URL 字符串数组
    /// @param parentImageViews 父视图的图像视图数组，用户展现和解除转场动画参照
    @objc func tapImageView(tap: UITapGestureRecognizer) {
        
        guard let iv = tap.view,
            let picURLs = viewModel?.picURLs
            else {
                return
        }
        
        var selectedIndex = iv.tag
        
        // 针对四张图处理
        if picURLs.count == 4 && selectedIndex > 1 {
            selectedIndex -= 1
        }
        
        let urls = (picURLs as NSArray).value(forKey: "largePic") as! [String]
        
        // 处理可见的图像视图数组
        var imageViewList = [UIImageView]()
        
        for iv in subviews as! [UIImageView] {
            
            if !iv.isHidden {
                imageViewList.append(iv)
            }
        }
        
        // 发送通知
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: WBStatusCellBrowserPhotoNotification),
            object: self,
            userInfo: [WBStatusCellBrowserPhotoURLsKey: urls,
                       WBStatusCellBrowserPhotoSelectedIndexKey: selectedIndex,
                       WBStatusCellBrowserPhotoImageViewsKey: imageViewList])
    }
   
}
extension WBStatusPictureView {
    // 1. cell 中所有的控件都提前准备好
    // 2。 设置的时候，根据数据决定是否显示
    // 3. 不要动态创建控件
    func setupUI() {
        
        //设置背景颜色
        backgroundColor = superview?.backgroundColor
        //超出边界的内容不显示
     //   clipsToBounds = true
        
        let count = 3
        let rect = CGRect(x: 0, y: WBStatusPictureViewOutterMargin, width: WBStatusPictureItemWidth, height: WBStatusPictureItemWidth)
        //创建j9个 iamgeview
        for i in 0..<count * count {
            let iv = UIImageView()
            //设置 contentMode 防止拉伸
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            
            //iv.backgroundColor = UIColor.red
            let row = CGFloat(i / count)
            let col = CGFloat(i % count)
            
            let xoffSet = col * (WBStatusPictureItemWidth + WBStatusPictureViewInnerMargin)
            let yoffSet = row * (WBStatusPictureItemWidth + WBStatusPictureViewInnerMargin)
            iv.frame = rect.offsetBy(dx: xoffSet, dy: yoffSet)
            
            addSubview(iv)
            
            // 让 imageView 能够接收用户交互
            iv.isUserInteractionEnabled = true
            // 添加手势识别
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
            
            iv.addGestureRecognizer(tap)
            
            // 设置 imageView 的 tag
            iv.tag = i
            
            addGifView(iv: iv)
        }
    }
    
    /// 向图像视图添加 gif 提示图像
    private func addGifView(iv: UIImageView) {
        
        let gifImageView = UIImageView(image: UIImage(named: "timeline_image_gif"))
        
        iv.addSubview(gifImageView)
        
        // 自动布局
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iv.addConstraint(NSLayoutConstraint(
            item: gifImageView,
            attribute: .right,
            relatedBy: .equal,
            toItem: iv,
            attribute: .right,
            multiplier: 1.0,
            constant: 0))
        iv.addConstraint(NSLayoutConstraint(
            item: gifImageView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: iv,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0))
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


