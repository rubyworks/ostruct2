---
source:
- meta
authors:
- name: Trans
  email: transfire@gmail.com
copyrights:
- holder: Rubyworks
  year: '2010'
  license: BSD-2-Clause
requirements:
- name: detroit
  groups:
  - build
  development: true
- name: qed
  groups:
  - test
  development: true
- name: ae
  groups:
  - test
  development: true
dependencies: []
alternatives: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/ostruct2.git
  scm: git
  name: upstream
resources:
- uri: http://rubyworks.github.com/ostruct2
  label: Website
  type: home
- uri: http://rubydoc.info/gems/ostruct2/frames
  type: docs
- uri: http://github.com/rubyworks/ostruct2
  label: Source Code
  type: code
- uri: http://groups.google.com/group/rubyworks-mailinglist
  label: Mailing List
  type: mail
- uri: http://chat.us.freenode.net/rubyworks
  label: IRC Channel
  type: chat
categories: []
extra: {}
load_path:
- lib
revision: 0
created: '2010-04-21'
summary: A Better OpenStruct
title: OStruct2
version: 0.1.0
name: ostruct2
description: ! 'OStruct2 is a reimplementation of Ruby''s standard ostruct.rb library.

  This new OpenStruct class addresses issues the original has with conflicting

  member names and cloning.'
organization: Rubyworks
date: '2012-05-19'
