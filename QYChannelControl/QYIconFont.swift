//
//  QYIconFont.swift
//  CaiLiFang
//
//  Created by TrinaSolar on 2020/3/31.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import Foundation

import UIKit
import CoreText

let icon_add = QYIconFont(code: "\u{e7b0}", desc: "添加")
let icon_close = QYIconFont(code: "\u{e747}", desc: "关闭")

struct QYIconFont {
    var code: String      // 标准解析格式 比如："\u{a62b}"
    var desc: String      // 图标作用和备注

    init(code: String, desc: String) {
        self.code = code
        self.desc = desc
    }
    
    static func image(code: String, fontSize: CGFloat, color: UIColor) -> UIImage {
        let nscode = code as NSString
        guard let font = UIFont(name: "IconFont", size: fontSize) else {
            return UIImage()
        }
        let rect = nscode.boundingRect(with:CGSize(width: 0.0, height: 0.0) , options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        let size = rect.size
        print("建议图片大小：\(size)") //建议UIImageView大小参考打印值
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        label.font = font
        label.textAlignment = .center
        label.text = code
        label.textColor = color
        if let context = UIGraphicsGetCurrentContext() {
            label.layer.render(in: context)
        }
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return UIImage()
    }
}

extension UILabel{
    /**
     生成IconFont Label
    */
    convenience init(frame: CGRect = CGRect.zero, fontSize: CGFloat) {
        self.init(frame: frame)
        self.font = UIFont(name: "IconFont", size: fontSize)
        self.textAlignment = .center
    }
}
