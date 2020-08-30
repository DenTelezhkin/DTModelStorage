CoreDataStorage
================

`CoreDataStorage` is meant to be used with `NSFetchedResultsController`. It automatically monitors all `NSFetchedResultsControllerDelegate` methods and and calls delegate with appropriate updates.

```swift
let storage = CoreDataStorage(fetchedResultsController: controller)
```

Any section in `CoreDataStorage` conform to `NSFetchedResultsSectionInfo` protocol, however `DTModelStorage` extends them to be `Section` protocol compatible. This way CoreData sections and memory sections have the same interface.

### UI Updates

`StorageUpdate` is created every time `controllerWillChangeContent` delegate method is called. Changes are collected into a single `StorageUpdate` instance, using `controller(_:didChange:at:for:newIndexPath:)` and `controller(_:didChange:atSectionIndex:for:)` delegate method.

After `controllerDidChangeContent(_:)` delegate method call, update is delivered to the delegate.

## CoreData updater

When setting up CoreDataStorage with `DTTableViewManager` and `DTCollectionViewManager`, consider using special CoreData updater:

```swift
manager.collectionViewUpdater = manager.coreDataUpdater()

manager.tableViewUpdater = manager.coreDataUpdater()
```

This special version of updater has two important differences from default behavior:

1. Moving items is animated as insert and delete
2. When data model changes, `update(with:)` method and `handler` closure are called to update visible cells without explicitly reloading them.

Those are [recommended by Apple](https://developer.apple.com/documentation/coredata/nsfetchedresultscontrollerdelegate) approaches to handle `NSFetchedResultsControllerDelegate` updates with `UITableView` and `UICollectionView`. Those behaviours can be configured on both `CollectionViewUpdater` and `TableViewUpdater` classes.
