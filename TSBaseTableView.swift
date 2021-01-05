//
//  TSBaseTableView.swift
//  TSTableViewTemplate
//
//  Created by jugang.tang on 2020/8/24.
//  Copyright © 2020 jugang.tang. All rights reserved.
//

import UIKit

public class TSBaseTableView: UITableView {
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        separatorStyle = .none
        backgroundColor = .white
        if #available(iOS 11.0, *) {
            self.estimatedRowHeight = 0
            self.estimatedSectionHeaderHeight = 0
            self.estimatedSectionFooterHeight = 0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// 添加头部刷新控件
    @objc public func addTableHeader(_ refreshingBlock: @escaping () -> Void) {
        let header = MJDIYHeader()
        header.refreshingBlock = refreshingBlock
        self.mj_header = header
    }

    /// 添加底部刷新控件
    @objc public func addTableFooter(_ refreshingBlock: @escaping () -> Void) {
        let footer = MJRefreshAutoStateFooter()
        footer.refreshingBlock = refreshingBlock
        footer.setTitle("～已经到底了～", for: .noMoreData)
        self.mj_footer = footer
    }

    /// 显示无数据占位图
    @objc public func showNoData(tipStr: String? = nil) {
        self.tipImageView.isHidden = false
        if let text = tipStr, text.count > 0 {
            self.tipLabel.isHidden = false
            self.tipLabel.text = text
        } else {
            self.tipLabel.isHidden = true
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if !tipImageView.isHidden {
            let w = tipImageView.image?.size.width ?? 60
            let h = tipImageView.image?.size.height ?? 60
            tipImageView.frame = CGRect(x: self.center.x - w / 2, y: self.center.y - h - 20, width: w, height: h)
        }
        if !tipLabel.isHidden {
            tipLabel.frame = CGRect(x: 50, y: self.center.y - 10, width: self.bounds.width - 100, height: 20)
        }
    }

    /// 隐藏无数据占位图
    @objc public func hideNoDataTip() {
        self.tipImageView.isHidden = true
        self.tipLabel.isHidden = true
    }

    private lazy var tipImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "empty_data"))
        imageView.isHidden = true
        self.addSubview(imageView)
        return imageView
    }()

    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .lightGray
        self.addSubview(label)
        return label
    }()
}
