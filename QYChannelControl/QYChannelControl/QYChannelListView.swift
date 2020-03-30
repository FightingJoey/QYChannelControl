//
//  QYChannelListView.swift
//  QYChannelControl
//
//  Created by TrinaSolar on 2020/3/29.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit

protocol QYChannelListViewDelegate: NSObjectProtocol {
    func didSelected(index: Int)
    func channelWith(index: Int) -> String
    func numberOfChannelList() -> Int
}

private struct QYChannelListViewCellModel {
    var frame: CGRect
    var indexPath: IndexPath
}

private enum QYChannelListCellAnimationType {
    case selected
    case willSelected
}

//MARK: ========== QYChannelListCell ==========

private class QYChannelTitleLabel: UILabel {
    var alignment: QYChannelTitleVerticalAlignment = .bottom
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch alignment {
        case .center:
            textRect.origin.y = (bounds.size.height - textRect.size.height)/2.0
        case .bottom:
            textRect.origin.y = bounds.size.height - textRect.size.height
        case .top:
            textRect.origin.y = font.pointSize > UIFont.labelFontSize ? 0 : 2
        }
        return textRect
    }
    
    override func drawText(in rect: CGRect) {
        let actualRect = textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: actualRect)
    }
}

private class QYChannelListCell: UICollectionViewCell {
    
    var config: QYChannelControlConfig = QYChannelControlConfig()
    var textLabel: QYChannelTitleLabel = {
        let label = QYChannelTitleLabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.textAlignment = .center
        contentView.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds
    }
    
    func configCell(isSelected: Bool) {
        textLabel.textColor = isSelected ? config.titleSelectedColor : config.titleNormalColor
        textLabel.font = isSelected ? config.titleSelectedFont : config.titleNormalFont
        textLabel.alignment = config.textVerticalAlignment
    }
    
    func showAnimation(progress: CGFloat, type: QYChannelListCellAnimationType) {
        switch type {
        case .selected:
            textLabel.textColor = QYChannelControlUtils.colorTransform(from: config.titleSelectedColor, to: config.titleNormalColor, progress: progress)
        case .willSelected:
            textLabel.textColor = QYChannelControlUtils.colorTransform(from: config.titleNormalColor, to: config.titleSelectedColor, progress: progress)
        }
    }
}

//MARK: ========== QYChannelListView ==========

class QYChannelListView: UIView {

    var delegate: QYChannelListViewDelegate?
    
    // 当前选中位置
    var selectedIndex: Int = 0 {
        didSet {
            updateViewWithSelect()
        }
    }
    
    var lastSelected: Int {
        get {
            return lastSelectedIndex
        }
    }
    
    // 是否停止显示动画，在手动设置位置时，不显示动画效果
    var isStopAnimation: Bool = false
    
    var leftBtn: UIButton? {
        didSet {
            addSubview(self.leftBtn!)
        }
    }
    
    var rightBtn: UIButton? {
        didSet {
            addSubview(self.rightBtn!)
        }
    }
    
    //MARK: Private Property
    
    private var lastSelectedIndex: Int = 0

    // 集合视图
    private lazy var collectionView: UICollectionView = { [weak self] in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        if let weakself = self {
            layout.sectionInset = weakself.config.channelListViewInset
            layout.minimumLineSpacing = weakself.config.titleSpace
            layout.minimumInteritemSpacing = weakself.config.titleSpace
        }
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = config.channelListViewBackgroundColor
        collectionView.register(QYChannelListCell.self, forCellWithReuseIdentifier: "QYChannelListCell")
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    // 配置信息
    private var config: QYChannelControlConfig = QYChannelControlConfig()
    
    // 阴影线条
    private lazy var shadowLine: UIView = { [weak self] in
        let view = UIView()
        if let weakself = self {
            view.bounds = CGRect(x: 0, y: 0, width: weakself.config.shadowLineWidth, height: weakself.config.shadowLineHeight)
            view.backgroundColor = weakself.config.shadowLineColor
            if weakself.config.shadowLineCap == .round {
                view.layer.cornerRadius = weakself.config.shadowLineHeight/2.0
                view.layer.masksToBounds = true
            }
            view.isHidden = weakself.config.isShadowLineHidden
        }
        return view
    }()
    
    // 底部分割线
    private lazy var separatorLine: UIView = { [weak self] in
        let view = UIView()
        if let weakself = self {
            view.backgroundColor = weakself.config.separatorLineColor
            view.isHidden = weakself.config.isSeparatorLineHidden
        }
        return view
    }()
    
    //MARK: Life Style
    
    init(_ frame: CGRect = CGRect.null, config: QYChannelControlConfig) {
        super.init(frame: frame)
        self.config = config
        self.addSubview(collectionView)
        self.addSubview(separatorLine)
        collectionView.addSubview(shadowLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var collectionW = bounds.size.width
        let btnW = self.bounds.size.height
        var collectionX: CGFloat = 0.0
        
        if let _ = rightBtn {
            collectionW = bounds.size.width - btnW
            rightBtn?.frame = CGRect(x: bounds.size.width - btnW, y: 0, width: btnW, height: btnW)
        }
        if let _ = leftBtn {
            collectionW = bounds.size.width - btnW
            leftBtn?.frame = CGRect(x: 0, y: 0, width: btnW, height: btnW)
            collectionX = btnW
        }
        
        collectionView.frame = CGRect(x: collectionX, y: 0, width: collectionW, height: bounds.size.height)
        
        separatorLine.frame = CGRect(x: collectionX, y: bounds.size.height - config.separatorLineHeight, width: bounds.size.width, height: config.separatorLineHeight)
        bringSubviewToFront(separatorLine)
        
        fixShadowLineCenter()
        collectionView.sendSubviewToBack(shadowLine)
        if !config.isShadowLineHidden {
            shadowLine.isHidden = delegate?.numberOfChannelList() == 0
        }
    }
    
    //MARK: Private Method
    
    private func fixShadowLineCenter() {
        collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        let shadowCenter = shadowLineCenter(index: selectedIndex)
        if shadowCenter.x > 0 {
            shadowLine.center = shadowCenter
        } else {
            if shadowLine.center.x <= 0 {
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.01) {
                    DispatchQueue.main.sync {
                        self.shadowLine.center = self.shadowLineCenter(index: self.selectedIndex)
                    }
                }
            }
        }
    }
    
    private func shadowLineCenter(index: Int) -> CGPoint {
        var cellFrame: CGRect = CGRect.zero
        if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) {
            cellFrame = cell.frame
        }
        let centerX = cellFrame.midX
        let separatorLineHeight = config.isSeparatorLineHidden ? 0 : config.separatorLineHeight
        var centerY = bounds.size.height - config.separatorLineHeight/2.0 - separatorLineHeight
        switch config.shadowLineAlignment {
        case .top:
            centerY = config.shadowLineHeight/2.0
        case .center:
            centerY = cellFrame.midY
        default:
            break
        }
        return CGPoint(x: centerX, y: centerY)
    }
    
