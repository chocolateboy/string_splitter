## 0.3.1 - TBD

- remove trailing empty field when the separator is empty (#1)

## 0.3.0 - 2018-06-23

- **breaking change**: rename the `default_separator` option to `default_delimiter`
  - to avoid ambiguity in the code, refer to the input pattern/string as the
    "delimiter" and the matched string as the "separator"

## 0.2.0 - 2018-06-22

- **breaking change**: make `index` (AKA `offset`) 0-based and add `position`
  (AKA `pos`) as the 1-based accessor

## 0.1.0 - 2018-06-22

- **breaking change**: the block now takes a single `split` object with an
  `index` accessor, rather than seperate `index` and `split` arguments
- add support for negative indices in the value supplied to the `at` option
- add a `count` field to the split object containing the total number of splits

## 0.0.1 - 2018-06-21

- initial release
