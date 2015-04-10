![Build Status](https://travis-ci.org/DenHeadless/DTModelStorage.png?branch=master) &nbsp;
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTModelStorage/badge.png) &nbsp; 
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTModelStorage/badge.png) &nbsp;
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)
DTModelStorage
==============

> This is a child-project for [DTTableViewManager](https://github.com/DenHeadless/DTTableViewManager) and [DTCollectionViewManager](https://github.com/DenHeadless/DTCollectionViewManager) - great tools for UITableView and UICollectionView management.

What this is all about?
==============

The goal of the project - is to provide storage classes for datasource based controls. Now, what do i mean by that? Let's take UITableView, for example. It's datasource methods mostly relates on following:

* sections
* items in sections
* section headers and footers

Now, if we look on UICollectionView, that stuff does not change. And probably any kind of datasource based control can be adapted to use the same terminology. So, instead of reinventing the wheel every time, let's try to implement universal storage classes, that would fit any control. 

DTModelStorage supports 2 kinds of storage classes:
* Memory storage
* CoreData storage

Internal structure of these will be different, but we need a common interface and pattern to interact with them. This pattern is actually very simple, and contains two simple steps.

1. Update storage 
2. Notify delegate about changes in storage

Memory storage classes will provide convinience methods to update storage, CoreData storage classes will rely on updates from NSFetchedResultsControllerDelegate protocol. So the first step will be different, but the second step stays the same. And delegate for storage classes will receive the same message, and it will not actually care, which storage is used. They will look the same from its point of view. 

DTModelStorage does not force any specific use, and does not imply, which UI components are compatible with it. However, storage classes are designed to work with "sections" and "items", which generally means some kind of table or collection of items.

Common interface for storage classes
================

Storage methods:
```objective-c
- (NSArray*)sections;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
```

Any section implements two methods:
```objective-c
- (NSArray *)objects;
- (NSUInteger)numberOfObjects;
```

Section object will be different for different kind of storage class. 

DTCoreDataStorage
================

DTCoreDataStorage is meant to be used with NSFetchedResultsController. It automatically monitors all NSFetchedResultsControllerDelegate methods and and calls delegate with appropriate updates.

```objective-c
DTCoreDataStorage * storage = [DTCoreDataStorage storageWithFetchResultsController:controller];
```	

Any section in DTCoreDataStorage conform to NSFetchedResultsSectionInfo protocol.

For perfomance reasons, you should not call -(NSArray *)objects method, if you don't need to. Objects may not be fetched from CoreData database, and if you need to retrieve only one specific item, it's better to call -objectAtIndexPath: method instead. This way only one item will be actually fetched from database. 

DTMemoryStorage
================
DTMemoryStorage encapsulates storage of data models in memory. It's basically NSArray of DTSectionModel objects, which contain array of objects for current section, and supplementary models of any kind, that add additional information for section. Good example would be UITableView headers and footers.

```objective-c
DTMemoryStorage * storage = [DTMemoryStorage storage];
```

#### Adding items 

```objective-c
[storage addItem:model];
[storage addItem:model toSection:0];

[storage addItems:@[model1,model2]];
[storage addItems:@[model1,model2] toSection:0];

[storage insertItem:model toIndexPath:indexPath];
```

#### Remove / replace

```objective-c
[storage removeItem:model];
[storage removeItems:@[model1,model2]];

[storage replaceItem:model1 withItem:model2];
```	

#### Managing sections 

```objective-c
[storage deleteSections:[NSIndexSet indexSetWithIndex:1]];
```

#### Retrieving items

```objective-c
id item = [storage itemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

NSIndexPath * indexPath = [storage indexPathForItem:model];

NSArray * itemsInSection = [storage itemsInSection:0];

DTSectionModel * section = [storage sectionAtIndex:0];
```

#### Updating manually

Sometimes you may need to update batch of sections, remove all items, and add new ones. For those massive updates you don't actually need to update interface until update is finished. Wrap your updates in single block and pass it to updateWithoutAnimations method:

```objective-c
[storage updateWithoutAnimations:^{
// Add/remove/modify any row or section
}];
// Calling reloadData is mandatory after calling this method. or you will get crash runtime
```

#### Supplementary models

```objective-c
DTSectionModel * section = [storage sectionAtIndex:0];
[section setSupplementaryModel:@"foo" forKind:UICollectionElementKindSectionHeader];
id model = [section supplementaryModelOfKind:UICollectionElementKindSectionHeader];
```

Installation
===========
Both storage classes:

    pod 'DTModelStorage', '~> 1.2.0'

Only DTCoreDataStorage:

    pod 'DTModelStorage/CoreDataStorage', '~> 1.2.0'

Only DTMemoryStorage:

    pod 'DTModelStorage/MemoryStorage', '~> 1.2.0'

Requirements
============

* XCode 6.3 and higher
* iOS 7
* ARC
