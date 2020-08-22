# StringSplitter

[![Build Status](https://travis-ci.org/chocolateboy/string_splitter.svg)](https://travis-ci.org/chocolateboy/string_splitter)
[![Gem Version](https://img.shields.io/gem/v/string_splitter.svg)](https://rubygems.org/gems/string_splitter)

<!-- toc -->

- [NAME](#name)
- [INSTALLATION](#installation)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [WHY?](#why)
- [CAVEATS](#caveats)
  - [Differences from String#split](#differences-from-stringsplit)
- [COMPATIBILITY](#compatibility)
- [VERSION](#version)
- [SEE ALSO](#see-also)
  - [Gems](#gems)
  - [Articles](#articles)
- [AUTHOR](#author)
- [COPYRIGHT AND LICENSE](#copyright-and-license)

<!-- tocstop -->

# NAME

StringSplitter - `String#split` on steroids

# INSTALLATION

```ruby
gem "string_splitter"
```

# SYNOPSIS

```ruby
require "string_splitter"

ss = StringSplitter.new
```

**Same as `String#split`**

```ruby
ss.split("foo bar baz")
ss.split("foo bar baz", " ")
ss.split("foo bar baz", /\s+/)
# => ["foo", "bar", "baz"]

ss.split("foo", "")
ss.split("foo", //)
# => ["f", "o", "o"]

ss.split("", "...")
ss.split("", /.../)
# => []
```

**Split at the first delimiter**

```ruby
ss.split("foo:bar:baz:quux", ":", at: 1)
ss.split("foo:bar:baz:quux", ":", select: 1)
# => ["foo", "bar:baz:quux"]
```

**Split at the last delimiter**

```ruby
ss.split("foo:bar:baz:quux", ":", at: -1)
# => ["foo:bar:baz", "quux"]
```

**Split at multiple delimiter positions**

```ruby
ss.split("1:2:3:4:5:6:7:8:9", ":", at: [1..3, -1])
# => ["1", "2", "3", "4:5:6:7:8", "9"]
```

**Split at all but the first and last delimiters**

```ruby
ss.split("1:2:3:4:5:6", ":", except: [1, -1])
ss.split("1:2:3:4:5:6", ":", reject: [1, -1])
# => ["1:2", "3", "4", "5:6"]
```

**Split from the right**

```ruby
ss.rsplit("1:2:3:4:5:6:7:8:9", ":", at: [1..3, -1])
# => ["1", "2:3:4:5:6", "7", "8", "9"]
```

**Split with negative, descending, and infinite ranges**

```ruby
ss.split("1:2:3:4:5:6:7:8:9", ":", at: ..-3)
# => ["1", "2", "3", "4", "5", "6", "7:8:9"]

ss.split("1:2:3:4:5:6:7:8:9", ":", at: 4...)
# => ["1:2:3:4", "5", "6", "7", "8:9"]

ss.split("1:2:3:4:5:6:7:8:9", ":", at: [1, 5..3, -2..])
# => ["1", "2:3", "4", "5", "6:7", "8", "9"]
```

**Full control via a block**

```ruby
result = ss.split("1:2:3:4:5:6:7:8", ":") do |split|
  split.pos % 2 == 0
end
# => ["1:2", "3:4", "5:6", "7:8"]
```

```ruby
string = "banana".chars.sort.join # "aaabnn"

ss.split(string, "") do |split|
    split.rhs != split.lhs
end
# => ["aaa", "b", "nn"]
```

# DESCRIPTION

Many languages have built-in `split` functions/methods for strings. They behave
similarly (notwithstanding the occasional
[surprise](https://chriszetter.com/blog/2017/10/29/splitting-strings/)), and
handle a few common cases, e.g.:

* limiting the number of splits
* including the separator(s) in the results
* removing (some) empty fields

But, because the API is squeezed into two overloaded parameters (the delimiter
and the limit), achieving the desired results can be tricky. For instance,
while `String#split` removes empty trailing fields (by default), it provides no
way to remove *all* empty fields. Likewise, the cramped API means there's no
way to, e.g., combine a limit (positive integer) with the option to preserve
empty fields (negative integer), or use backreferences in a delimiter pattern
without including its captured subexpressions in the result.

If `split` was being written from scratch, without the baggage of its legacy
API, it's possible that some of these options would be made explicit rather
than overloading the parameters. And, indeed, this is possible in some
implementations, e.g. in Crystal:

```ruby
":foo:bar:baz:".split(":", remove_empty: false)
# => ["", "foo", "bar", "baz", ""]

":foo:bar:baz:".split(":", remove_empty: true)
# => ["foo", "bar", "baz"]
````

StringSplitter takes this one step further by moving the configuration out of
the method altogether and delegating the strategy — i.e. which splits should be
accepted or rejected — to a block:

```ruby
ss = StringSplitter.new

ss.split("foo:bar:baz", ":") { |split| split.index == 0 }
# => ["foo", "bar:baz"]

ss.split("foo:bar:baz:quux", ":") do |split|
  split.position == 1 || split.position == 3
end
# => ["foo", "bar:baz", "quux"]
```

As a shortcut, the common case of splitting (or not splitting) at one or more
positions is supported by dedicated options:

```ruby
ss.split("foo:bar:baz:quux", ":", select: [1, -1])
# => ["foo", "bar:baz", "quux"]

ss.split("foo:bar:baz:quux", ":", reject: [1, -1])
# => ["foo:bar", "baz:quux"]
```

# WHY?

I wanted to split semi-structured output into fields without having to resort
to a regex or a full-blown parser.

As an example, the nominally unstructured output of many Unix commands is often
formatted in a way that's tantalizingly close to being
[machine-readable](https://en.wikipedia.org/wiki/Delimiter-separated_values),
apart from a few pesky exceptions, e.g.:

```bash
$ ls -l

-rw-r--r-- 1 user users   87 Jun 18 18:16 CHANGELOG.md
-rw-r--r-- 1 user users  254 Jun 19 21:21 Gemfile
drwxr-xr-x 3 user users 4096 Jun 19 22:56 lib
-rw-r--r-- 1 user users 8952 Jun 18 18:16 LICENSE.md
-rw-r--r-- 1 user users 3134 Jun 19 22:59 README.md
```

These lines can *almost* be parsed into an array of fields by splitting them on
whitespace. The exception is the date (columns 6-8), i.e.:

```ruby
line = "-rw-r--r-- 1 user users   87 Jun 18 18:16 CHANGELOG.md"
line.split
```

gives:

```ruby
["-rw-r--r--", "1", "user", "users", "87", "Jun", "18", "18:16", "CHANGELOG.md"]
```

instead of:

```ruby
["-rw-r--r--", "1", "user", "users", "87", "Jun 18 18:16", "CHANGELOG.md"]
```

One way to work around this is to parse the whole line, e.g.:

```ruby
line.match(/^(\S+) \s+ (\d+) \s+ (\S+) \s+ (\S+) \s+ (\d+) \s+ (\S+ \s+ \d+ \s+ \S+) \s+ (.+)$/x)
```

But that requires us to specify *everything*. What we really want is a version
of `split` which allows us to veto splitting for the 6th and 7th delimiters
(and to stop after the 8th delimiter), i.e. control over which splits are
accepted, rather than being restricted to the single, baked-in strategy
provided by the `limit` parameter.

By providing a simple way to accept or reject each split, StringSplitter makes
cases like this easy to handle, either via a block:

```ruby
ss.split(line) do |split|
  case split.position when 1..5, 8 then true end
end
# => ["-rw-r--r--", "1", "user", "users", "87", "Jun 18 18:16", "CHANGELOG.md"]
```

Or via its option shortcut:

```ruby
ss.split(line, at: [1..5, 8])
# => ["-rw-r--r--", "1", "user", "users", "87", "Jun 18 18:16", "CHANGELOG.md"]
```

# CAVEATS

## Differences from String#split

Unlike `String#split`, StringSplitter doesn't trim the string before splitting
if the delimiter is omitted or a single space, e.g.:

```ruby
" foo bar baz ".split          # => ["foo", "bar", "baz"]
" foo bar baz ".split(" ")     # => ["foo", "bar", "baz"]

ss.split(" foo bar baz ")      # => ["", "foo", "bar", "baz", ""]
ss.split(" foo bar baz ", " ") # => ["", "foo", "bar", "baz", ""]
```

`String#split` omits the `nil` values of unmatched optional captures:

```ruby
"foo:bar:baz".scan(/(:)|(-)/)  # => [[":", nil], [":", nil]]
"foo:bar:baz".split(/(:)|(-)/) # => ["foo", ":", "bar", ":", "baz"]
```

StringSplitter preserves them by default (if `include_captures` is true, as it
is by default), though they can be omitted from spread captures by passing
`:compact` as the value of the `spread_captures` option:

```ruby
s1 = StringSplitter.new(spread_captures: true)
s2 = StringSplitter.new(spread_captures: false)
s3 = StringSplitter.new(spread_captures: :compact)

s1.split("foo:bar:baz", /(:)|(-)/) # => ["foo", ":", nil, "bar", ":", nil, "baz"]
s2.split("foo:bar:baz", /(:)|(-)/) # => ["foo", [":", nil], "bar", [":", nil], "baz"]
s3.split("foo:bar:baz", /(:)|(-)/) # => ["foo", ":", "bar", ":", "baz"]
```

# COMPATIBILITY

StringSplitter is tested and supported on all versions of Ruby [supported by
the ruby-core team](https://www.ruby-lang.org/en/downloads/branches/), i.e.,
currently, Ruby 2.5 and above.

# VERSION

0.7.2

# SEE ALSO

## Gems

- [rsplit](https://github.com/Tatzyr/rsplit) - a reverse-split implementation (only works with string delimiters)

## Articles

- [Splitting Strings](https://chriszetter.com/blog/2017/10/29/splitting-strings/)

# AUTHOR

[chocolateboy](mailto:chocolate@cpan.org)

# COPYRIGHT AND LICENSE

Copyright © 2018-2020 by chocolateboy.

This is free software; you can redistribute it and/or modify it under the
terms of the [Artistic License 2.0](https://www.opensource.org/licenses/artistic-license-2.0.php).
