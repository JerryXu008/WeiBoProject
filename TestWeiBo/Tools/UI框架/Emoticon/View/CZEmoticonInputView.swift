//
//  CZEmoticonInputView.swift
//  BiaoQingTest
//
//  Created by BruceXu on 2019/2/28.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit
/// 可重用的标识符
private let cellId = "cellId"

//表情输入视图
class CZEmoticonInputView: UIView {

    @IBOutlet weak var toolbar: CZEmoticonToolbar!
    @IBOutlet weak var collectionVIew: UICollectionView!
    
    //分页控件
    @IBOutlet weak var pageControl: UIPageControl!
    
    /// 选中表情回调闭包属性
    var selectedEmoticonCallBack: ((_ emoticon: CZEmoticon?)->())?
    //加载返回输入视图
    class func inputView(selectedEmoticon: @escaping (_ emoticon: CZEmoticon?)->()) -> CZEmoticonInputView {
        let nib = UINib(nibName: "CZEmoticonInputView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! CZEmoticonInputView
        // 记录闭包
        v.selectedEmoticonCallBack = selectedEmoticon
        return v
    }
    
    override func awakeFromNib() {
//        let nib = UINib(nibName: "CZEmoticonCell", bundle: nil)
//        collectionVIew.register(nib, forCellWithReuseIdentifier: cellId)
        
        
        collectionVIew.register(CZEmoticonCell.self, forCellWithReuseIdentifier: cellId)
       
        // 设置工具栏代理
        toolbar.delegate = self
        
        // 设置分页控件的图片
        let bundle = CZEmoticonManager.shared.bundle
        
        guard let normalImage = UIImage(named: "compose_keyboard_dot_normal", in: bundle, compatibleWith: nil),
           let selectedImage = UIImage(named: "compose_keyboard_dot_selected", in: bundle, compatibleWith: nil) else {
                return
        }
        
        // 使用填充图片设置颜色
        //        pageControl.pageIndicatorTintColor = UIColor(patternImage: normalImage)
        //        pageControl.currentPageIndicatorTintColor = UIColor(patternImage: selectedImage)
        
        // 使用 KVC 设置私有成员属性
        //UIPageControl.cz_ivarsList()
        pageControl.setValue(normalImage, forKey: "_pageImage")
        pageControl.setValue(selectedImage, forKey: "_currentPageImage")
    }

}

extension CZEmoticonInputView: CZEmoticonToolbarDelegate {
    
    func emoticonToolbarDidSelectedItemIndex(toolbar: CZEmoticonToolbar, index: Int) {
        
        // 让 collectionView 发生滚动 -> 每一个分组的第0页
        let indexPath = IndexPath(item: 0, section: index)
        
        collectionVIew.scrollToItem(at: indexPath, at: .left, animated: true)
        
        // 设置分组按钮的选中状态
        toolbar.selectedIndex = index
    }
}

// MARK: - UICollectionViewDelegate
extension CZEmoticonInputView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 1. 获取中心点
        var center = scrollView.center
        center.x += scrollView.contentOffset.x
        
        // 2. 获取当前显示的 cell 的 indexPath
        let paths = collectionVIew.indexPathsForVisibleItems
        
        // 3. 判断中心点在哪一个 indexPath 上，在哪一个页面上
        var targetIndexPath: IndexPath?
        
        for indexPath in paths {
            
            // 1> 根据 indexPath 获得 cell
            let cell = collectionVIew.cellForItem(at: indexPath)
            
            // 2> 判断中心点位置(cell.frame 很巧妙)
            if cell?.frame.contains(center) == true {
                targetIndexPath = indexPath
                
                break
            }
            print("=====\(cell?.frame)")
        }
        
        guard let target = targetIndexPath else {
            return
        }
        
        // 4. 判断是否找到 目标的 indexPath
        // indexPath.section => 对应的就是分组
        toolbar.selectedIndex = target.section
        
        // 5. 设置分页控件
        // 总页数，不同的分组，页数不一样
        pageControl.numberOfPages = collectionVIew.numberOfItems(inSection: target.section)
        pageControl.currentPage = target.item
        
        
    }
}
//数据源
extension CZEmoticonInputView:UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return CZEmoticonManager.shared.packages.count
    }
    // 返回每个分组中的表情`页`的数量
    // 每个分组的表情包中 表情页面的数量 emoticons 数组 / 20
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return CZEmoticonManager.shared.packages[section].numberOfPages
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 1. 取 cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CZEmoticonCell
        
        // 2. 设置 cell - 传递对应页面的表情数组
        cell.emoticons = CZEmoticonManager.shared.packages[indexPath.section].emoticon(page: indexPath.item)
//
//        // 设置代理 - 不适合用闭包
        cell.delegate = self
        
        // 3. 返回 cell
        return cell
    }
}



// MARK: - CZEmoticonCellDelegate
extension CZEmoticonInputView: CZEmoticonCellDelegate {
    
    /// 选中的表情回调
    ///
    /// - parameter cell: 分页 Cell
    /// - parameter em:   选中的表情，删除键为 nil
    func emoticonCellDidSelectedEmoticon(cell: CZEmoticonCell, em: CZEmoticon?) {
        // print(em)
        
        // 执行闭包，回调选中的表情
        selectedEmoticonCallBack?(em)
        
        // 添加最近使用的表情
        guard let em = em else {
            return
        }
        
        // 如果当前 collectionView 就是最近的分组，不添加最近使用的表情
        let fff = collectionVIew.indexPathsForVisibleItems
        let indexPath = collectionVIew.indexPathsForVisibleItems[0]
        if indexPath.section == 0 {
            return
        }
        
        // 添加最近使用的表情
        CZEmoticonManager.shared.recentEmoticon(em: em)
        
        // 刷新数据 - 第 0 组
        var indexSet = IndexSet()
        indexSet.insert(0)
        
        collectionVIew.reloadSections(indexSet)
    }
}
