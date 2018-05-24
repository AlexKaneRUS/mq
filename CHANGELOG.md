# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.4.0] - 2018-05-24
### Added
- `MonadState` into `MQMonad`. Now it is `MQMonadS s a`.

## [0.1.3.1] - 2018-05-23
### Changed
- closeM and terminateM functions added for destruction of Context

## [0.1.3.0] - 2018-05-18
### Changed
- Error message has codes now.
- Conroller host moved to deploy section for the component config.json.

## [0.1.2.1] - 2018-05-17
### Changed
- `String` is not so fast as `Text`.

## [0.1.2.0] - 2018-05-17
### Changed
- Key type in Message map changed from `ByteString` to `String`.

## [0.1.2.0] - 2018-05-17
### Changed
- Key type in Message map changed from `ByteString` to `String`.

## [0.1.1.0] - 2018-05-14
### Changed
- Working with tags

## [0.1.0.4] - 2018-05-11
### Changed
- New error handling during execution of runMQMonad

## [0.1.0.3] - 2018-04-28
### Changed
- New logic for validation of tags

## [0.1.0.1] - 2018-04-26
### Added
- Initial version

## [0.1.0.0] - 2018-04-06
### Added
- Initial version
