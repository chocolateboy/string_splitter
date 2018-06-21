# StringSplitter

[![Build Status](https://travis-ci.org/chocolateboy/string_splitter.svg)](https://travis-ci.org/chocolateboy/string_splitter)
[![Gem Version](https://img.shields.io/gem/v/string_splitter.svg)](https://rubygems.org/gems/string_splitter)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [NAME](#name)
- [INSTALLATION](#installation)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [WHY?](#why)
- [VERSION](#version)
- [SEE ALSO](#see-also)
  - [Gems](#gems)
  - [Articles](#articles)
- [AUTHOR](#author)
- [COPYRIGHT AND LICENSE](#copyright-and-license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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

# same as String#split
ss.split("foo bar baz quux")
# => ["foo", "bar", "baz", "quux"]

# split on the first separator
ss.split("foo:bar:baz:quux", ":", at: 1)
# => ["foo", "bar:baz:quux"]

# split on the last separator
ss.rsplit("foo:bar:baz:quux", ":", at: 1)
# => ["foo:bar:baz", "quux"]

# split on multiple separator indices
line = "-rw-r--r-- 1 user users   87 Jun 18 18:16 CHANGELOG.md"
ss.split(line, at: [1..5, 8])
# => ["-rw-r--r--", "1", "user", "users", "87", "Jun 18 18:16", "CHANGELOG.md"]

# full control via a block
ss.split("foo:bar:baz-baz", /[:-]/) do |i, split|
  split.rhs == "baz" && strip.separator == "-"
end
# => ["foo:bar:baz", "baz"]

```

# DESCRIPTION

Many languages have built-in string `split` functions/methods. They behave similarly
(notwithstanding the occasional [surprise](https://chriszetter.com/blog/2017/10/29/splitting-strings/)),
and handle a few common cases e.g.:

* limiting the number of splits
* including the separators in the results
* removing (some) empty fields

But, because the API is squeezed into two overloaded parameters (the separator and the limit),
achieving the desired effects can be tricky. For instance, while `String#split` removes empty
trailing fields (by default), it provides no way to remove *all* empty fields. Likewise, the
cramped API means there's no way to combine e.g. a limit (positive integer) with the option
to preserve empty fields (negative integer).

If `split` was being written from scratch, without the baggage of its legacy API,
it's possible that some of these options would be made explicit rather than overloading
the `limit` parameter. And, indeed, this is possible in some implementations,
e.g. in Crystal:

```ruby
":foo:bar:baz:".split(":", remove_empty: false) # => ["", "foo", "bar", "baz", ""]
":foo:bar:baz:".split(":", remove_empty: true)  # => ["foo", "bar", "baz"]
````

StringSplitter takes this one step further by moving the configuration out of the method altogether
and delegating the strategy — i.e. which splits should be accepted or rejected — to a block:

```ruby
ss = StringSplitter.new

ss.split("foo:bar:baz", ":")  { |i| i == 1 } # => ["foo", "bar:baz"]
ss.rsplit("foo:bar:baz", ":") { |i| i == 1 } # => ["foo:bar", "baz"]
```

As a shortcut, the common case of splitting on separators at one or more indices can be specified
via an option:

```ruby
ss.split('foo:bar:baz:quux', ':', at: [1, 3]) # => ["foo", "bar:baz", "quux"]
```

# WHY?

I wanted to split semi-structured output into fields without having to resort to a regex or a full-blown parser.

As an example, the nominally unstructured output of many Unix commands is, in practice, often formatted in a way
that's tantalizingly close to being machine-readable apart from a few pesky exceptions e.g.:

```bash
$ ls -la

-rw-r--r-- 1 user users   87 Jun 18 18:16 CHANGELOG.md
-rw-r--r-- 1 user users  254 Jun 19 21:21 Gemfile
drwxr-xr-x 3 user users 4096 Jun 19 22:56 lib
-rw-r--r-- 1 user users 8952 Jun 18 18:16 LICENSE.md
-rw-r--r-- 1 user users 3134 Jun 19 22:59 README.md
```

These lines can *almost* be parsed into an array of fields by splitting them on whitespace. The exception is the
date (columns 6-8) i.e.:

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

One way to work around this is to parse the whole line e.g.:

```ruby
line.match(/^(\S+) \s+ (\d+) \s+ (\S+) \s+ (\S+) \s+ (\d+) \s+ (\S+ \s+ \d+ \s+ \S+) (.+)$/x)
```

But that requires us to specify *everything*. What we really want is a version of `split`
which allows us to veto splitting for the 6th and 7th separators i.e. control over which
splits are accepted, rather than being restricted to the single, baked-in strategy provided
by the `limit` parameter.

By providing a simple way to accept or reject each split, StringSplitter makes cases like
this easy to handle, either via a block:

```ruby
ss.split(line) do |i|
  case i when 1..5, 8 then true end
end
# => ["-rw-r--r--", "1", "user", "users", "87", "Jun 18 18:16", "CHANGELOG.md"]
```

Or via its option shortcut:

```ruby
ss.split(line, at: [1..5, 8])
# => ["-rw-r--r--", "1", "user", "users", "87", "Jun 18 18:16", "CHANGELOG.md"]
```

# VERSION

0.0.1

# SEE ALSO

## Gems

- [rsplit](https://github.com/Tatzyr/rsplit) - a reverse-split implementation (only works with string separators)

## Articles

- [Splitting Strings](https://chriszetter.com/blog/2017/10/29/splitting-strings/)

# AUTHOR

[chocolateboy](mailto:chocolate@cpan.org)

# COPYRIGHT AND LICENSE

Copyright © 2018 by chocolateboy.

This is free software; you can redistribute it and/or modify it under the
terms of the [Artistic License 2.0](http://www.opensource.org/licenses/artistic-license-2.0.php).
