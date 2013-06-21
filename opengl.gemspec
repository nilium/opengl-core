# This file is part of ruby-opengl.
# Copyright (c) 2013 Noel Raymond Cower. All rights reserved.
# See COPYING for license details.

Gem::Specification.new { |s|
  s.name        = 'opengl'
  s.version     = '0.0.1'
  s.date        = '2013-06-20'
  s.summary     = 'OpenGL'
  s.description = 'OpenGL bindings for Ruby 2.x'
  s.authors     = [ 'Noel Raymond Cower' ]
  s.email       = 'ncower@gmail.com'
  s.files       = Dir.glob('lib/**/*.rb') +
                  Dir.glob('ext/**/*.{c,rb}')
  s.extensions << 'ext/opengl/extconf.rb'
  s.homepage    = 'https://github.com/nilium/ruby-opengl'
  s.license     = 'Simplified BSD'

  s.add_development_dependency 'nokogiri'
}
