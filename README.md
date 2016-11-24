# Jobs
[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org) ![Build Status](https://travis-ci.org/BrettRToomey/Jobs.svg?branch=master)

A job system in Swift, for Swift

## Getting started
Start Jobs by calling
```swift
try Jobs.shared.start()
```

And add a new `job` like so
```swift
Jobs.shared.add(interval: .seconds(4)) {
    print("I am ran every 4 seconds.")
}
```

## Intervals
The `Duration` enumeration currently supports `.seconds`, `.days` and `.weeks`
```swift
Jobs.shared.add(interval: .days(5)) {
    print("I am ran every 5 days.")
}
```

## Removal
You are returned a **discardable** `JobId (UInt)` when you add a `job`. You need this `id` if you want to remove it at a later time.
```swift
//keep a reference to `id` so we can use it to
//remove the job later
let id = Jobs.shared.add( //... {
    // ...
}

Jobs.shared.remove(id)
```

## Cleanup
Stop Jobs by calling 
```swift
try Jobs.shared.stop()
```