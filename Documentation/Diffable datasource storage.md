ProxyDiffableDataSourceStorage
================

`ProxyDiffableDataSourceStorage` is a proxy class used by `DTTableViewManager/DTCollectionViewManager` frameworks to support diffable datasources in iOS 13.

All it does, it contain wrapper closures, that redirect datasource questions to diffable datasource object. Additionally, It has the same supplementary model provider logic that all storages have.

## Example

You can find working example of diffable datasources integration [here](https://github.com/DenTelezhkin/DTTableViewManager/blob/master/Example/Controllers/MultiSectionDiffingTableViewController.swift).

### Benefits of using `ProxyDiffableDataSourceStorage`

For one, this implementation allows you to use diffable datasources with `DTCollectionViewManager` and `DTTableViewManager`. Secondly, it simplifies a lot of setup with diffable datasources.

```swift
// Without `DTCollectionViewManager` and `ProxyDiffableDataSourceStorage`
dataSource = UICollectionViewDiffableDataSource
    <Section, MountainsController.Mountain>(collectionView: mountainsCollectionView) {
        (collectionView: UICollectionView, indexPath: IndexPath,
        mountain: MountainsController.Mountain) -> UICollectionViewCell? in
    guard let mountainCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
            fatalError("Cannot create new cell") }
    mountainCell.label.text = mountain.name
    return mountainCell
}
```

into:

```swift
// With `DTCollectionViewManager` and `ProxyDiffableDataSourceStorage`
dataSource = manager.configureDiffableDataSource { indexPath, model in
   model
}
```

Basically instead of managing cells, you only manage models, because `DTTableViewManager` and `DTCollectionViewManager` already manage cells for you.

Another small benefit for `UITableView` users is that diffable datasources for UITableView do not support headers or footers, but when using `ProxyDiffableDataSourceStorage` - they work perfectly fine, powered by `supplementaryModelProvider`.

> Please note, that due to underlying implementation details, using `UICollectionViewDiffableDataSource.supplementaryViewProvider` property is not supported. Please use `ProxyDiffableDataSourceStorage.supplementaryModelProvider` property instead.
