# This file is part of ruby-opengl.
# Copyright (c) 2013 Noel Raymond Cower. All rights reserved.
# See COPYING for license details.

Gem::Specification.new { |s|
  s.name        = 'opengl-core'
  s.version     = '1.2.0'
  s.date        = '2013-06-20'
  s.summary     = 'OpenGL core profile bindings'
  s.description = 'OpenGL core profile (3.2 onward, no deprecated functionality) bindings for Ruby 2.x. Generated from Khronos XML spec files.'
  s.authors     = [ 'Noel Raymond Cower' ]
  s.email       = 'ncower@gmail.com'
  s.files       = Dir.glob('lib/**/*.rb') +
                  Dir.glob('ext/**/*.{c,rb}')
  s.extensions << 'ext/opengl-core/extconf.rb'
  s.homepage    = 'https://github.com/nilium/ruby-opengl'
  s.license     = 'Simplified BSD'
  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency 'nokogiri'
}
