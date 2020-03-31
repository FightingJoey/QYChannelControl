//
//  QYChannelView.swift
//  QYChannelControl
//
//  Created by TrinaSolar on 2020/3/31.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit

private let QYChannelViewCellIdentifier = "QYChannelViewCellIdentifier"
private let QYChannelViewHeaderIdentifier = "QYChannelViewHeaderIdentifier"

let QYSCREEN_WIDTH = UIScreen.main.bounds.size.width
let QYSCREEN_HEIGHT = UIScreen.main.bounds.size.height

func QYRGBColor(_ rgbValue: UInt) -> UIColor {
    return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8)/255.0, blue: CGFloat(rgbValue & 0x0000FF)/255.0, alpha: 1.0)
}

class QYChannelView: UIView {

    private var config: QYChannelConfig = QYChannelConfig()
    
    var clickIndexBlock: ((_ index: Int) -> ())?
    
    var updateCurrentIndexBlock: ((_ index: Int) -> ())?
    
    var titleArr = ["我的频道", "推荐频道"]
    
    var subTitleArr = [["点击进入频道","拖拽可以排序"],["点击添加频道"]]
    
    var selectedArr = ["推荐","河北","财经","娱乐","体育","社会","NBA","视频","汽车","图片","科技","军事","国际","数码","星座","电影","时尚","文化","游戏","教育","动漫","政务","纪录片","房产","佛学","股票","理财"]

    var recommendArr = ["有声","家居","电竞","美容","电视剧","搏击","健康","摄影","生活","旅游","韩流","探索","综艺","美食","育儿"]
    
