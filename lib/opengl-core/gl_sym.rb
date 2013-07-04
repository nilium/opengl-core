require 'fiddle'
require 'opengl-core/opengl_stub'

module Gl ; end

# @api private
module Gl::GlSym

  # Filled by gl_commands.rb
  GL_COMMAND_TYPES = {}
  # Filled by __load_gl_sym__
  GL_COMMAND_FUNCTIONS = {}

  # OpenGL library handle.
  @@opengl_lib = nil

  # Loads a symbol from the GL library. If the GL library hasn't yet been loaded
  # it will also do that. The returned function will be a wrapped Fiddle
  # function using the types that function name is associated with in
  # GL_COMMAND_TYPES. The returned value is cached in GL_COMMAND_FUNCTIONS and
  # returned if __load_gl_sym__ is called for the same name again.
  def self.__load_gl_sym__(name)
    if @@opengl_lib.nil?
      lib_path = case
      when apple?
        '/System/Library/Frameworks/OpenGL.framework/OpenGL'
      when windows? || Fiddle::WINDOWS
        'opengl32.dll'
      when unix? || linux?
        'libGL.so.1'
      else
        raise 'Unrecognized platform'
      end
      @@opengl_lib = Fiddle.dlopen(lib_path)
    end

    fn = GL_COMMAND_FUNCTIONS[name]
    if fn.nil?
      fn = (GL_COMMAND_FUNCTIONS[name] = begin
        sym = @@opengl_lib[name.to_s]
        types = GL_COMMAND_TYPES[name]
        Fiddle::Function.new(sym, types[:parameter_types], types[:return_type])
      rescue
        false
      end)
    end

    fn
  end

end # module GlSym