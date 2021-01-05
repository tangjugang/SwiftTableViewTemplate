//
//  TSBaseCell.swift
//  TSTableViewTemplate
//
//  Created by jugang.tang on 2020/8/24.
//  Copyright © 2020 jugang.tang. All rights reserved.
//

import UIKit

class TSBaseCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layer.masksToBounds = true
        contentView.layer.masksToBounds = true
        backgroundColor = .white
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var reloadCellHeight: ((CGFloat) -> Void)? // 适用于异步计算高度后刷新cell

    var reloadCell: (() -> Void)? // 局部刷新cell

    func setUI() {}

    func ts_cellForRow(_ tableView: UITableView, cellData: TSBaseCellData, data: Any?) {}

    func ts_cellHeight(_ tableView: UITableView, cellData: TSBaseCellData, data: Any?) -> CGFloat {
        return cellData.cellHeight
    }

    func ts_didSelectRow(_ tableView: UITableView, cellData: TSBaseCellData, data: Any?) {}

    func addShadowBackgroundView() {
        backgroundColor = UIColor(hex: "F5F5FA")
        self.contentView.layer.cornerRadius = 10
        self.contentView.backgroundColor = .white
        let normalView = UIView()
        normalView.backgroundColor = .white
        ahs_setShadow(view: normalView, width: 0, bColor: .clear, sColor: AHSRgbAlpha(225, 225, 230, 0.2), offset: CGSize(width: 0, height: 10), opacity: 1, radius: 8)
        self.backgroundView = normalView
    }

    func setShadowBackgroundViewFrame() {
        if self.bounds.height >= 20 {
            self.contentView.frame = self.bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 20, right: 10))
            self.backgroundView?.frame = self.contentView.frame
        }
    }
}

class TSDefaultCell: TSBaseCell {
    override func setUI() {
        backgroundColor = .clear
    }
}

extension UITableViewCell {
    /*
     卡片式Cell
     注意要在willDisplay中调用不然显示会有问题
     */
    func cornerCard(radio: CGFloat, margin: CGFloat, indexPath: IndexPath) {
        func checkCellIndexPath(indexPath: IndexPath) -> UIRectCorner? {
            // 拿到Cell的TableView
            var view: UIView? = superview
            while view != nil, !(view is UITableView) {
                view = view!.superview
            }
            guard let tableView = view as? UITableView else { return nil }
            if indexPath.row == 0, indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                // 1.只有一行
                return .allCorners
            } else if indexPath.row == 0 {
                // 2.每组第一行
                return [.topLeft, .topRight]
            } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                // 3.每组最后一行
                return [.bottomLeft, .bottomRight]
            } else {
                return nil
            }
        }

        let corner = checkCellIndexPath(indexPath: indexPath)
        let contentBounds = CGRect(origin: CGPoint(x: margin, y: 0), size: CGSize(width: frame.width - 2 * margin, height: frame.height))
        let layer = CAShapeLayer()
        layer.bounds = contentBounds
        layer.position = CGPoint(x: contentBounds.midX ,y: contentBounds.midY)
        layer.path = UIBezierPath(roundedRect: contentBounds, byRoundingCorners: corner ?? [], cornerRadii: CGSize(width: radio, height: radio)).cgPath
        self.layer.mask = layer
    }

    /// 只切上边或下边的圆角
    func cornerCard(radio: CGFloat, margin: CGFloat, indexPath: IndexPath, cutTop: Bool) {
        func checkCellIndexPath(indexPath: IndexPath) -> UIRectCorner? {
            // 拿到Cell的TableView
            var view: UIView? = superview
            while view != nil, !(view is UITableView) {
                view = view!.superview
            }
            guard let tableView = view as? UITableView else { return nil }
            if indexPath.row == 0, indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                // 1.只有一行
                return cutTop ? [.topLeft, .topRight] : [.bottomLeft, .bottomRight]
            } else if indexPath.row == 0 {
                // 2.每组第一行
                return cutTop ? [.topLeft, .topRight] : nil
            } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                // 3.每组最后一行
                return cutTop ? nil : [.bottomLeft, .bottomRight]
            } else {
                return nil
            }
        }

        let corner = checkCellIndexPath(indexPath: indexPath)
        let contentBounds = CGRect(origin: CGPoint(x: margin, y: 0), size: CGSize(width: frame.width - 2 * margin, height: frame.height))
        let layer = CAShapeLayer()
        layer.bounds = contentBounds
        layer.position = CGPoint(x: contentBounds.midX ,y: contentBounds.midY)
        layer.path = UIBezierPath(roundedRect: contentBounds, byRoundingCorners: corner ?? [], cornerRadii: CGSize(width: radio, height: radio)).cgPath
        self.layer.mask = layer
    }
}
