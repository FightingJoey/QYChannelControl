//
//  QYChannelManage.swift
//  QYChannelControl
//
//  Created by TrinaSolar on 2020/3/30.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

/** 现存问题
 *  1.多种方式弹出
 *  2.定制化Cell及Header
 *  3.拖动到第二栏释放，移动到第二栏（完成）
 *  4.支持多个组
 *  5.保存选中（完成）
 *  6.是否全屏
 *  7.支持自定义Cell
 */

import UIKit

typealias QYChannelBlock = (Array<String>, Array<String>, Int) -> ()

enum QYChannelModalType {
    case push
    case fromBottom
    case fromTop
    case fromLeft
}

struct QYChannelConfig {
    // 菜单列数
    var columns: Int = 3
    // 横向和纵向的间距
    var cellSpacingH: CGFloat = 10.0
    var cellSpacingV: CGFloat = 10.0
    // headerView高度
    var headerHeight: CGFloat = 44.0
    
    var fixedNum: Int = 2
    
    init() {}
}

class QYChannelManage: NSObject {
    
    static let shared = QYChannelManage()
    
    private lazy var nav: UINavigationController = {
        let nav = UINavigationController(rootViewController: UIViewController())
        nav.navigationBar.tintColor = .black
        return nav
    }()
    
    private var channelView: QYChannelView?
    
    private var backBlock: QYChannelBlock?
    
    private var backIndex: Int = 0
    
    var config: QYChannelConfig = QYChannelConfig() {
        didSet {
            channelView = nil
            setup()
        }
    }

    override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        channelView = QYChannelView(frame: UIScreen.main.bounds, config: config)
        channelView?.clickIndexBlock = { (index) in
            self.backIndex = index
            self.goBack()
        }
        channelView?.updateCurrentIndexBlock = { (index) in
            self.backIndex = index
        }
        nav.topViewController?.title = "频道管理"
        nav.topViewController?.view = channelView
        nav.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(goBack))
    }
    
    @objc private func goBack() {
        UIView.animate(withDuration: 0.25, animations: {
            var frame = self.nav.view.frame
            frame.origin.y = frame.origin.y - self.nav.view.bounds.size.height
            self.nav.view.frame = frame
        }) { (finished) in
            self.nav.view.removeFromSuperview()
        }
        if let block = backBlock {
            block(channelView!.selectedArr, channelView!.recommendArr, backIndex)
        }
    }
    
    func show(enabledTitles: Array<String>, disableTitles: Array<String>, currentIndex: Int, finish: @escaping QYChannelBlock) {
        backBlock = finish
        channelView?.isEditing = false
        channelView?.selectedArr = enabledTitles
        channelView?.recommendArr = disableTitles
        channelView?.selectIndex = currentIndex
        channelView?.reloadData()
        
        var frame = nav.view.frame
        frame.origin.y = frame.origin.y - nav.view.bounds.size.height
        nav.view.frame = frame
        nav.view.alpha = 0
        UIApplication.shared.keyWindow?.addSubview(nav.view)
        UIView.animate(withDuration: 0.25) {
            self.nav.view.alpha = 1
            self.nav.view.frame = UIScreen.main.bounds
        }
    }
    
}
