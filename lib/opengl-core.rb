require 'opengl-core/opengl_stub'
require 'opengl-core/gl_sym'
require 'opengl-core/gl_enums'
require 'opengl-core/gl_commands'

module Gl

  def have_gl_command?(command)
    !!GlSym.__load_gl_sym__(command.intern)
  end

  def load_all_gl_commands!()
    GlSym::GL_COMMAND_TYPES.each_key { |fnsym| GlSym.__load_gl_sym__(fnsym) }
    self
  end

  extend self

end
