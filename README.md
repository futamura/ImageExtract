[![CI](https://github.com/futamura/ImageExtract/actions/workflows/ci.yml/badge.svg)](https://github.com/futamura/ImageExtract/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/futamura/ImageExtract/branch/master/graph/badge.svg)](https://codecov.io/gh/futamura/ImageExtract)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg)](https://swift.org/package-manager/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/futamura/ImageExtract)
[![Platform](https://img.shields.io/badge/platform-ios%20|%20macos-lightgrey.svg)](https://github.com/futamura/ImageExtract)
![Language](https://img.shields.io/badge/Language-Swift%205.9%2B-orange.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

# ImageExtract
A Swift library to allows you to extract the size of an image without downloading.

## Requirements

- iOS 15.0 or later
- macOS 12.0 or later
- Swift 5.9 or later (Xcode 15 or later)

## Supported image format

- JPEG
- PNG
- GIF
- BMP
- WebP

All formats including WebP are decoded by parsing the image header directly. No external dependencies are required.

## Installation

### Swift Package Manager

In Xcode, choose File > Add Package Dependencies… and enter:

```
https://github.com/futamura/ImageExtract.git
```

Or add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/futamura/ImageExtract.git", from: "3.0.0")
]
```

### Carthage

Add the following to your `Cartfile` and follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

```
github "futamura/ImageExtract"
```

## Usage

Read the [usage](https://futamura.github.io/ImageExtract/usage.html) and the [API reference](https://futamura.github.io/ImageExtract/Classes/ImageExtract.html) for detailed information.

### Initialization

Just import ImageExtract framework:
```swift
import ImageExtract
```

### Synchronous and asynchronous request

Get the size of an image synchronously:
```swift
let url: String = "https://example.com/image.jpg"
let extractor: ImageExtract = ImageExtract()
let result: (size: CGSize, isFinished: Bool) = extractor.extract(url)
print(result.size) // (800.0, 600.0)
```

Get the size of an image asynchronously:
```swift
let url: String = "https://example.com/image.jpg"
let extractor: ImageExtract = ImageExtract()
extractor.extract(url) { (url: String?, size: CGSize, isFinished: Bool) in
    print(size) // (800.0, 600.0)
}
```

## Copyright

ImageExtract is released under MIT license, which means you can modify it, redistribute it or use it however you like.
