## 0.7.3 - 2020-08-24

#### Changes

- avoid exposing an internal Split method inside blocks

## 0.7.2 - 2020-08-22

#### Fixes

- fix/test default delimiter + `remove_empty_fields`

## 0.7.1 - 2020-08-22

#### Changes

- performance improvements
  - delegate to `String#split` where possible
  - use a regular class for Split rather than values.rb
  - create Split objects directly rather than allocating intermediate hashes

## 0.7.0 - 2020-08-21

#### Breaking Changes

- `String#split` incompatibility: we no longer trim the string (with
  `String#strip`) before splitting if the delimiter is omitted

## 0.6.0 - 2020-08-20

#### Breaking Changes

- `ss.split(str, " ")` is no longer treated the same as `ss.split(str)` i.e.
  unlike Ruby's `String#split`, the former no longer strips the string before
  splitting
- rename the `remove_empty` option `remove_empty_fields`
- rename the `exclude` option `except` (alias for `reject`)

#### Features

- add support for descending, negative, and infinite ranges,
  e.g. `ss.split(str, ":", at: [..4, 4..., 3..1, -1..-3])` etc.

#### Fixes

- correctly handle backreferences in delimiter patterns

## 0.5.1 - 2018-07-01

#### Changes

- set StringSplitter::VERSION when `string_splitter.rb` is loaded

## 0.5.0 - 2018-06-26

#### Features

- add a `reject`/`exclude` option which rejects splits at the specified positions
- add a `select` alias for `at`

#### Fixes

- don't treat string delimiters as patterns

## 0.4.0 - 2018-06-24

#### Breaking Changes

- remove the `offset` alias for `split.index`

## 0.3.1 - 2018-06-24

#### Fixes

- remove trailing empty field when the separator is empty
  ([#1](https://github.com/chocolateboy/string_splitter/issues/1))

## 0.3.0 - 2018-06-23

#### Breaking Changes

- rename the `default_separator` option `default_delimiter`

## 0.2.0 - 2018-06-22

#### Breaking Changes

- make `index` (AKA `offset`) 0-based and add `position` (AKA `pos`) as the
  1-based accessor

## 0.1.0 - 2018-06-22

#### Breaking Changes

- the block now takes a single `split` object with an `index` accessor, rather
  than separate `index` and `split` arguments

#### Features

- add support for negative indices in the value supplied to the `at` option
- add a `count` field to the split object containing the total number of splits

## 0.0.1 - 2018-06-21

- initial release
