#!/usr/bin/env ruby

#
# QED test coverage report using SimpleCov.
#
# Use `$properties.coverage_folder` to set directory in which to store
# coverage report this defaults to `log/coverage`.
#
# IMPORTANT! Unfortunately this will not give us a reliable report
# b/c QED uses the RC gem, so SimpleCov can't differentiate the two.
#
config 'qed', profile: 'cov' do
  #puts "QED w/coverage!"
  dir = $properties.coverage_folder
  require 'simplecov'
  SimpleCov.command_name 'QED'
  SimpleCov.start do
    coverage_dir(dir || 'log/coverage')
    #add_group "Label", "lib/qed/directory"
  end
end

#
# Pry
#
config 'pry' do
  puts "RC on Pry!"
  $LOAD_PATH.unshift('lib')
end

#
# Rake tasks 
#
config 'rake' do
  desc 'run unit tests'
  task 'test' do
    sh 'qed'
  end
end

=begin
#
# Detroit assembly.
#
config 'detroit' do
  service :email do |s|
    s.mailto = ['ruby-talk@ruby-lang.org', 
                'rubyworks-mailinglist@googlegroups.com']
  end

  service :gem do |s|
    s.gemspec = 'pkg/ostruct2.gemspec'
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

  service :vclog do |s|
    s.output = ['log/history.html',
                'log/changes.html']
  end
end
=end
