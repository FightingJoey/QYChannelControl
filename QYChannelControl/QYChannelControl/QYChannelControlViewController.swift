//
//  QYChannelControlViewController.swift
//  QYChannelControl
//
//  Created by TrinaSolar on 2020/3/29.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit

protocol QYChannelControlViewControllerDataSource: NSObjectProtocol {
    func viewControllerFor(index: Int) -> UIViewController
    func channelFor(index: Int) -> String
    func numberOfChannels() -> Int
}

class QYChannelControlViewController: UIViewController {
    
    var config: QYChannelControlConfig = QYChannelControlConfig()
    
    var dataSource: QYChannelControlViewControllerDataSource?
    
    var defaultIndex: Int = 0
    
    // 频道列表View
    private var channelListView: QYChannelListView?
    // 分页控制器
    private var pageVC: UIPageViewController?
    // pageViewController内部的scrollView
    private var scrollV: UIScrollView?
    // 显示过的vc列表，用于视图控制器缓存
    private var showedVCList: Array<UIViewController> = []
    // 当前选中的index
    private var selectedIndex: Int = 0 {
        didSet {
            channelListView?.selectedIndex = self.selectedIndex
        }
    }
    // 频道列表
    private var channelList: Array<String> = []
    // 是否已经加载
    private var isLoaded: Bool = false
    
    //MARK: Life Style
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelListView = QYChannelListView(config: config)
        channelListView?.delegate = self
        view.addSubview(channelListView!)
        
        pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC?.delegate = self
        pageVC?.dataSource = self
        view.addSubview(pageVC!.view)
        addChild(pageVC!)
        
        pageVC?.view.subviews.forEach({ (view) in
            if view.isKind(of: UIScrollView.self) {
                self.scrollV = (view as! UIScrollView)
                self.scrollV?.delegate = self
            }
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if config.isShowTitleInNavigationBar {
            parent?.navigationItem.titleView = channelListView
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (!isLoaded) {
            // 设置加载标记为已加载
            isLoaded = true;
            
            // 修正UI
            channelListView?.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: config.channelListViewHeight)
            pageVC?.view.frame = CGRect(x: 0, y: config.channelListViewHeight, width: view.bounds.size.width, height: view.bounds.size.height-config.channelListViewHeight)
            
            // 初始化频道列表
            channelList.removeAll()
            for i in 0..<numberOfChannels() {
                channelList.append(channelFor(index: i))
            }
            
            // 移动到默认Index
            moveTo(index: defaultIndex, animated: false)
        }
    }
    
    //MARK: Public Method
    
    func reloadData(moveToIndex: Int = 0) {
        // 先修正UI，再刷新数据
        channelListView?.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: config.channelListViewHeight)
        pageVC?.view.frame = CGRect(x: 0, y: config.channelListViewHeight, width: view.bounds.size.width, height: view.bounds.size.height-config.channelListViewHeight)
        
        // 刷新频道列表View
        channelListView?.reloadData()
        
        // 刷新频道列表
        channelList.removeAll()
        for i in 0..<numberOfChannels() {
            channelList.append(channelFor(index: i))
        }
        
        // 移动到对应Index
        if moveToIndex < 0 || moveToIndex > numberOfChannels() {
            return
        }
        moveTo(index: moveToIndex, animated: true)
        channelListView?.isStopAnimation = true
    }
    
    func customBtn(_ btn: UIButton, isRight: Bool = true) {
        if isRight {
            channelListView?.rightBtn = btn
        } else {
            channelListView?.leftBtn = btn
        }
    }
    
    //MARK: Private Method
    
    private func moveTo(index: Int, animated: Bool) {
        if numberOfChannels() == 0 || index >= numberOfChannels() { return }
        selectedIndex = index
        if let last = channelListView?.lastSelected {
            let direction = last > selectedIndex ? UIPageViewController.NavigationDirection.reverse : UIPageViewController.NavigationDirection.forward
            // 获取Index对应的ViewController
            if let viewC = viewControllerFor(index: index) {
                
                // pageViewController设置当前viewcontrollers
                pageVC?.setViewControllers([viewC], direction: direction, animated: true, completion: { (finished) in
                    
                })
                
                // 添加遮罩，防止在页面切换时，触摸导致的问题
                let maskView = UIView(frame: view.bounds)
                maskView.backgroundColor = UIColor.clear
                view.addSubview(maskView)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    maskView.removeFromSuperview()
                }
            }
        }
    }

    private func viewControllerFor(index: Int) -> UIViewController? {
        if index < 0 || index >= numberOfChannels() { return nil }
        
        // 获取当前VC
        let currentVC = pageVC?.viewControllers?.first
        let currentTitle = currentVC?.title
        let targetTitle = channelFor(index: index)
        if let title = currentTitle, title == targetTitle {
            return currentVC
        }
        
        // 去缓存中查找是否显示过，如果之前显示过，则从内存中读取
        for vc in showedVCList {
            if let title = vc.title, title == targetTitle {
               return vc
            }
        }
        
        // 获取Index对应的ViewController
        if let viewC = dataSource?.viewControllerFor(index: index) {
            viewC.title = channelFor(index: index)
            showedVCList.append(viewC)
            addChild(viewC)
            return viewC
        }
        print("selected %ld", selectedIndex)
        print("index - %d", index)
        return nil
    }
    
    func numberOfChannels() -> Int {
        return dataSource?.numberOfChannels() ?? 0
    }
    
    func channelFor(index: Int) -> String {
        return dataSource?.channelFor(index: index) ?? ""
    }
}

//MARK: UIPageViewControllerDataSource && UIPageViewControllerDelegate

extension QYChannelControlViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // pageViewController即将滚动
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // pageViewController滚动结束
        if (!completed) { return }
        if (!finished) { return }
        
        if let vc = pageViewController.viewControllers?.first {
            // 获取到当前VC并判断其title是否在频道列表内，若存在，则获取其在频道列表中的下标
            if let selectIndex = channelList.firstIndex(of: vc.title ?? "") {
                if selectIndex < channelList.count && selectIndex >= 0 {
                    // 设置当前选中的Index
                    selectedIndex = selectIndex
                }
            }
        }
    }
}

extension QYChannelControlViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControllerFor(index: selectedIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControllerFor(index: selectedIndex + 1)
    }
}

//MARK: UIScrollViewDelegate

extension QYChannelControlViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x - scrollView.bounds.size.width
        channelListView?.showAnimationWith(progress: Float(value/scrollView.bounds.size.width))
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        channelListView?.isStopAnimation = false
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        channelListView?.isStopAnimation = false
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        channelListView?.isStopAnimation = false
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        channelListView?.isStopAnimation = false
    }
}

//MARK: QYChannelListViewDelegate

extension QYChannelControlViewController: QYChannelListViewDelegate {
    func didSelected(index: Int) {
        moveTo(index: index, animated: true)
    }
    
    func channelWith(index: Int) -> String {
        return channelFor(index: index)
    }
    
    func numberOfChannelList() -> Int {
        return numberOfChannels()
    }
}

