#!/usr/bin/env ruby

require 'irb'
require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 10000
IRB.conf[:HISTORY_FILE] = File.join(Dir.home, '.irb_history')

require 'string_splitter'

ss1 = StringSplitter.new
ss2 = StringSplitter.new(remove_empty: true)
ss3 = StringSplitter.new(spread_captures: false)

line = 'drwxr-xr-x 2 user users 4096 Jun 18 18:16 .bundle'
s1 = 'foo:bar:baz:quux'
s2 = ':foo:bar:baz:quux:'

binding.irb

# IRB.start(__FILE__)
