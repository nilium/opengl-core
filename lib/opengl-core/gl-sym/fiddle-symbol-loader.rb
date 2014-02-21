#  This file is part of the opengl-core project.
#  <https://github.com/nilium/ruby-opengl>
#
#  -----------------------------------------------------------------------------
#
#  fiddle-symbol-loader.rb
#    Fiddle-based GL symbol loader.


require 'fiddle'
require 'rbconfig'


module GL

module GLSym

class FiddleSymbolLoader

  TYPE_MAPPINGS = {
    :'void'              => Fiddle::TYPE_VOID,
    :'GLvoid'            => Fiddle::TYPE_VOID,
    :'GLenum'            => Fiddle::TYPE_INT,
    :'GLboolean'         => Fiddle::TYPE_CHAR,
    :'GLbitfield'        => Fiddle::TYPE_INT,
    :'GLbyte'            => Fiddle::TYPE_CHAR,
    :'GLshort'           => Fiddle::TYPE_SHORT,
    :'GLint'             => Fiddle::TYPE_INT,
    :'GLclampx'          => Fiddle::TYPE_INT,
    :'GLubyte'           => Fiddle::TYPE_CHAR,
    :'GLushort'          => Fiddle::TYPE_SHORT,
    :'GLuint'            => Fiddle::TYPE_INT,
    :'GLsizei'           => Fiddle::TYPE_INT,
    :'GLfloat'           => Fiddle::TYPE_FLOAT,
    :'GLclampf'          => Fiddle::TYPE_FLOAT,
    :'GLdouble'          => Fiddle::TYPE_DOUBLE,
    :'GLclampd'          => Fiddle::TYPE_DOUBLE,
    :'GLchar'            => Fiddle::TYPE_CHAR,
    :'GLcharARB'         => Fiddle::TYPE_CHAR,
    :'GLhandleARB'       => Fiddle::TYPE_UINTPTR_T,
    :'GLhalfARB'         => Fiddle::TYPE_SHORT,
    :'GLhalf'            => Fiddle::TYPE_SHORT,
    :'GLfixed'           => Fiddle::TYPE_INT,
    :'GLintptr'          => Fiddle::TYPE_PTRDIFF_T,
    :'GLsizeiptr'        => Fiddle::TYPE_PTRDIFF_T,
    :'GLint64'           => Fiddle::TYPE_LONG_LONG,
    :'GLuint64'          => Fiddle::TYPE_LONG_LONG,
    :'GLintptrARB'       => Fiddle::TYPE_PTRDIFF_T,
    :'GLsizeiptrARB'     => Fiddle::TYPE_PTRDIFF_T,
    :'GLint64EXT'        => Fiddle::TYPE_LONG_LONG,
    :'GLuint64EXT'       => Fiddle::TYPE_LONG_LONG,
    :'GLsync'            => Fiddle::TYPE_VOIDP,
    :'GLhalfNV'          => Fiddle::TYPE_SHORT,
    :'GLvdpauSurfaceNV'  => Fiddle::TYPE_PTRDIFF_T,
    :'GLDEBUGPROC'       => Fiddle::TYPE_VOIDP,
    :'GLDEBUGPROCARB'    => Fiddle::TYPE_VOIDP,
    :'GLDEBUGPROCKHR'    => Fiddle::TYPE_VOIDP,
    :'GLDEBUGPROCAMD'    => Fiddle::TYPE_VOIDP,
  }

  TYPE_MAPPINGS.default_proc = -> (hash, key) do
    if key.to_s.end_with?('*')
      hash[key] = Fiddle::TYPE_VOIDP
    else
      raise ArgumentError, "No type mapping defined for #{key}"
    end
  end

  def fiddle_typed(types)
    case types
    when Array then types.map { |i| fiddle_typed(i) }
    else TYPE_MAPPINGS[types.to_sym]
    end
  end

  def initialize
    @opengl_lib = nil
    @loaded = {}
  end

  def unload
    if @opengl_lib
      @opengl_lib.close
      @opengl_lib = nil
    end

    @loaded.clear
  end

  # Loads a symbol from the GL library. If the GL library hasn't yet been loaded
  # it will also do that. The returned function will be a wrapped Fiddle
  # function using the types that function name is associated with in
  # GL_COMMAND_TYPES. The returned value is cached in GL_COMMAND_FUNCTIONS and
  # returned if load_sym is called for the same name again.
  def load_sym(name, types)
    if @opengl_lib.nil?
      # Platform detection based on code by Thomas Enebo, written for this
      # Stack Overflow answer: http://stackoverflow.com/a/13586108/457812. As
      # such, this particular bit of code is also available under the same
      # terms as content on Stack Overflow unless there's some licensing issue
      # I'm unaware of, in which case I assume it'll eventually be brought to
      # my attention so I can fix things up.
      host = RbConfig::CONFIG['host_os']
      lib_path =
        case host
        when %r[ mac\sos | darwin ]ix
          '/System/Library/Frameworks/OpenGL.framework/OpenGL'
        when %r[ mswin | msys | mingw | cygwin | bcwin | wince | emc ]ix
          'opengl32.dll'
        when %r[ linux | solaris | bsd]ix
          'libGL.so.1'
        else
          raise 'Unrecognized platform'
        end

      @opengl_lib = Fiddle.dlopen(lib_path)
    end

    begin
      sym = @opengl_lib[name.to_s]

      Fiddle::Function.new(
        sym,
        fiddle_typed(types[:parameter_types]),
        fiddle_typed(types[:return_type])
        )
    rescue Fiddle::DLError
      nil
    end if @opengl_lib
  end

end # FiddleSymbolLoader

end # GLSym

end # GL
