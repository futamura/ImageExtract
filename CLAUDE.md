# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ImageExtract is a Swift library that extracts the pixel size of a remote image without downloading the whole file: it streams only the first chunk of the response and parses the image header. Supported formats: JPEG, PNG, GIF, BMP, WebP — all parsed byte-by-byte with no external dependencies (WebP included; libwebp was removed intentionally, do not reintroduce it).

Platforms: iOS 15+ / macOS 12+. Language mode: Swift 5 (not Swift 6 strict concurrency). Distribution: Swift Package Manager and Carthage (CocoaPods support was dropped).

## Commands

```sh
# Full test suite via SPM (macOS)
swift test

# Single test class / single test
swift test --filter ImageDecoderTests
swift test --filter ImageDecoderTests/testWebPLosslessSize

# Xcode project tests (both must stay green)
xcodebuild test -project ImageExtract.xcodeproj -scheme ImageExtract-macOS -destination 'platform=macOS'
xcodebuild test -project ImageExtract.xcodeproj -scheme ImageExtract-iOS -destination 'platform=iOS Simulator,name=<any iPhone>'

# Lint (CI runs this with --strict; keep it clean)
swiftlint --strict --quiet

# Regenerate API docs (published via GitHub Pages from docs/)
jazzy
rm -rf docs/docsets   # jazzy 0.15 emits a misnamed hidden .docset; Dash docsets are not published
```

Integration tests (`ImageExtractSyncTests`, `ImageExtractAsyncTests`, `ImageFormatTests` invalid-byte cases) fetch real images from `raw.githubusercontent.com/futamura/ImageExtractTest` and require network access. Decoder unit tests (`ImageDecoderTests`) are offline and use hand-crafted header bytes.

## Architecture

Request flow: `ImageExtract` (public API, `Source/ImageExtract.swift`) → `ImageLoader` (URLSession-based queue that downloads only up to `ImageChunkSize` bytes, then cancels the connection once a size is parsed) → `ImageFormat` (magic-number detection, `Source/ImageFormat.swift`) → per-format decoder classes in `Source/ImageDecoder.swift` (`JPGDecoder`, `PNGDecoder`, `GIFDecoder`, `BMPDecoder`, `WEBPDecoder`).

Points that are easy to get wrong:

- **Dual project definition.** `Package.swift` and `ImageExtract.xcodeproj` both describe the build and must be kept in sync manually (source files, deployment targets, test resources). CI runs both.
- **Test resources.** `Tests/Resources/TestImage.json` is referenced by the xcodeproj test targets and declared as an SPM resource. Tests load it through `Bundle.current` (`Tests/DataSet.swift`), which resolves to `Bundle.module` under SWIFT_PACKAGE and to `Bundle(for:)` under the xcodeproj.
- **Binary parsing helpers.** `Source/Helper.swift` defines a generic `Data` subscript (`data[offset, length]`) that loads raw little-endian values; decoders mix it with per-byte reads. Header bytes are untrusted input — never force-unwrap while parsing (a `String(data:encoding:)!` here used to crash the test suite on non-ASCII headers).
- **WebP sizes** are read straight from the RIFF container: VP8X = 24-bit canvas size minus one, VP8L = two packed 14-bit fields after the 0x2F signature, VP8 = 14-bit fields with 2-bit upscale flags that must be masked off. See the tests in `Tests/ImageDecoderTests.swift` for reference byte layouts.
