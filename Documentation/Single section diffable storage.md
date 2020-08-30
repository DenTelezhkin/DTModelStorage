SingleSectionStorage
================

While sometimes you need such fine-grained control, that `MemoryStorage` provides, the most often use case for this library is just showing a collection of items, for example array of posts from social network, or search results with a single entity.

In this case, mostly used methods from `MemoryStorage` are `setItems` and `addItems`, because in this case you probably don't need any other methods. What you may want, however, is an ability to automatically calculate diffs between old and new state to be able to animate UI without the need to call `reloadData`. That's where `SingleSectionStorage` comes in.

But before showing any usage examples, let's talk about diffing a little bit. There are a lot of great collection differs outhere, and `DTModelStorage` is not aimed to providing another one. Instead, it provides an API to work with currently available differs.

#### Algorithms

There are a lot of community-built algorithms to compute diff between two collections, for example here's list of frameworks that are built using Paul Heckel's `A Technique for Isolating Differences Between Files`:

- [HeckelDiff](https://github.com/mcudich/HeckelDiff)
- [ListDiff](https://github.com/lxcid/ListDiff) - port of [IGListKit's diffing algorithm](https://github.com/Instagram/IGListKit) to Swift
- [PHDiff](https://github.com/andre-alves/PHDiff)

There are other algorithms and implementations available, for example:

- [Dwifft](https://github.com/jflinter/Dwifft) - Longest common subsequence algorithm
- [Differ](https://github.com/tonyarnold/Differ) - Longest common subsequence algorithm
- [Changeset](https://github.com/osteslag/Changeset) - Wagner-Fischer algorithm (specific implementation of Levenstein algorithm).

Because algorithms are built differently, but have some common traits, `SingleSectionStorage` implements two concrete subclasses, that work with algorithms with `Equatable` elements and algorithms that work with `Hashable` elements - `SingleSectionEquatableStorage` and `SingleSectionHashableStorage`.

#### Algorithm adapter

To work with specific algorithm, you would need to create a thin adapter, that converts results of algorithm work to models, compatible with `DTModelStorage`. Here are some examples of how this can be done:

- [Adapter for Dwifft](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Tests/Specs/SingleSectionStorageTestCase.swift#L18-L30)
- [Adapter for HeckelDiff](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Tests/Specs/SingleSectionStorageTestCase.swift#L32-L48)
- [Adapter for Changeset](https://github.com/DenTelezhkin/DTTableViewManager/blob/master/Example/Example%20controllers/AutoDiffSearchViewController.swift#L14-L26)

#### Example

After adapter has been built, you need to implement `EntityIdentifiable` protocol on your data models to provide way to identify models:

```swift
extension Post : EntityIdentifiable {
    public var identifier: AnyHashable { return id }
}
```

Create storage:

```swift
let storage = SingleSectionEquatableStorage(items: arrayOfPosts, differ: ChangesetDiffer())
```

Set new array of items and automatically calculate all diffs:

```swift
storage.setItems(newPosts)
```

Full example of automatically animating items in `UITableView` can be seen in [DTTableViewManager repo](https://github.com/DenTelezhkin/DTTableViewManager/blob/master/Example/Example%20controllers/AutoDiffSearchViewController.swift)

#### Adding items

When you show list of items, common task is to add new loaded items to this list (for example load more content). Doing that is really simple:

```swift
storage.addItems(newItems)
```

Sometimes you may want to customize how items are accumulated in resulting collection of items. For example when content changed in time between first page request and second page request in load-more scenario. If back-end does not handle this for iOS side, you may want to build handling of such cases on client side. To do that, `DTModelStorage` provides  `AccumulationStrategy` protocol, that consists of single method:

```swift
protocol AccumulationStrategy {
    func accumulate<T:Identifiable>(oldItems: [T], newItems: [T]) -> [T]
}
```

This strategy determines how new collection of items will be formed. `DTModelStorage` provides three concrete implementations of this protocol:

- `AdditiveAccumulationStrategy` - default strategy, that simply adds oldItems to newItemsArray.
- `UpdateOldValuesAccumulationStrategy` - replaces old values with new values from `newItems` array - uniqueness is determined by `Identifiable` `identifier` property
- `DeleteOldValuesAccumulationStrategy` - deletes old items, new values remain in new location as returned by `newArray` - uniqueness is determined by `EntityIdentifiable` `identifier` property.

To use any of the strategies, just call `addItems` method with additional parameter:

```swift
storage.addItems(newItems, UpdateOldValuesAccumulationStrategy())
```

#### Several model types in SingleSectionStorage

`SingleSectionStorage` class uses generics to determine it's item type. While it provides compile-time guarantees for item type, it unfortunately prevents using several model types in `SingleSectionStorage` using `Any` type or a protocol. To do that, Swift needs to implement feature called [Generalized existentials](https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#existentials). Unfortunately, at the moment of writing (Xcode 12, Swift 5.3) this feature is not implemented.

Therefore, to support several data models type in `SingleSection` we can use technique called type-erasing. We can build generic wrapper class, that implements all protocols that are required, but actually accepts `Any` value:

```swift
struct AnyIdentifiableEquatable: Identifiable, Equatable {
    let value : Any
    let equals: (Any) -> Bool
    let identifier: AnyHashable

    init<T:Identifiable & Equatable>(_ value: T) {
        self.value = value
        equals = {
            guard let instance = $0 as? T else { return false }
            return instance == value
        }
        identifier = value.identifier
    }

    static func == (lhs: AnyIdentifiableEquatable, rhs: AnyIdentifiableEquatable) -> Bool {
        return lhs.equals(rhs.value) || rhs.equals(lhs.value)
    }
}
```

This way you can create a storage, that accepts any number of data models:

```swift
let typeErasedInstances = [AnyIdentifiableEquatable(Foo()), AnyIdentifiableEquatable(Bar())]
let storage = SingleSectionEquatableStorage(items: typeErasedInstances, differ: DwifftDiffer())
```

Quite ugly, I know. But that seems like the only option that is possible today.
