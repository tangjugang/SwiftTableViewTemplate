//
//  TSBaseTableViewController.swift
//  TSTableViewTemplate
//
//  Created by jugang.tang on 2020/8/24.
//  Copyright © 2020 jugang.tang. All rights reserved.
//

import UIKit

class TSBaseTableViewController: BaseViewController {
    var dataSource: [TSBaseCellData]? {
        didSet {
            guard let arr = dataSource, arr.count > 0 else { return }
            for item in arr {
                baseTableView.register(item.cellClass, forCellReuseIdentifier: item.identifier)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(baseTableView)
    }

    /// 刷新某个Section
    func reloadSection(with cellData: TSBaseCellData) {
        let index = dataSource?.firstIndex { (cd) -> Bool in
            cd.identifier == cellData.identifier
        }
        guard let section = index, section >= 0, dataSource?.count ?? 0 > section else { return }
        cellData.cellForRowMark = false
        UIView.performWithoutAnimation {
            baseTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
        }
    }

    // MARK: - 额外配置数据

    func ts_configCell(with cell: TSBaseCell, indexPath: IndexPath, data: Any?) {}

    func ts_viewForHeader(section: Int, cellData: TSBaseCellData?) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func ts_heightForHeader(section: Int, cellData: TSBaseCellData?) -> CGFloat {
        return 0.01
    }

    func ts_viewForFooter(section: Int, cellData: TSBaseCellData?) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func ts_heightForFooter(section: Int, cellData: TSBaseCellData?) -> CGFloat {
        return 0.01
    }

    // MARK: - Getter

    lazy var baseTableView: TSBaseTableView = {
        let tableView = TSBaseTableView(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
}

extension TSBaseTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = dataSource?[indexPath.section],
            let baseCell = tableView.dequeueReusableCell(withIdentifier: data.identifier, for: indexPath) as? TSBaseCell {
            data.cell = baseCell
            baseCell.reloadCellHeight = { [weak self] height in
                if data.cellHeight != height {
                    data.cellHeight = height
                    self?.reloadSection(with: data)
                }
            }
            baseCell.reloadCell = { [weak self] in
                self?.reloadSection(with: data)
            }
            self.ts_configCell(with: baseCell, indexPath: indexPath, data: data.data)
            baseCell.ts_cellForRow(tableView, cellData: data, data: data.data)
            return baseCell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let data = dataSource?[indexPath.section],
            let baseCell = data.cell {
            if data.cellHeight < 1 || data.heightForRowMark {
                data.cellHeight = baseCell.ts_cellHeight(tableView, cellData: data, data: data.data)
                data.heightForRowMark = false
            }
            return data.cellHeight
        }
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let data = dataSource?[indexPath.section], let baseCell = tableView.cellForRow(at: indexPath) as? TSBaseCell {
            baseCell.ts_didSelectRow(tableView, cellData: data, data: data.data)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.ts_viewForHeader(section: section, cellData: dataSource?[section])
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.ts_heightForHeader(section: section, cellData: dataSource?[section])
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.ts_viewForFooter(section: section, cellData: dataSource?[section])
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.ts_heightForFooter(section: section, cellData: dataSource?[section])
    }
}
