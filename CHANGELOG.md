# Change Log
All notable changes to this project will be documented in this file.

# Next

**This is major release, containing breaking API changes, please read [DTTableViewManager 6.0 Migration Guide](https://github.com/DenHeadless/DTTableViewManager/blob/master/Documentation/DTTableViewManager%206.0%20Migration%20Guide.md)**

* `MemoryStorage` now has a convenience method for moving item without animations: `moveItemWithoutAnimation(from:to:)`.
* `EventReaction` class now has 4 and 5 argument reactions
* All storage protocols are now class-bound.
* Implemented mapping conditions. `ViewModelMapping` was changed to be able to work with mapping blocks.

# Breaking

* `RealmStorage` is not included in Carthage releases.
* `setItems` method, that accepted array of arrays of items to set items for all sections, has been renamed to `setItemsForAllSections` to provide more clarity and not to clash with `setItems(_:forSection:)` method.

## [5.1.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/5.1.0)

* Swift 3.2 support(Xcode 9 beta 1).
* `RealmStorage` now accepts `RealmCollection` objects into section, thus allowing `List` and `LinkingObjects` to be used(previously only `Results` objects could be used in section).

## [5.0.1](https://github.com/DenHeadless/DTModelStorage/releases/tag/5.0.1)

* Improved handling of `NSFetchedResultsControllerDelegate` `NSFetchedResultsChangeType.update` change type in cases, where object inserts/removal/moves is used simultaneously with object updates(#17).

## [5.0.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/5.0.0)

* Reworked `EventReaction` class to use `ViewModelMapping` to properly identify not only model and `ViewType`, but also `viewClass`. This allows event reactions to run for cases where two view subclasses, conforming to `ModelTransfer`, use the same model, and have similar events.

## [4.1.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/4.1.0)

* Adds `setItems(_:)` method, that allows to set items for all sections in `MemoryStorage`.

## [4.0.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/4.0.0)

* `StorageUpdate` properties, that tracked changes independently of each other, have been replaced with `objectChanges`, `sectionChanges` arrays, that track all changes in order they occured
* `StorageUpdate` now has `updatedObjects` dictionary, that allow tracking objects, that have been updated, along with corresponding indexPath. It is done because UITableView and UICollectionView defer cell updates after insertions and deletions are completed, and therefore shift indexPaths. For example, if you were to insert 0 item and update it, UITableView would think that you are updating 1 item instead of 0, because it happens in single animation block and 0 item becomes 1.

## [3.0.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/3.0.0)

No changes

## [3.0.0-beta.3](https://github.com/DenHeadless/DTModelStorage/releases/tag/3.0.0-beta.3)

* Requires Realm 2.0 and higher.
* Fixes crash, that happens, when subscribing to Realm notifications and Realm is read-only.

## [3.0.0-beta.2](https://github.com/DenHeadless/DTModelStorage/releases/tag/3.0.0-beta.2)

* Enables `RealmStorage` with `RealmSwift` dependency

## [3.0.0-beta.1](https://github.com/DenHeadless/DTModelStorage/releases/tag/3.0.0-beta.1)

Swift 3.0 and higher is required for this version of framework.

**Note** Beta 1 Does not include RealmStorage subspec due to [RealmSwift.framework podspec issues](https://github.com/realm/realm-cocoa/issues/4101)

### Reworked

* `UIReaction` class has been replaced with new `EventReaction` class, that allows more flexible and powerful events usage
* Supplementary models are now stored in `[String:[Int:Any]]` instead of `[String:Any]` to support supplementary models, whose position is determined by indexPath in UICollectionView. `SupplementaryStorageProtocol`, `SupplementaryAccessible` protocols have been reworked to reflect those changes.
* `MemoryStorageErrors` have been made an `Error` type following conventions from [SE-0112](https://github.com/apple/swift-evolution/blob/master/proposals/0112-nserror-bridging.md).

### Added

* `MemoryStorage` and `RealmStorage` now implement  `SectionLocationIdentifyable` protocol, allowing any section to find out, what it's index is.
* `SectionModel` and `RealmSection` gained `currentSectionIndex` property, that shows index of section in sections array.
* `displaySectionNameForSupplementaryKinds` property on `CoreDataStorage`, that defines, for which supplementary kinds `NSFetchedResultsController` `sectionName` should be used as a data model.
* `removeItemsFromSection` method on `MemoryStorage`, that allows to remove all items from specific section

### Removed

* `itemForCellClass:atIndexPath:`, `itemForHeaderClass:atSectionIndex:`, `itemsForFooterClass:atSectionIndex:`
* `makeNSIndexSet` method, because Swift 3 allows to directly create IndexSet from both `Array` and `Set`.

## [2.6.2](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.6.2)

### Fixed

* `CoreDataStorage` now properly updates new indexPath after Move event on iOS 9.

## [2.6.1](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.6.1)

### Fixed

* Now properly handles case, when `deleteSections` method was called with index, that is not present in `MemoryStorage` or `RealmStorage`

### Added

* `setSectionWithResults(_:forSectionIndex:)` for `RealmStorage`

### Updated

* `Realm` dependency to `1.0.0`

## [2.6.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.6.0)

### Changed

* Support for fine-grained notifications in Realm
* Update to Realm 0.103.1 and higher.

### Fixed

* Fixed https://github.com/DenHeadless/DTTableViewManager/issues/34, thanks @orkenstein, @andrewSvsg

## [2.5.1](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.5.1)

## Changed

* Realm dependency updated to 0.102 version.

## [2.5.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.5.0)

## Breaking

* Update to Swift 2.2. This release is not backwards compatible with Swift 2.1.

## Added

* `insertItems(_:toIndexPaths:)` method, that mirrors UITableView `insertRowsAtIndexPaths(_:withRowAnimation:)` and UICollectionView `insertItemsAtIndexPaths(_:)` method
* `totalNumberOfItems` computed property in `MemoryStorage`, that allows getting current total number of items across all storage.

## Changed

* Require Only-App-Extension-Safe API is set to YES in framework targets.

## [2.4.4](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.4.4)

### Changed

* `batchUpdatesInProgress` property on `BaseStorage` is made public to be available in subclasses

## [2.4.3](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.4.3)

### Changed

* All methods were moved from extensions to class bodies to allow overriding them in @nonobjc subclasses.

## [2.4.2](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.4.2)

### Changed

* `replaceItem(_:replacingItem:)` method no longer requires second argument to be Equatable.

## [2.4.1](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.4.1)

### Changed

* `BaseStorage` `startUpdate` and `finishUpdate` methods are now public along with `currentUpdate` property.

## [2.4.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.4.0)

### Added

* `RealmStorage` and `RealmSection` class, that allows using Realm database results as a storage for `DTTableView` and `DTCollectionViewManager`.
* Ability to specify xibName on `ViewModelMapping` class.

### Removed

Removed API, deprecated in previous releases. All removed API calls are superseded by following replacement methods.

* `removeAllTableItems`, `removeAllCollectionItems` -> `removeAllItems`
* `moveCollectionItemAtIndexPath:toIndexPath:`, `moveTableItemAtIndexPath:toIndexPath:` -> `moveItemAtIndexPath:toIndexPath:`
* `moveCollectionViewSection:toSection`, `moveTableViewSection:toSection` -> `moveSection:toSection`
* `objectForCellClass` -> `itemForCellClass`
* `objectForHeaderClass` -> `itemForHeaderClass`
* `objectForFooterClass` -> `itemForFooterClass`
* `objectAtIndexPath` -> `itemAtIndexPath`
* `SectionModel` `objects` and `numberOfObjects` -> `items`, `numberOfItems`

## [2.3.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.3.0)

### Added

* `ViewModelMapping` class, that allows to store and retrieve mappings using type checks instead of runtime introspection
* `UIReaction` class, that will allow `DTTableViewManager` and `DTCollectionViewManager` to react to selection and configuration events. This class supersedes `TableViewReaction` and `CollectionViewReaction` internal classes, that previously served the same purpose.
* `DTViewModelMappingCustomizable` protocol to allow customization of `ViewModelMapping`.

### Removed

* `RuntimeHelper` model introspection methods

## [2.2.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.2.0)

### Added

* `performUpdates` method to perform batch updates on Storage classes.
* Support for Apple TV platform (tvOS)

### Fixed

* Handle NSFetchedResultsController update, that may be called in a form of .Move type(iOS 9).

## [2.1.3](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.1.3)

### Fixed

* `insertItem(_:atIndexPath:)` method now properly accepts zero index path in empty section

## [2.1.2](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.1.2)

### Added

* `setSection(_:forSectionIndex:)` method to set specific section with supplementaries and reloadData

### Updated

* Explicitly call storageNeedsReloading from methods `setSupplementaries`, `setSectionHeaderModels` and `setSectionFooterModels`

## [2.1.1](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.1.1)

#### Added
* `insertSection(_:atIndex:)` method that allows to insert `SectionModel` directly, with items and supplementary models.

## [2.1.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.1.0)

#### Updated
* `StorageUpdate` class was rewritten from scratch using Swift Set.
* `StorageUpdate` now contains movedRowIndexPaths and movedSectionIndexes properties
* All method names and properties, that contained `object` term in their name, have been renamed to read 'item' instead
* `MemoryStorage` `sectionAtIndex(_:)` method now returns optional value instead of always returning `SectionModel`. This method no longer inserts new sections, when called.

#### Fixed
* `removeItems` method should no longer skip items, if their indexPath is reduced when removing previous item

#### Removed
* `removeAllTableItems` and `removeAllCollectionItems` have been replaced by `removeAllItems` method.
* `moveCollectionItemAtIndexPath:toIndexPath:` and `moveTableItemAtIndexPath:toIndexPath:` have been replaced by `moveItemAtIndexPath:toIndexPath:` method
* `moveCollectionViewSection:toSection` and `moveTableViewSection:toSection` have been replaced by `moveSection:toSection` method

## [2.0.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.0.0)

Framework was completely rewritten from scratch in Swift 2.

For more details, read [blog post](http://digginginswift.com/2015/09/13/dttableviewmanager-4-protocol-oriented-uitableview-management-in-swift/).
