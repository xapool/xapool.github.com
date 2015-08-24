#!/usr/bin/env ruby

unless ARGV[0]
  puts 'Usage: newpost "the post title"'
  exit(-1)
end

date_prefix = Time.now.strftime("%Y-%m-%d")
postname = ARGV[0].strip.downcase.gsub(/ /, '-')
post = "./_posts/#{date_prefix}-#{postname}.md"

header = <<-END
---
layout: post
title: #{ARGV[0]}
categories:
tags:
---

END

File.open(post, 'w') do |f|
  f << header
end

system("open", post)
