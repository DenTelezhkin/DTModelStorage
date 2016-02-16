![Build Status](https://travis-ci.org/DenHeadless/DTModelStorage.svg?branch=master) &nbsp;
[![codecov.io](http://codecov.io/github/DenHeadless/DTModelStorage/coverage.svg?branch=master)](http://codecov.io/github/DenHeadless/DTModelStorage?branch=master)
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTModelStorage/badge.png) &nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)]()
DTModelStorage 2
================

> This is a child-project for [DTTableViewManager](https://github.com/DenHeadless/DTTableViewManager) and [DTCollectionViewManager](https://github.com/DenHeadless/DTCollectionViewManager) - great tools for UITableView and UICollectionView management.

- [x] Written in Swift 2
- [x] Support for any data structure - class, struct, enum, tuple
- [x] Protocol-oriented implementation with generic and associated types
- [x] Swift 2 error-handling model
- [x] Using Swift reflection API to introspect types
- [x] High test coverage

What this is all about?
==============

The goal of the project is to provide storage classes for datasource based controls. Let's take UITableView, for example. It's datasource methods mostly relates on following:

* sections
* items in sections
* section headers and footers

Now, if we look on `UICollectionView`, that stuff does not change. And probably any kind of datasource based control can be adapted to use the same terminology. So, instead of reinventing the wheel every time, let's try to implement universal storage classes, that would fit any control.

`DTModelStorage` supports 2 kinds of storage classes:
* Memory storage
* CoreData storage

Internal structure of these will be different, but we need a common interface and pattern to interact with them. This pattern is actually very simple, and contains two simple steps.

1. Update storage
2. Notify delegate about changes in storage

Memory storage classes will provide convinience methods to update storage, CoreData storage classes will rely on updates from `NSFetchedResultsControllerDelegate` sprotocol. So the first step will be different, but the second step stays the same. And delegate for storage classes will receive the same message, and it will not actually care, which storage is used. They will look the same from its point of view.

`DTModelStorage` does not force any specific use, and does not imply, which UI components are compatible with it. However, storage classes are designed to work with "sections" and "items", which generally means some kind of table or collection of items.

CoreDataStorage
================

`CoreDataStorage` is meant to be used with `NSFetchedResultsController`. It automatically monitors all `NSFetchedResultsControllerDelegate` methods and and calls delegate with appropriate updates.

```swift
let storage = CoreDataStorage(fetchedResultsController: controller)
```

Any section in `CoreDataStorage` conform to `NSFetchedResultsSectionInfo` protocol, however `DTModelStorage` extends them to be `Section` protocol compatible. This way CoreData sections and memory sections have the same interface.

For perfomance reasons, you should not retrieve items via `items` property, if you don't need to. Items may not be fetched from CoreData database, and if you need to retrieve only one specific item, it's better to call -`itemAtIndexPath:` method instead. This way only one item will be actually fetched from database.

MemoryStorage
================
`MemoryStorage` encapsulates storage of data models in memory. It's basically NSArray of `SectionModel` items, which contain array of items for current section, and supplementary models of any kind, that add additional information for section. Good example would be UITableView headers and footers, or UICollectionView with UICollectionViewFlowLayout.

```swift
let storage = MemoryStorage()
```

#### Adding items

```swift
storage.addItem(model)
storage.addItem(model, toSection: 0)

storage.addItems([model1,model2])
storage.addItems([model1,model2], toSection:0)

try? storage.insertItem(model, toIndexPath: indexPath)
```

#### Remove / replace / Reload

```swift
try? storage.removeItem(model)
storage.removeItems([model1,model2])
storage.removeItemsAtIndexPaths(indexPaths)

try? storage.replaceItem(model1, withItem: model2)

storage.reloadItem(model1)
```

#### Managing sections

```swift
storage.deleteSections(NSIndexSet(index: 1))
```

#### Retrieving items

```swift
let item = storage.itemAtIndexPath(NSIndexPath(forItem:1, inSection:0))

let indexPath = storage.indexPathForItem(model)

let itemsInSection = storage.itemsInSection(0)

let section = storage.sectionAtIndex(0)
```

#### Updating manually

Sometimes you may need to update batch of sections, remove all items, and add new ones. For those massive updates you don't actually need to update interface until update is finished. Wrap your updates in single block and pass it to updateWithoutAnimations method:

```swift
storage.updateWithoutAnimations {
	// Add multiple rows, or another batch of edits
}
// Calling reloadData is mandatory after calling this method. or you will get crash runtime
```

#### Supplementary models

```swift
let section = storage.sectionAtIndex(0)
section.setSupplementaryModel("foo", forKind: UICollectionElementKindSectionHeader)
let model = section.supplementaryModelOfKind(UICollectionElementKindSectionHeader)
```

#### Transferring model

`DTModelStorage` defines `ModelTransfer` protocol, that allows transferring your data model to interested parties. This can be used for example for updating `UITableViewCell`. Thanks to associated `ModelType` of the protocol it is possible to transfer your model without any type casts.

#### Generic model getters

`DTModelStorage` provides several `UITableView` and `UICollectionView`-extended methods for retrieving your data model of correct type, for example, you can retrieve model for passed `UITableViewCell` subclass:

```swift
func itemForCellClass<T:ModelTransfer where T: UITableViewCell>(cellClass: T.Type, atIndexPath indexPath: NSIndexPath)-> T.ModelType?

// Usage:
if let item = storage.itemForCell(FooCell.self, atIndexPath: indexPath) {
	// Do something
}
```

And because your `UITableViewCell` subclass will be implementing `ModelTransfer` protocol, we'll be able to gather associated type `ModelType` and cast model to it dynamically. This allows to completely remove all type casts from your `UITableView` and `UICollectionView` code.

## RealmStorage

`RealmStorage` class is made to work with [realm.io](https://realm.io) databases. It works with sections, that contain Realm.Results object.

Creating storage and filling it with results is very easy:

```
let results = try! Realm().objects(Dog)

let storage = RealmStorage()
storage.addSectionWithResults(results)
```

That's it! Results are automatically monitored, and refreshed, if Realm objects change.

Installation
===========

[CocoaPods](https://cocoapods.org):

    pod 'DTModelStorage', '~> 2.4.0'

[Carthage](https://github.com/Carthage/Carthage)

    github "DenHeadless/DTModelStorage" ~> 2.4.0

Requirements
============

* Xcode 7 and higher
* Swift 2
* iOS 8 and higher / tvOS 9.0 and higher

Objective-C
============

Due to generic implementation of DTModelStorage currently there are no plans to support Objective-C. If you want to use `DTModelStorage` in Objective-C project, you can use [latest compatible release](https://github.com/DenHeadless/DTModelStorage/releases/tag/1.3.1) of the framework, that was previously written in Objective-C.
