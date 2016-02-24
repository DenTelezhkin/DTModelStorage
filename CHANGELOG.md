# Change Log
All notable changes to this project will be documented in this file.

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
