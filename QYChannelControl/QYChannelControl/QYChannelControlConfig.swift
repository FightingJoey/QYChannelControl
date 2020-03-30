//
//  QYChannelControlConfig.swift
//  QYChannelControl
//
//  Created by TrinaSolar on 2020/3/29.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit

/**
标题对齐，居左，居中，局右
*/
enum QYChannelTitleAlignment {
    case left
    case center
    case right
}

/**
文字垂直对齐，居中，居上，局下
*/
enum QYChannelTitleVerticalAlignment {
    case top
    case center
    case bottom
}

/**
阴影末端形状，圆角、直角
*/
enum QYChannelListViewShadowLineCap {
    case round
    case square
}

/**
 阴影对齐
 */
enum QYChannelListViewShadowLineAlignment {
    case top
    case center
    case bottom
    case titleBottom
    case titleTop
}

/**
阴影动画类型，平移、缩放、无动画
*/
enum QYChannelListViewShadowLineAnimationType {
    case pan
    case zoom
    case none
}

enum QYChannelListViewSelectionShadowWidthStyle {
    case dynamic // Selection shadow is equal to the segment's label width.
    case fixed // Selection shadow is equal to the full width of the segment.
    case custom // Selection shadow width is customed
}

struct QYChannelControlConfig {
    /**
    标题正常颜色 默认 grayColor
    */
    var titleNormalColor: UIColor = .gray
    /**
    标题选中颜色 默认 blackColor
    */
    var titleSelectedColor: UIColor = .black
    /**
    标题正常字体 默认 标准字体18
    */
    lazy var titleNormalFont: UIFont = {
        return UIFont.systemFont(ofSize: 18)
    }()
    /**
    标题选中字体 默认 标准粗体18
    */
    lazy var titleSelectedFont: UIFont = {
        return UIFont.boldSystemFont(ofSize: 18)
    }()
    /**
    标题间距 默认 10
    */
    var titleSpace: CGFloat = 10
    /**
    标题宽度 默认 文字长度
    */
    var titleWidth: CGFloat = 0
    /**
    标题颜色过渡开关 默认 开
    */
    var isTitleColorTransition: Bool = true
    /**
    文字垂直对齐 默认居中
    */
    var textVerticalAlignment: QYChannelTitleVerticalAlignment = .center
    /**
    标题栏显示位置 默认居左（只在标题总长度小于屏幕宽度时有效）
    */
    var channelListViewAlignment: QYChannelTitleAlignment = .left
    /**
    标题栏高度 默认 44
    */
    var channelListViewHeight: CGFloat = 40
    /**
    标题栏背景色 默认 透明
    */
    var channelListViewBackgroundColor: UIColor = .clear
    /**
    标题栏内容缩进 默认 UIEdgeInsetsMake(0, 10, 0, 10)
    */
    var channelListViewInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    /**
    是否在NavigationBar上显示标题栏 默认NO
    */
    var isShowTitleInNavigationBar: Bool = true
    /**
    隐藏底部阴影 默认 NO
    */
    var isShadowLineHidden: Bool = false
    /**
    阴影高度 默认 3.0f
    */
    var shadowLineHeight: CGFloat = 3.0
    /**
     阴影宽度 默认 30.0f
     */
    var shadowLineWidth: CGFloat = 30.0
    /**
    阴影颜色 默认 黑色
    */
    var shadowLineColor: UIColor = .black
    /**
    阴影末端形状 默认圆角
    */
    var shadowLineCap: QYChannelListViewShadowLineCap = .round
    /**
    阴影动画效果 默认平移
    */
    var shadowLineAnimationType: QYChannelListViewShadowLineAnimationType = .zoom
    /**
    阴影对齐 默认底部
    */
    var shadowLineAlignment: QYChannelListViewShadowLineAlignment = .bottom
    /**
    隐藏底部分割线 默认 NO
    */
    var isSeparatorLineHidden: Bool = false
    /**
    底部分割线高度 默认 0.5
    */
    var separatorLineHeight: CGFloat = 0.5
    /**
    底部分割线颜色 默认 lightGrayColor
    */
    var separatorLineColor: UIColor = .lightGray
    
    init() {}
}
