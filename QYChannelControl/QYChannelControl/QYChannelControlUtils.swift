//
//  QYChannelControlUtils.swift
//  QYChannelControl
//
//  Created by TrinaSolar on 2020/3/29.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit

struct QYChannelControlUtils {
    
    // 文字宽度
    static func width(text: String, font: UIFont, size: CGSize) -> CGFloat {
        let options: NSStringDrawingOptions = .usesLineFragmentOrigin
        let attributes = [NSAttributedString.Key.font : font]
        let rect: CGRect = text.boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return rect.width
    }
    
    // 颜色过渡
    static func colorTransform(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        var pro = progress >= 1 ? 1 : progress
        pro = progress <= 0 ? 0 : progress
        var fromComponents = from.cgColor.components
        var toComponents = to.cgColor.components
        let fromColorNum = from.cgColor.numberOfComponents
        let toColorNum = to.cgColor.numberOfComponents
        if fromColorNum == 2 {
            if let white = fromComponents?.first {
                let fromColor = UIColor(red: white, green: white, blue: white, alpha: 1)
                fromComponents = fromColor.cgColor.components
            }
        }
        if toColorNum == 2 {
            if let white = toComponents?.first {
                let toColor = UIColor(red: white, green: white, blue: white, alpha: 1)
                toComponents = toColor.cgColor.components
            }
        }
        let red = fromComponents![0]*(1-pro) + toComponents![0]*pro
        let green = fromComponents![1]*(1-pro) + toComponents![1]*pro
        let blue = fromComponents![2]*(1-pro) + toComponents![2]*pro
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    // 执行阴影动画
    static func showAnimation(shadow: UIView, shadowWidth: CGFloat, from: CGRect, to: CGRect, type: QYChannelListViewShadowLineAnimationType, progress: CGFloat) {
        switch type {
        case .none:
            return
        case .pan:
            let distance = to.midX - from.midX
            let centerX = from.midX + CGFloat(fabsf(Float(progress)))*distance
            shadow.center = CGPoint(x: centerX, y: shadow.center.y)
        case .zoom:
            var distance = CGFloat(fabsf(Float(to.midX))) - from.midX
            distance = CGFloat(fabsf(Float(distance)))
            let fromX = from.midX - shadowWidth/2.0
            let toX = to.midX - shadowWidth/2.0
            if progress > 0 { // 向右移动
                // 前半段0~0.5，x不变，w变大
                if progress <= 0.5 {
                    // 让过程变成0~1
                    let newPro = 2*CGFloat(fabsf(Float(progress)))
                    let newWidth = shadowWidth + newPro * distance
                    var shadowFrame = shadow.frame
                    shadowFrame.size.width = newWidth
                    shadowFrame.origin.x = fromX
                    shadow.frame = shadowFrame
                } else {
                    // 后半段0.5~1，x变大 w变小
                    // 让过程变成1~0
                    let newPro = 2*(1-CGFloat(fabsf(Float(progress))))
                    let newWidth = shadowWidth + newPro * distance
                    let newX = toX - newPro * distance
                    var shadowFrame = shadow.frame
                    shadowFrame.size.width = newWidth
                    shadowFrame.origin.x = newX
                    shadow.frame = shadowFrame
                }
            } else { // 向左移动
                // 前半段0~0.5，x变小，w变大
                if progress >= -0.5 {
                    // 让过程变成0~1
                    let newPro = 2*CGFloat(fabsf(Float(progress)))
                    let newWidth = shadowWidth + newPro * distance
                    let newX = fromX - newPro * distance
                    var shadowFrame = shadow.frame
                    shadowFrame.size.width = newWidth
                    shadowFrame.origin.x = newX
                    shadow.frame = shadowFrame
                } else {
                    // 后半段0.5~1，x变大 w变小
                    // 让过程变成1~0
                    let newPro = 2*(1-CGFloat(fabsf(Float(progress))))
                    let newWidth = shadowWidth + newPro * distance
                    var shadowFrame = shadow.frame
                    shadowFrame.size.width = newWidth
                    shadowFrame.origin.x = toX
                    shadow.frame = shadowFrame
                }
            }
        }
    }

}
