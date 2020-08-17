## 0.6.0 - TBD

### Breaking Changes

- EOL Ruby versions (2.3 and 2.4) are no longer supported
- rename the `remove_empty` option `remove_empty_fields`
- rename the `exclude` option (an alias for `reject`) `except`

#### Fixes

- correctly handle backreferences in delimiter patterns

#### Features

- add support for descending, negative, and infinite ranges,
  e.g. `ss.split(str, ":", at: [..4, 4.., 3..1, -1..-3])` etc.

## 0.5.1 - 2018-07-01

- set StringSplitter::VERSION when `string_splitter.rb` is loaded

## 0.5.0 - 2018-06-26

- don't treat string delimiters as patterns
- add a `reject`/`exclude` option which rejects splits at the specified positions
- add a `select` alias for `at`

## 0.4.0 - 2018-06-24

### Breaking Changes

- remove the `offset` alias for `split.index`

## 0.3.1 - 2018-06-24

- remove trailing empty field when the separator is empty
  ([#1](https://github.com/chocolateboy/string_splitter/issues/1))

## 0.3.0 - 2018-06-23

### Breaking Changes

- rename the `default_separator` option `default_delimiter`

## 0.2.0 - 2018-06-22

### Breaking Changes

- make `index` (AKA `offset`) 0-based and add `position` (AKA `pos`) as the
  1-based accessor

## 0.1.0 - 2018-06-22

### Breaking Changes

- the block now takes a single `split` object with an `index` accessor, rather
  than seperate `index` and `split` arguments

### Features

- add support for negative indices in the value supplied to the `at` option
- add a `count` field to the split object containing the total number of splits

## 0.0.1 - 2018-06-21

- initial release
