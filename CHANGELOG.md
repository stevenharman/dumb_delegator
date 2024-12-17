# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.1.0] 2024-12-17
### Changed
  - Use `__getobj__` to be compatible with the `Delegator` "interface." [@cervantn [14](https://github.com/stevenharman/dumb_delegator/pull/14)]

## [1.0.0] 2020-01-27
### Changed
  - Require Ruby >= 2.4. We may still work with older Rubies, but no promises.
  - Basic introspection support for a DumbDelegator instance: `#inspect`, `#method`, and `#methods`. [[13](https://github.com/stevenharman/dumb_delegator/pull/13)]

### Added
  - Optional support for using a DumbDelegator instance in a `case` statement. [[12](https://github.com/stevenharman/dumb_delegator/pull/12)]

## [0.8.1] 2020-01-25
### Changed
  - Explicitly Require Ruby >= 1.9.3

### Added
  - This CHANGELOG file.
