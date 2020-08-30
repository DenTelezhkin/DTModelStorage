## RealmStorage

`RealmStorage` class is made to work with [realm.io](https://realm.io) databases. It works with sections, that contain Realm.Results object.

Creating storage and filling it with results is very easy:

```
let results = try! Realm().objects(Dog)

let storage = RealmStorage()
storage.addSection(with:results)
```

That's it! Results are automatically monitored, and refreshed, if Realm objects change.

**Note** You should not use RealmStorage with multiple sections, because it may lead to crashes when simultaneous UI updates make UI state inconsistent(https://github.com/DenTelezhkin/DTModelStorage/issues/21).

One possible solution to this are diffable datasources in iOS 13, where you should be able to construct all sections manually thus avoiding crashes.

## Availability

Currently `RealmStorage` is only available through CocoaPods package manager. The reason for that is subspecs feature, that only CocoaPods has. Nor SPM nor Carthage do not support installing specific part of the framework with it's dependencies, and asking `DTModelStorage` users to always download (and if used with Carthage - build) Realm is too harsh, and not worth it.

If you want to use RealmStorage with SPM or Carthage, consider manually copying and pasting files from Sources/RealmStorage folder(there are only two files, so hopefully it's not too big of a hassle).
