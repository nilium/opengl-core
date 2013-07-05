require 'opengl-core/opengl_stub'
require 'opengl-core/gl_sym'
require 'opengl-core/gl_enums'
require 'opengl-core/gl_commands'

module Gl

  # Checks if a GL command is availalbe to use. This necessarily loads the
  # command if it's not yet loaded just to check if it exists, so do not call
  # this from multiple threads when other Gl commands are being loaded. If you
  # want to ensure this only reads, you can call load_all_gl_commands! ahead of
  # time and query it afterward.
  def have_gl_command?(command)
    !!GlSym.__load_gl_sym__(command.intern)
  end

  # Does what it says on the tin. Should only be called once, preferably from
  # the main thread, though I'm not aware of any thread requirements re: symbol
  # loading. If you're using Gl commands from multiple threads with multiple
  # contexts, you should call this before using any Gl commands.
  def load_all_gl_commands!()
    GlSym::GL_COMMAND_TYPES.each_key { |fnsym| GlSym.__load_gl_sym__(fnsym) }
    self
  end

  extend self

end
