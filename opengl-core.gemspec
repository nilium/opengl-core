#  This file is part of the opengl-core project.
#  <https://github.com/nilium/ruby-opengl>
#
#  -----------------------------------------------------------------------------
#
#  opengl-core.gemspec
#    opengl-core Gem specification.


Gem::Specification.new do |s|
  s.name        = 'opengl-core'
  s.version     = '2.0.0'
  s.summary     = 'OpenGL core profile bindings'
  s.description = 'OpenGL core profile (3.2 onward, no deprecated functionality) bindings for Ruby 2.x. Generated from Khronos XML spec files.'
  s.authors     = [ 'Noel Raymond Cower' ]
  s.email       = 'ncower@gmail.com'
  s.files       = Dir.glob('lib/**/*.rb') + ['README.md', 'COPYING']
  s.homepage    = 'https://github.com/nilium/ruby-opengl'
  s.license     = 'Simplified BSD'
  s.required_ruby_version = '~> 2'

  s.add_development_dependency 'nokogiri', '~> 1.6'
end
