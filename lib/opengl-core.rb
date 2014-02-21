#  This file is part of the opengl-core project.
#  <https://github.com/nilium/ruby-opengl>
#
#  -----------------------------------------------------------------------------
#
#  opengl-core.rb
#    Root file for opengl-core -- contains general functions and requires other
#    gem sources.


require 'opengl-core/gl-sym'
require 'opengl-core/gl-enums'
require 'opengl-core/gl-commands'


module GL

  # Checks if a GL command is availalbe to use. This necessarily loads the
  # command if it's not yet loaded just to check if it exists, so do not call
  # this from multiple threads when other Gl commands are being loaded. If you
  # want to ensure this only reads, you can call load_all_gl_commands! ahead of
  # time and query it afterward.
  def have_gl_command?(command)
    begin ; !!GLSym.load_sym(command.intern) ; rescue NoMethodError ; end
  end

  # Does what it says on the tin. Should only be called once, preferably from
  # the main thread, though I'm not aware of any thread requirements re: symbol
  # loading. If you're using Gl commands from multiple threads with multiple
  # contexts, you should call this before using any Gl commands.
  def load_all_gl_commands!()
    GLSym::GL_COMMAND_TYPES.each_key do |fnsym|
      begin ; GLSym.load_sym(fnsym) ; rescue NoMethodError ; end
    end
    self
  end

  extend self

end # GL
