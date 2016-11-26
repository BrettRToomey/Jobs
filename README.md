# Jobs
[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org) ![Build Status](https://travis-ci.org/BrettRToomey/Jobs.svg?branch=master)[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/BrettRToomey/Jobs/master/LICENSE.md)

A minimalistic job system in Swift, for Swift

## Getting started 🚀
Creating a new `Job` is as simple as:
```swift
Jobs.add(interval: .seconds(4)) {
    print("👋 I'm printed 4 times!")
}
```

## Intervals ⏲
The `Duration` enumeration currently supports `.seconds`, `.days` and `.weeks`.
```swift
Jobs.add(interval: .days(5)) {
    print("See you every 5 days.")
}
```
#### Syntax candy 🍭
It's possible to create a `Duration` from an `Int` and a `Double`.
```swift
10.seconds // `Duration.seconds(10)`
2.days // `Duration.days(2)`
3.weeks // `Duration.weeks(3)`
```

## Starting a job 🎬
By default, `Job`s are started automatically, but if you wish to start one yourself, even at a later point in time, just do the following:
```swift
let job = Jobs.add(interval: 2.seconds, autoStart: false) {
    print("I wasn't started right away.")
}
//...
job.start()
```

## Stopping a job ✋
Giving up has never been so easy!
```swift
job.stop()
```

## Error handling ❌
Sometimes jobs can fail, that's okay, we have you covered.
```swift
Jobs.add(
    interval: 10.seconds,
    action: {
        throw Error.someError
    }, 
    onError: { error in
        print("caught an error: \(error)")
    }
)
```

#### Retry on failure ⭕️
By default, jobs are ran again on error. If you wish to change this behavior then set the following attribute: 
```swift
myJobName.retryOnFail = false
```