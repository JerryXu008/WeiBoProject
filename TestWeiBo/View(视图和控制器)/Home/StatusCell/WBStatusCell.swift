//
//  WBStatusCell.swift
//  TestWeiBo
//
//  Created by BruceXu on 2019/2/17.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit
/// 微博 Cell 的协议
/// 如果需要设置可选协议方法
/// - 需要遵守 NSObjectProtocol 协议
/// - 协议需要是 @objc 的
/// - 方法需要 @objc optional
@objc protocol WBStatusCellDelegate: NSObjectProtocol {
    
    /// 微博 Cell 选中 URL 字符串
    @objc optional func statusCellDidSelectedURLString(cell: WBStatusCell, urlString: String)
}

class WBStatusCell: UITableViewCell {
    /// 代理属性
    weak var delegate: WBStatusCellDelegate?
    
    //微博视图模型
    var viewModel: WBStatusViewModel? {
        didSet {
            //正文文字
            statusLabel.attributedText = viewModel?.statusAttrText
            // 设置被转发文字
            retweetedLabel?.attributedText = viewModel?.retweetedAttrText
          
            nameLabel.text = viewModel?.status.user?.screen_name
            //设置会员图标
            memberIconView.image = viewModel?.memberIcon
            //认证图标
            vipIconView.image = viewModel?.vipIcon
            //用户头像
            iconView.cz_setImage(urlString: viewModel?.status.user?.profile_image_url, placeholderImage: UIImage(named: "avatar_default_big"), isAvatar: true)
            
            //底部工具栏
            toolBar.viewModel = viewModel
            
            //测试修改配图高度
           // pictureVIew.heightCons.constant = viewModel?.pictureViewSize.height ?? 0
            
            
            
//            //测试4张图片
//            if viewModel?.status.pic_urls?.count ?? 0  > 4 {
//                var picURLs = viewModel?.status.pic_urls
//                picURLs!.removeSubrange((picURLs!.startIndex + 4)..<picURLs!.endIndex)
//                 pictureVIew.urls = picURLs
//            }
//            else {
//
//                //配图数组设置
//                pictureVIew.urls = viewModel?.status.pic_urls
//            }
            //配图数组设置
         //   pictureVIew.urls = viewModel?.picURLs //原创或者被转发的配图
           
             pictureVIew.viewModel = viewModel
          
            
            // 设置来源
            sourceLabel.text = viewModel?.status.source
            
            // 设置时间
            timeLabel.text = viewModel?.status.createdDate?.cz_dateDescription
          
            
            //设置微博文本代理
            statusLabel?.delegate2 = self
            retweetedLabel?.delegate2 = self
            
            //print(">>>>>>>>>>>>>>>>>AAA=\(retweetedLabel?.delegate2)")
            // print(">>>>>>>>>>>>>>>>>BBB=\(self)")
        }
    }
    
    //正文
    @IBOutlet weak var statusLabel: FFLabel!
   // 头像
    @IBOutlet weak var iconView: UIImageView!
    //会员图标
    @IBOutlet weak var memberIconView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    //认证图标
    @IBOutlet weak var vipIconView: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
  
    //底部视图
    @IBOutlet weak var toolBar: WBStatusToolBar!
    //o配图视图
    @IBOutlet weak var pictureVIew: WBStatusPictureView!
   
    @IBOutlet weak var pictureTopCons: NSLayoutConstraint!
    
     ///被转发微博的标签 - 原创微博没有此空间，用问号
    
    @IBOutlet weak var retweetedLabel: FFLabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // 离屏渲染 - 异步绘制
        self.layer.drawsAsynchronously = true
        
        // 栅格化 - 异步绘制之后，会生成一张独立的图像，cell在屏幕上滚动的时候，本质上滚动的是这张图片
        // cell 优化，要尽量减少图层的数量，相当于就只有一层！
        // 停止滚动之后，可以接收监听
        self.layer.shouldRasterize = true
        
        // 使用 `栅格化` 必须注意指定分辨率
        self.layer.rasterizationScale = UIScreen.main.scale
   
        //设置微博文本代理
         statusLabel?.delegate2 = self
         retweetedLabel?.delegate2? = self
        
    }

    

}
extension WBStatusCell: FFLabelDelegate {
    
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        
        // 判断是否是 URL
        if !text.hasPrefix("http://") {
            return
        }
        
        // 插入 ? 表示如果代理没有实现协议方法，就什么都不做
        // 如果使用 !，代理没有实现协议方法，仍然强行执行，会崩溃！
        delegate?.statusCellDidSelectedURLString?(cell: self, urlString: text)
    }
}
