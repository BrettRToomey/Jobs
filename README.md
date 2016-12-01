# Jobs
[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org) ![Build Status](https://travis-ci.org/BrettRToomey/Jobs.svg?branch=master)
[![codecov](https://codecov.io/gh/BrettRToomey/Jobs/branch/master/graph/badge.svg)](https://codecov.io/gh/BrettRToomey/Jobs)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/BrettRToomey/Jobs/master/LICENSE.md)

A minimalistic job system in Swift, for Swift

##### Table of Contents
* [Getting started](#getting-started-)
* [Intervals](#intervals-)
  * [Syntax candy](#syntax-candy-)
* [Starting a job](#starting-a-job-)
* [Stopping a job](#stopping-a-job-)
* [Error handling](#error-handling-)
  * [Retry on failure](#retry-on-failure-)

## Integration
Update your `Package.swift` file.
```swift
.Package(url: "https://github.com/BrettRToomey/Jobs.git", majorVersion: 0)
```

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
        return RecoverStrategy.default
    }
)
```

#### Retry on failure ⭕️
By default, jobs will be attempted again after a five second delay. If you wish to override this behavior you must first implement an `onError` handler and return one of the following `RecoveryStrategy` cases.
```swift
.none //do not retry
.default //retry after 5 seconds
.retry(after: Duration) //retry after specified duration
```
Here's a small sample:
```swift 
enum Error: Swift.Error {
  case recoverable
  case abort
}

Jobs.add(
    interval: 1.days,
    action: {
        //...
    }, 
    onError: { error in
        switch error {
        //we cannot recover from this
        case .abort:
            //do not retry
            return .none

        //we can recover from this
        case .recoverable:
            //... recovery code

            //try again in 15 seconds
            return .retry(after: 15.seconds)
        }
    }
)
```
