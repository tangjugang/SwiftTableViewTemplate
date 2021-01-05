# TSTableViewTemplate
## 适用场景

每个`section`都是`唯一`的`cell`注册的，每个`section`只有一行`row`。通俗地讲，适用于由不同内容的模块组合起来的界面。

## 特性

- 局部刷新`cell`
- 异步计算高度后刷新`cell`
- 避免滑动`cell`重复执行`cellForRowAt`

## 使用

#### 1. 初始化`TSBaseCellData`，每个`TSBaseCellData`绑定了我们将要注册的`cell`和显示的`data`

```swift
var dataSource = [TSBaseCellData]()
var businessCD = TSBaseCellData.defaultInit()
var couponCD = TSBaseCellData.defaultInit()

// i.模块的数据由大接口返回时
businessCD = TSBaseCellData(cellClass: AHSHomeBusinessCell.self, data: homeConfigData)
dataSource.append(businessCD)

// ii.模块的数据由其他接口返回时
// 先复用之前的高度，防止异步回调后刷新突兀
if couponCD.cellHeight < 1 {
    couponCD = TSBaseCellData(cellClass: AHSHomeCouponCell.self, data: nil)
}
dataSource.append(couponCD)

// 等待其他接口返回数据，局部刷新该cell
async {
  	couponCD.data = model
    reloadCellSubject.onNext(couponCD)
}
```



#### 2. `VC`继承`TSBaseTableViewController`，绑定`dataSource`，刷新`tableView`

```swift
class AHSHomeController: TSBaseTableViewController {
    private func setData() {
        viewModel.fetchHomeConfigData().subscribe(onNext: { [weak self] data in
            guard let this = self else { return }
            this.dataSource = this.viewModel.dataSource
            this.baseTableView.reloadData()
            if this.dataSource?.count ?? 0 > 0 {
                this.viewModel.requestHomeSpecialModuleAPI()
            }
        }, onError: { [weak self] error in
            guard let this = self else { return }
            this.dataSource = nil
            this.baseTableView.reloadData()
        }).disposed(by: disposeBag)
    }
}
```



#### 3. `Cell`继承`TSBaseCell`，`override`相关方法

```swift
class AHSHomeBusinessCell: TSBaseCell {
    override func ts_cellForRow(_ tableView: UITableView, 
                                cellData: TSBaseCellData, data: Any?) {
        // 避免滑动cell重复赋值（置为true），不需要不写即可
        if cellData.cellForRowMark {
            return
        }
        guard let model = data as? AHSHomeConfig, 
      				let items = model.businessItemsConfig, items.count > 0 else {
            return
        }
        cellData.cellForRowMark = true
     		// 接下来，视图赋值操作......
    }
}
```



## 特别说明

上面代码中有提到

- 局部刷新`cell`
- 避免滑动`cell`重复执行`cellForRowAt`

的写法。

那么，

- 异步计算高度后刷新`cell`

怎么写？



#### 示例：计算图片高度后刷新cell高度

别问我，为什么不用UITableViewAutomaticDimension，性能先不说，这玩意受限性很大，比如：

1. 若设置了estimatedRowHeight = 0; Cell自适应高度 UITableViewAutomaticDimension就失效了
2. 设置了self.contentView的UIEdgeInsets会影响UITableView.automaticDimension自动布局

所以，还是自己动手丰衣足食。

```swift
class AHSCharityCell: TSBaseCell {
      override func ts_cellForRow(_ tableView: UITableView, 
                                  cellData: TSBaseCellData, data: Any?) {
        if cellData.cellForRowMark {
            return
        }
        if let model = data as? AHSHomeCharityConfig, let url = model.imageUrl {
            cellData.cellForRowMark = true
            mainImageView.ahs_setImage(with: url) { [weak self] size, _ in
                if size.height > 0, size.width > 0 {
                    let height = (AHScreenWidth - 50) * (size.height / size.width) + 50
                    // 异步计算高度后刷新cell
                    self?.reloadCellHeight?(height)
                }
            }
        }
    }
}
```













