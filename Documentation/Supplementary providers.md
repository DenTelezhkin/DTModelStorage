## Supplementary model providers

All 5 implemented storages have a single supplementary model provider API, that consists of three closures:

* `headerModelProvider`
* `footerModelProvider`
* `supplementaryModelProvider`

`supplementaryModelProvider` closure setter has been overridden to allow calling `headerModelProvider` and `footerModelProvider`. So, for example, if closures are setup in the following way:

```swift
storage.headerModelProvider = { index in [1,2,3][index] }
storage.supplementaryModelProvider = { kind, index in [4,5,6][index.item] }
storage.supplementaryHeaderKind = "Foo"
```

Then supplementary providers will work as shown below:

```swift
storage.supplementaryModel(ofKind: "Foo", forSectionAt: IndexPath(item: 0, section:0)) // 1
storage.supplementaryModel(ofKind: "Bar", forSectionAt: IndexPath(item: 0, section:0)) // 4
```
