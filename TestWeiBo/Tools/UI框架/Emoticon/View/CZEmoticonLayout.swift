//
//  CZEmoticonLayout.swift
//  BiaoQingTest
//
//  Created by BruceXu on 2019/2/28.
//  Copyright © 2019年 BruceXu. All rights reserved.
//

import UIKit

/// 表情集合视图的布局
class CZEmoticonLayout: UICollectionViewFlowLayout {
    
    /// prepare 就是 OC 中的 prepareLayout
    override func prepare() {
        super.prepare()
        
        // 在此方法中，collectionView 的大小已经确定
        guard let collectionView = collectionView else {
            return
        }
        //每个cell和 collectionview一样大，一个cell放20个表情
        //而不是一个cell放一个表情，因为 水平滚动的时候，cell 为垂直布局，不符合常理
        itemSize = collectionView.bounds.size
        
        //行间距 ,也可以在 xib设置
        minimumLineSpacing = 0
        //格子间距
        minimumInteritemSpacing = 0
        
        // 设定滚动方向
        // 水平方向滚动，cell 垂直方向布局
        // 垂直方向滚动，cell 水平方向布局
        scrollDirection = .horizontal
    }
}
