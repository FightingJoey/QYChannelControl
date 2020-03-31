//
//  TestViewController.swift
//  QYChannelControl
//
//  Created by TrinaSolar on 2020/3/30.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let label = UILabel()
        label.text = markTitle
        label.textColor = UIColor.black
        label.frame = CGRect(x: 100, y: 100, width: 200, height: 100)
        view.addSubview(label)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
