# Change Log
All notable changes to this project will be documented in this file.

## [2.1.1](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.1.1)

#### Added
* `insertSection(_:atIndex:)` that allows to insert `SectionModel` directly, with items and supplementary headers. 

## [2.1.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.1.0)

#### Updated
* `StorageUpdate` class was rewritten from scratch using Swift Set.
* `StorageUpdate` now contains movedRowIndexPaths and movedSectionIndexes properties
* All method names and properties, that contained `object` term in their name, have been renamed to read 'item' instead

#### Fixed
* `removeItems` method should no longer skip items, if their indexPath is reduced when removing previous item

#### Removed
* `removeAllTableItems` and `removeAllCollectionItems` have been replaced by `removeAllItems` method.
* `moveCollectionItemAtIndexPath:toIndexPath:` and `moveTableItemAtIndexPath:toIndexPath:` have been replaced by `moveItemAtIndexPath:toIndexPath:` method
* `moveCollectionViewSection:toSection` and `moveTableViewSection:toSection` have been replaced by `moveSection:toSection` method

## [2.0.0](https://github.com/DenHeadless/DTModelStorage/releases/tag/2.0.0)

Framework was completely rewritten from scratch in Swift 2.

For more details, read [blog post](http://digginginswift.com/2015/09/13/dttableviewmanager-4-protocol-oriented-uitableview-management-in-swift/).
