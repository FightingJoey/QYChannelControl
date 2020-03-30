//
//  ViewController.swift
//  QYChannelControl
//
//  Created by TrinaSolar on 2020/3/29.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var pageV: QYChannelControlViewController?

    var datas: Array<String> = ["要闻","河北","财经","娱乐","体育","社会","NBA","视频","汽车","图片","科技","军事"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(type: .system)
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        btn.addTarget(self, action: #selector(updateData), for: .touchUpInside)
        
        pageV = QYChannelControlViewController()
        pageV?.view.frame = view.bounds
        pageV?.dataSource = self
        pageV?.customBtn(btn)
        addChild(pageV!)
        view.addSubview(pageV!.view)
        
    }
    
    @objc func updateData() {
        datas = ["娱乐","体育","视频","汽车","社会","NBA","要闻","河北","财经","图片","科技","军事"]
        pageV?.reloadData()
    }

}

extension ViewController: QYChannelControlViewControllerDataSource {
    func viewControllerFor(index: Int) -> UIViewController {
        let view = TestViewController()
        view.title = datas[index]
        return view
    }
    
    func channelFor(index: Int) -> String {
        return datas[index]
    }
    
    func numberOfChannels() -> Int {
        return datas.count
    }
    
    
}

