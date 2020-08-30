MemoryStorage
================
`MemoryStorage` encapsulates storage of data models in memory. It's basically an Array of `SectionModel` items, which contain array of items for current section.

```swift
let storage = MemoryStorage()
```

#### Adding items

Adding items to storage creates an update, that may be animated by storage delegate.

```swift
// section 0 is implied
storage.addItem(model)

storage.addItem(model, toSection: 0)

// section 0 is implied
storage.addItems([model1,model2])

storage.addItems([model1,model2], toSection:0)
```

#### Setting items

Setting items creates an update, that requires storage delegate to reload it's UI. Essentially, it leads to `UICollectionView.reloadData` or `UITableView.reloadData`.

```swift
// section 0 is implied
storage.setItems([1,2,3])

storage.setItems([4,5,6], forSection: 1)

// 1,2,3 - section 0, 4,5,6 - section 1
storage.setItemsForAllSections([[1,2,3],[4,5,6]])
```

#### Insert items

Inserting items creates an update, that may be animated by storage delegate.

```swift
try? storage.insertItem(model, to: indexPath)

// Inserts items starting at provided indexPath.
storage.insertItems([1,2,3], at: IndexPath(item: 3, section:0))

// Inserts items at provided indexPaths.
storage.insertItems([1,2], to: [IndexPath(item:3, section: 0), IndexPath(item: 4, section: 0)])
```

#### Remove / replace / Reload

Removing / replacing/ reloading items creates an update, that may be animated by storage delegate.

```swift
// Items need to conform to `Equatable` protocol
try? storage.removeItem(model)
// Items need to conform to `Equatable` protocol
storage.removeItems([model1,model2])
storage.removeItems(at: indexPaths)

storage.removeItems(fromSection: 1)

// Causes `reloadData`
storage.removeAllItems()

// Item need to conform to `Equatable` protocol
try? storage.replaceItem(model1, with: model2)

// Causes storage update with reload animation, if available
storage.reloadItem(model1)
```

#### Moving items

```swift
// Animated move
storage.moveItem(at: IndexPath(item:0, section:0), to: IndexPath(item:0, section:1))

// Without animations - useful for datasource only update, such as after drag&drop or reordering, where UI was already updated.
storage.moveItemWithoutAnimation(from: IndexPath(item:0, section:0), to: IndexPath(item:0, section:1))
```

#### Managing sections

Deleting / moving / inserting sections creates an update, that may be animated by storage delegate.

```swift
storage.deleteSections(IndexSet(integer: 1))

storage.moveSection(1, toSection: 3)

// Reloads data
storage.setSection(SectionModel(), forSection: 1)

// Animated insertion
storage.insertSection(SectionModel(), atIndex: 1)
```

### Batch updates

If you need to perform several animated changes to datasource simultaneously, you can use `performUpdates` method:

```swift
storage.performUpdates {
  storage.addItems([2,4,6])
  try? storage.insertItem(3, to: indexPath(1, 0))
}
```
Those changes will produce a single `StorageUpdate` instance, thus allowing `UITableView` or `UICollectionView` to animate changes in a single batch update.

> Warning. Performing mutually exclusive updates inside block can cause application crash. For example adding and removing the same item may crash `UICollectionView`.

#### Retrieving items

```swift
let item = storage.item(at: IndexPath(item:1, section:0)

let indexPath = storage.indexPath(forItem:model)

let itemsInSection = storage.items(inSection:0)

let section = storage.section(atIndex:0)
```

#### Updating manually

Sometimes you may need to update batch of sections, remove all items, and add new ones. For those massive updates you don't actually need to update interface until update is finished. Wrap your updates in single block and pass it to updateWithoutAnimations method:

```swift
storage.updateWithoutAnimations {
    // Add multiple rows, or another batch of edits
}
// Calling reloadData is mandatory after calling this method, or you will get crash at runtime.
```
