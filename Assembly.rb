#!/usr/bin/env ruby

# Detroit assembly.

service :gem do |s|
  s.gemspec = '.gemspec'
end

service :github do |s|
  s.folder = 'web'
end

service :dnote do |s|
  s.title  = 'Source Notes'
  s.output = 'log/notes.html'
end

service :locat do |s|
  s.output = 'log/locat.html'
end

service :qedoc do |s|
  s.files  = "demo/"
  s.output = "DEMO.md"
  s.title  = "OStruct2"
end

service :vclog do |s|
  s.output = ['log/history.html',
              'log/changes.html']
end

service :email do |s|
  s.mailto = ['ruby-talk@ruby-lang.org', 
              'rubyworks-mailinglist@googlegroups.com']
end

service :yard do |s|
  s.yardopts = true
  s.priority = -1
end

