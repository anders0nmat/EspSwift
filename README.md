# EspSwift

A swift wrapper for some ESP standard components.

## Usage

Add the following package to your `Package.swift` dependencies
```swift
.package(url: "https://github.com/anders0nmat/EspSwift.git", branch: "main"),
```

Add the dependency to your target
```swift
.product(name: "EspSwift", package: "EspSwift"),
```

Import the packages you need into your module, e.g.
```swift
import FreeRTOS
import WiFi
```

## Example Usage

See [swift-esp-http](https://github.com/anders0nmat/swift-esp-http)


