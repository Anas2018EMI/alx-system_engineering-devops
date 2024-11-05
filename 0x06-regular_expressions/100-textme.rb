#!/usr/bin/env ruby

# The regular expression matches:
# [from:VALUE] followed by [to:VALUE] followed by [flags:VALUE]
# and extracts just the values

puts ARGV[0].scan(/\[from:(.*?)\] \[to:(.*?)\] \[flags:(.*?)\]/).map { |match| match.join(',') }[0]
