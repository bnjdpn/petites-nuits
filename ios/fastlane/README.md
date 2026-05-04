fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Run unit tests

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate localized screenshots (FR-only)

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Push metadata only (no binary)

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Push screenshots only (no binary, no metadata)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build & upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Full App Store release: build + submit (screenshots + metadata uploaded)

### ios release_quick

```sh
[bundle exec] fastlane ios release_quick
```

Quick release without uploading screenshots

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
