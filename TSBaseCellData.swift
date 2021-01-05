//
//  TSBaseCellData.swift
//  TSTableViewTemplate
//
//  Created by jugang.tang on 2020/8/24.
//  Copyright © 2020 jugang.tang. All rights reserved.
//

import UIKit

class TSBaseCellData {
    var cellClass: TSBaseCell.Type
    var data: Any? {
        didSet {
            heightForRowMark = true
            cellForRowMark = false
        }
    }

    var identifier: String
    var cellHeight = CGFloat(0)
    var cell: TSBaseCell?

    /// 重新计算cell高度（置为true）
    var heightForRowMark = false

    /// 避免滑动cell重复赋值（置为true），适用于唯一的标识（只有一个cell），注意刷新时重置掉
    var cellForRowMark = false

    init(cellClass: TSBaseCell.Type, data: Any?, cellHeight: CGFloat = 0) {
        self.cellClass = cellClass
        self.data = data
        self.identifier = String(describing: cellClass)
        self.cellHeight = cellHeight
    }

    static func defaultInit() -> TSBaseCellData {
        return TSBaseCellData(cellClass: TSDefaultCell.self, data: nil)
    }
}