    private func widthForItem(indexPath: IndexPath) -> CGFloat {
        if config.titleWidth > 0 {
            return config.titleWidth
        }
        let normalTitleWidth = QYChannelControlUtils.width(text: delegate!.channelWith(index: indexPath.row), font: config.titleNormalFont, size: bounds.size)
        let selectedTitleWidth = QYChannelControlUtils.width(text: delegate!.channelWith(index: indexPath.row), font: config.titleSelectedFont, size: bounds.size)
        return selectedTitleWidth > normalTitleWidth ? selectedTitleWidth : normalTitleWidth
    }
    
    private func updateViewWithSelect() {
        if selectedIndex == lastSelectedIndex { return }
        // 更新UI
        let currentIndexPath = IndexPath(row: selectedIndex, section: 0)
        if let currentCell = collectionView.cellForItem(at: currentIndexPath) as? QYChannelListCell {
            currentCell.configCell(isSelected: true)
            // 延时刷新
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.2) {
                DispatchQueue.main.sync {
                    UIView.performWithoutAnimation {
                        self.collectionView.reloadItems(at: [currentIndexPath])
                    }
                }
            }
        }
        // 如果上次选中的item已经不存在了，无需刷新
        if let count = delegate?.numberOfChannelList(), lastSelectedIndex < count {
            // 更新UI
            let lastIndexPath = IndexPath(row: lastSelectedIndex, section: 0)
            if let lastCell = collectionView.cellForItem(at: lastIndexPath) as? QYChannelListCell {
                lastCell.configCell(isSelected: false)
                // 延时刷新
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    DispatchQueue.main.sync {
                        UIView.performWithoutAnimation {
                            self.collectionView.reloadItems(at: [lastIndexPath])
                        }
                    }
                }
            }
        }
        // 自动居中
        collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        // 设置阴影位置
        shadowLine.center = shadowLineCenter(index: selectedIndex)
        // 保存上次选择位置
        lastSelectedIndex = selectedIndex
    }
    
    //MARK: Public Method
    
    public func reloadData() {
        collectionView.reloadData()
        if !config.isShadowLineHidden {
            shadowLine.isHidden = delegate?.numberOfChannelList() == 0
        }
        fixShadowLineCenter()
    }
    
    public func showAnimationWith(progress: Float) {
        if isStopAnimation { return }
        if progress == 0 { return }
        let targetIndex = progress < Float(0.0) ? selectedIndex - 1 : selectedIndex + 1
        if let count = delegate?.numberOfChannelList(), targetIndex >= count || targetIndex < 0 {
            return
        }
        if let currentCell = collectionView.cellForItem(at: IndexPath(row: selectedIndex, section: 0)) as? QYChannelListCell, let targetCell = collectionView.cellForItem(at: IndexPath(row: targetIndex, section: 0)) as? QYChannelListCell {
            if config.isTitleColorTransition {
                currentCell.showAnimation(progress: CGFloat(fabsf(progress)), type: .selected)
                targetCell.showAnimation(progress: CGFloat(fabsf(progress)), type: .willSelected)
            }
            QYChannelControlUtils.showAnimation(shadow: shadowLine, shadowWidth: config.shadowLineWidth, from: currentCell.frame, to: targetCell.frame, type: config.shadowLineAnimationType, progress: CGFloat(progress))
        }
    }
}

//MARK: UICollectionViewDelegate && UICollectionViewDataSource

extension QYChannelListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isStopAnimation = true
        delegate?.didSelected(index: indexPath.row)
    }
}

extension QYChannelListView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QYChannelListCell", for: indexPath) as! QYChannelListCell
        cell.config = config
        cell.textLabel.text = delegate?.channelWith(index: indexPath.row)
        cell.configCell(isSelected: indexPath.row == selectedIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.numberOfChannelList() ?? 0
    }
}

extension QYChannelListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthForItem(indexPath: indexPath), height: collectionView.bounds.size.height - config.channelListViewInset.top - config.channelListViewInset.bottom)
    }
}
