#!/usr/bin/env ruby

default :test

desc 'run unit tests'
task 'test' do
  sh 'qed'
end

task :prep do
  sh 'mast -u'
  sh 'index -u var'
end