    var isEditing: Bool = false {
        didSet {
            if !isEditing {
                // 当前不在编辑状态，找到与selectIndexTitle相等的cell
                if let indexPathList = collectionView?.indexPathsForVisibleItems {
                    for indexP in indexPathList {
                        if let cell = collectionView?.cellForItem(at: indexP) as? QYChannelViewCell, let title = cell.title {
                            if title == selectIndexTitle {
                                // 如果该cell在第二组，则重设selectIndex为0
                                selectIndex = indexP.section == 0 ? indexP.item : 0
                                selectIndexTitle = selectedArr[selectIndex]
                                if let block = updateCurrentIndexBlock {
                                    block(selectIndex)
                                }
                                collectionView?.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    var selectIndex: Int = 0 {
        didSet {
            if selectIndex < selectedArr.count {
                selectIndexTitle = selectedArr[selectIndex]
            }
        }
    }
    
    var selectIndexTitle: String = ""
    
    var indexPath: IndexPath?
    
    var targetIndexPath: IndexPath?
    
    var collectionView: UICollectionView?
    
    var dragingItem: QYChannelViewCell?
        
    init(frame: CGRect, config: QYChannelConfig = QYChannelConfig()) {
        super.init(frame: frame)
        
        self.config = config
        
        backgroundColor = UIColor.white
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let cellWidth = (frame.size.width - CGFloat((config.columns + 1)) * config.cellSpacingH) / CGFloat(config.columns) - 1
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth/5*2)
        flowLayout.sectionInset = UIEdgeInsets(top: config.cellSpacingV, left: config.cellSpacingH, bottom: config.cellSpacingV, right: config.cellSpacingH)
        flowLayout.minimumLineSpacing = config.cellSpacingV
        flowLayout.minimumInteritemSpacing = config.cellSpacingH
        flowLayout.headerReferenceSize = CGSize(width: frame.size.width, height: config.headerHeight)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.register(QYChannelViewCell.self, forCellWithReuseIdentifier: QYChannelViewCellIdentifier)
        collectionView?.register(QYChannelHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: QYChannelViewHeaderIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        longPress.minimumPressDuration = 0.25
        collectionView?.addGestureRecognizer(longPress)
        addSubview(collectionView!)
        
        dragingItem = QYChannelViewCell(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellWidth/5*2))
        dragingItem?.isHidden = true
        dragingItem?.isEditing = true
        collectionView?.addSubview(dragingItem!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        collectionView?.reloadData()
    }
    
    @objc private func longPressGesture(_ tap: UILongPressGestureRecognizer) {
        if !isEditing {
            isEditing = !isEditing
            if let cells = collectionView?.visibleCells {
                for cell in cells {
                    if let c = cell as? QYChannelViewCell {
                        c.isEditing = isEditing
                        c.isSelect = false
                    }
                }
            }
            if let header = collectionView?.dataSource?.collectionView?(collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? QYChannelHeaderView {
                header.button.isSelected = isEditing
            }
        }
        let point = tap.location(in: collectionView!)
        switch tap.state {
            case UIGestureRecognizerState.began:
                dragBegan(point: point)
            case UIGestureRecognizerState.changed:
                drageChanged(point: point)
            case UIGestureRecognizerState.ended:
                drageEnded(point: point)
            case UIGestureRecognizerState.cancelled:
                drageEnded(point: point)
            default: break
        }
    }
    
    private func getDragingIndexPath(_ point: CGPoint) -> IndexPath? {
        if let count = collectionView?.numberOfItems(inSection: 0), count < config.fixedNum {
            return nil
        }
        var dragIndexPath: IndexPath? = nil
        if let indexPathList = collectionView?.indexPathsForVisibleItems {
            for indexP in indexPathList {
                if indexP.section > 0 {
                    continue
                }
                if let frame = collectionView?.cellForItem(at: indexP)?.frame, frame.contains(point) {
                    if indexP.row > config.fixedNum - 1 {
                        dragIndexPath = indexP
                    }
                    break
                }
            }
        }
        return dragIndexPath
    }
    
    private func getTargetIndexPath(_ point: CGPoint) -> IndexPath? {
        var targetIndexPath: IndexPath? = nil
        if let indexPathList = collectionView?.indexPathsForVisibleItems {
            for indexP in indexPathList {
                // 如果目标IndexPath是自己，或者在第二组，则不需要排序
                if indexP == indexPath || indexP.section > 0 {
                    continue
                }
                // 在第一组中找出将被替换位置的Item
                if let frame = collectionView?.cellForItem(at: indexP)?.frame, frame.contains(point) {
                    if indexP.row > config.fixedNum - 1 {
                        targetIndexPath = indexP
                    }
                    break
                }
            }
        }
        return targetIndexPath
    }
    
    //MARK: - 长按开始
    private func dragBegan(point: CGPoint) {
        indexPath = getDragingIndexPath(point)
        guard let dragingIndexPath = indexPath else { return }
        collectionView?.bringSubviewToFront(dragingItem!)
        if let item = collectionView?.cellForItem(at: dragingIndexPath) as? QYChannelViewCell {
            item.isHidden = true
            dragingItem?.isHidden = false
            dragingItem?.frame = CGRect(x: 0, y: 0, width: item.frame.width + 6, height: item.frame.height + 6)
            dragingItem?.center = item.center
            dragingItem?.title = icon_close.code + " " + (item.title ?? "")
        }
    }

    //MARK: - 长按过程
    private func drageChanged(point: CGPoint) {
        guard let dragingIndexPath = indexPath else { return }
        dragingItem?.center = point
        targetIndexPath = getDragingIndexPath(point)
        if let target = targetIndexPath {
            // 更新数据源
            let obj = selectedArr[dragingIndexPath.item]
            selectedArr.remove(at: dragingIndexPath.item)
            selectedArr.insert(obj, at: target.item)
            // 交换位置
            collectionView?.moveItem(at: dragingIndexPath, to: target)
            indexPath = target
        }
    }

    //MARK: - 长按结束
    private func drageEnded(point: CGPoint) {
        guard let dragingIndexPath = indexPath else { return }
        
        var isDelete = false
        if let indexPathList = collectionView?.indexPathsForVisibleItems {
            for indexP in indexPathList {
                // 如果在第二组
                if indexP.section > 0 {
                    if let frame = collectionView?.cellForItem(at: indexP)?.frame, frame.contains(point) {
                        isDelete = true
                        break
                    }
                }
                if let cell = collectionView?.cellForItem(at: indexP) as? QYChannelViewCell, let title = cell.title {
                    if title == selectIndexTitle {
                        selectIndex = indexP.section == 0 ? indexP.item : 0
                        selectIndexTitle = selectedArr[selectIndex]
                        if let block = updateCurrentIndexBlock {
                            block(selectIndex)
                        }
                    }
                }
            }
        }
        
        let endIndexPath = isDelete ? IndexPath(item: 0, section: 1) : dragingIndexPath
        
        if isDelete {
            let obj = selectedArr[dragingIndexPath.item]
            selectedArr.remove(at: dragingIndexPath.item)
            recommendArr.insert(obj, at: 0)
            if let cell = collectionView?.cellForItem(at: dragingIndexPath) as? QYChannelViewCell {
                cell.isSelect = false
            }
            collectionView!.moveItem(at: dragingIndexPath, to: endIndexPath)
        }
        
        if let endFrame = collectionView?.cellForItem(at: endIndexPath)?.frame {
            UIView.animate(withDuration: 0.25, animations: {
                self.dragingItem?.frame = endFrame
            }) { (finished) in
                self.dragingItem?.isHidden = true
                if let item = self.collectionView?.cellForItem(at: endIndexPath) as? QYChannelViewCell {
                    item.isHidden = false
                    item.isCanDrag = isDelete ? false : true
                    item.isEditing = isDelete ? false : true
                }
                self.indexPath = nil
                self.targetIndexPath = nil
            }
        }
    }

}

//MARK: - UICollectionViewDelegate 方法
extension QYChannelView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? selectedArr.count : recommendArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QYChannelViewCellIdentifier, for: indexPath) as! QYChannelViewCell
        cell.title = indexPath.section == 0 ? selectedArr[indexPath.item] : recommendArr[indexPath.item]
        cell.isFixed = indexPath.section == 0 && indexPath.item < config.fixedNum
        if isEditing {
            cell.isSelect = false
        } else {
            cell.isSelect = indexPath.section == 0 && indexPath.item == selectIndex
        }
        cell.isEditing = isEditing
        cell.isCanDrag = indexPath.section == 0 ? true : false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            // 更新数据
            let obj = recommendArr[indexPath.item]
            recommendArr.remove(at: indexPath.item)
            selectedArr.append(obj)
            if let cell = collectionView.cellForItem(at: indexPath) as? QYChannelViewCell {
                cell.isEditing = isEditing
                cell.isCanDrag = true
            }
            collectionView.moveItem(at: indexPath, to: IndexPath(item: selectedArr.count - 1, section: 0))
            
        } else {
            if isEditing {
                if collectionView.numberOfItems(inSection: 0) < config.fixedNum { return }
                if indexPath.item < config.fixedNum { return }
                // 更新数据
                let obj = selectedArr[indexPath.item]
                selectedArr.remove(at: indexPath.item)
                recommendArr.insert(obj, at: 0)
                if let cell = collectionView.cellForItem(at: indexPath) as? QYChannelViewCell {
                    cell.isCanDrag = false
                    cell.isSelect = false
                }
                collectionView.moveItem(at: indexPath, to: IndexPath(item: 0, section: 1))
            } else {
                if let block = clickIndexBlock {
                    block(indexPath.item)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: QYChannelViewHeaderIdentifier, for: indexPath) as! QYChannelHeaderView
        
        var title = titleArr[indexPath.section]
        if indexPath.section == 0 {
            title = title + " " + (isEditing ? subTitleArr[0][1] : subTitleArr[0][0])
        } else {
            title = title + " " + subTitleArr[1][0]
        }
        header.title = title
        header.button.isSelected = isEditing
        header.button.isHidden = indexPath.section > 0 ? true : false
        header.clickCallback = {[weak self] in
            self?.isEditing = !(self?.isEditing)!
            self?.collectionView!.reloadData()
        }
        return header
    }
}

//MARK: - 自定义cell
class QYChannelViewCell: UICollectionViewCell {
    
    // 是否正在编辑
    var isEditing = false {
        didSet {
            updateView()
        }
    }
    
    // 是否被固定
    var isFixed = false {
        didSet {
            if isFixed {
                label.textColor = QYRGBColor(0x888888)
            } else {
                label.textColor = QYRGBColor(0x333333)
            }
        }
    }
    
    // 是否可被拖动
    var isCanDrag = true {
        didSet {
            updateView()
        }
    }
    
    // 是否被选中
    var isSelect: Bool = false {
        didSet {
            if isSelect {
                label.textColor = QYRGBColor(0x1363DD)
            } else {
                if isFixed {
                    label.textColor = QYRGBColor(0x888888)
                } else {
                    label.textColor = QYRGBColor(0x333333)
                }
            }
        }
    }
    
    var title: String? {
        didSet {
            label.text = title
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: self.bounds, fontSize: 15)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QYRGBColor(0xF6F6F6)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 3
    }
    
    private func updateView() {
        if !isCanDrag {
            let text = icon_add.code + " " + (title ?? "")
            label.text = text
        } else {
            if isEditing {
                if isFixed {
                    label.text = title
                } else {
                    let text = icon_close.code + " " + (title ?? "")
                    label.text = text
                }
            } else {
                label.text = title
            }
        }
    }
    
}

//MARK: - 自定义头视图
class QYChannelHeaderView: UICollectionReusableView {
    
    var clickCallback: (() -> ())?
    
    var title: String? {
        didSet {
            let attrStr = NSMutableAttributedString(string: title!)
            attrStr.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)], range: NSRange(location: 0, length: 4))
            attrStr.addAttributes([NSAttributedString.Key.foregroundColor: QYRGBColor(0x333333)], range: NSRange(location: 0, length: 4))
            attrStr.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], range: NSRange(location: 5, length: title!.count - 5))
            attrStr.addAttributes([NSAttributedString.Key.foregroundColor: QYRGBColor(0x888888)], range: NSRange(location: 5, length: title!.count - 5))
            titleLabel.attributedText = attrStr
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.frame.origin.x = 10
        return label
    }()
    
    lazy var button: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle("编辑", for: .normal)
        btn.setTitle("完成", for: .selected)
        btn.setTitleColor(QYRGBColor(0x1363DD), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.frame = CGRect(x: 0, y: 0, width: 65, height: 30)
        btn.center = CGPoint(x: QYSCREEN_WIDTH - 10 - 65/2, y: self.bounds.size.height/2)
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        btn.layer.borderColor = QYRGBColor(0x1363DD).cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(button)
        backgroundColor = .white
    }
    
    @objc func buttonClick() {
        if let block = clickCallback {
            block()
        }
    }
}

