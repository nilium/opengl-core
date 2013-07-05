require 'opengl-core'

module Gl

  # @api private
  UINT_BASE   = { :packed => [0].pack('I!').freeze,   :unpack => 'I!*' }
  UINT16_BASE = { :packed => [0].pack('S').freeze,    :unpack => 'S*' }
  UINT32_BASE = { :packed => [0].pack('L').freeze,    :unpack => 'L*' }
  UINT64_BASE = { :packed => [0].pack('Q').freeze,    :unpack => 'Q*' }
  INT_BASE    = { :packed => [0].pack('i!').freeze,   :unpack => 'i!*' }
  INT16_BASE  = { :packed => [0].pack('s').freeze,    :unpack => 's*' }
  INT32_BASE  = { :packed => [0].pack('l').freeze,    :unpack => 'l*' }
  INT64_BASE  = { :packed => [0].pack('q').freeze,    :unpack => 'q*' }
  USHORT_BASE = { :packed => [0].pack('S!').freeze,   :unpack => 'S!*' }
  SHORT_BASE  = { :packed => [0].pack('s!').freeze,   :unpack => 's!*' }
  FLOAT_BASE  = { :packed => [0.0].pack('F').freeze,  :unpack => 'F*' }
  DOUBLE_BASE = { :packed => [0.0].pack('D').freeze,  :unpack => 'D*' }
  POINTER_BASE = case Fiddle::SIZEOF_VOIDP
  when 2 then   { :packed => [0.0].pack('S').freeze,  :unpack => 'S*' }
  when 4 then   { :packed => [0.0].pack('L').freeze,  :unpack => 'L*' }
  when 8 then   { :packed => [0.0].pack('Q').freeze,  :unpack => 'Q*' }
  else raise "Pointer size is incompatible with opengl-core"
  end

  # @api private
  def self.__define_gl_gen_object_method__(name, type_base)
    pack_string = type_base[:packed]
    unpack_kind = type_base[:unpack]

    self.module_exec(name, :"#{name}__", pack_string, unpack_kind) {
      |func_name, raw_name, buffer_elem, pack_as|
      define_method(func_name) {
        |count|
        output_buffer = buffer_elem * count
        send(raw_name, count, output_buffer)
        output_buffer.unpack(pack_as)
      }
    }
  end

  # @api private
  def self.__define_gl_delete_object_method__(name, type_base)
    unpack_kind = type_base[:unpack]

    self.module_exec(name, :"#{name}__", unpack_kind) {
      |func_name, raw_name, pack_as|
      define_method(func_name) {
        |objects|
        objects = [objects] unless objects.kind_of?(Array)
        input_buffer = objects.pack(pack_as)
        send(raw_name, objects.length, input_buffer)
      }
    }
  end

  # @api private
  def self.__define_gl_get_method__(name, type_base)
    pack_string = type_base[:packed]
    unpack_kind = type_base[:unpack]

    self.module_exec(name, :"#{name}v__", pack_string, unpack_kind) {
      |func_name, raw_name, buffer_elem, pack_as|
      define_method(func_name) {
        |pname|
        output_buffer = String.new(buffer_elem)
        send(raw_name, pname, output_buffer)
        output_buffer.unpack(pack_as)[0]
      }
    }
  end


  # @!method self.glGenTextures(count)
  #   Returns an array of generated texture names.
  __define_gl_gen_object_method__ :glGenTextures, UINT_BASE
  # @!method self.glDeleteTextures(count, objects)
  __define_gl_delete_object_method__ :glDeleteTextures, UINT_BASE

  # @!method self.glGenVertexArrays(count)
  #   Returns an array of generated vertex array object names.
  __define_gl_gen_object_method__ :glGenVertexArrays, UINT_BASE
  # @!method self.glDeleteVertexArrays(count, objects)
  __define_gl_delete_object_method__ :glDeleteVertexArrays, UINT_BASE

  # @!method self.glGenBuffers(count)
  #   Returns an array of generated buffer object names.
  __define_gl_gen_object_method__ :glGenBuffers, UINT_BASE
  # @!method self.glDeleteBuffers(count, objects)
  __define_gl_delete_object_method__ :glDeleteBuffers, UINT_BASE

  # @!method self.glGenQueries(count)
  #   Returns an array of generated query object names.
  __define_gl_gen_object_method__ :glGenQueries, UINT_BASE
  # @!method self.glDeleteQueries(count, objects)
  __define_gl_delete_object_method__ :glDeleteQueries, UINT_BASE

  # @!method self.glGenSamplers(count)
  #   Returns an array of generated sampler object names.
  __define_gl_gen_object_method__ :glGenSamplers, UINT_BASE
  # @!method self.glDeleteSamplers(count, objects)
  __define_gl_delete_object_method__ :glDeleteSamplers, UINT_BASE

  # @!method self.glGenFramebuffers(count)
  #   Returns an array of generated framebuffer object names.
  __define_gl_gen_object_method__ :glGenFramebuffers, UINT_BASE
  # @!method self.glDeleteFramebuffers(count, objects)
  __define_gl_delete_object_method__ :glDeleteFramebuffers, UINT_BASE

  # @!method self.glGenRenderbuffers(count)
  #   Returns an array of generated renderbuffer object names.
  __define_gl_gen_object_method__ :glGenRenderbuffers, UINT_BASE
  # @!method self.glDeleteRenderbuffers(count, objects)
  __define_gl_delete_object_method__ :glDeleteRenderbuffers, UINT_BASE

  # @!method self.glGenRenderbuffersProgramPipelines(count)
  #   Returns an array of generated program pipeline object names.
  __define_gl_gen_object_method__ :glGenProgramPipelines, UINT_BASE
  # @!method self.glDeleteRenderbuffersProgramPipelines(count, objects)
  __define_gl_delete_object_method__ :glDeleteProgramPipelines, UINT_BASE

  # @!method self.glGenRenderbuffersTrasnformFeedbacks(count)
  #   Returns an array of generated transform feedback objects
  __define_gl_gen_object_method__ :glGenTransformFeedbacks, UINT_BASE
  # @!method self.glDeleteRenderbuffersTrasnformFeedbacks(count, objects)
  __define_gl_delete_object_method__ :glDeleteTransformFeedbacks, UINT_BASE

  __define_gl_get_method__ :glGetInteger, UINT_BASE
  __define_gl_get_method__ :glGetInteger64, INT64_BASE
  __define_gl_get_method__ :glGetFloat, FLOAT_BASE
  __define_gl_get_method__ :glGetDouble, DOUBLE_BASE

  # @return [Boolean] Returns the boolean value of the given parameter name.
  def glGetBoolean(pname)
    buffer = '0'
    glGetBooleanv(pname, buffer)
    !!buffer.unpack('C')[0]
  end

  # @return [String] Returns the string value of the given parameter name.
  def glGetString(name)
    glGetString__(name).to_s
  end

  # @return [String] Returns the string value of a parameter name at a given index.
  def glGetStringi(name, index)
    glGetStringi__(name, index).to_s
  end

  def glVertexAttribPointer(index, size, type, normalized, stride, offset)
    offset = case offset
    when Fiddle::Pointer then offset
    when Numeric then Fiddle::Pointer.new(offset)
    else offset
    end
    glVertexAttribPointer__ index, size, type, normalized, stride, offset
  end

  def glShaderSource(shader, sources)
    sources = [sources] unless sources.kind_of?(Array)
    source_lengths = sources.map { |s| s.bytesize }.pack('i*')
    source_pointers = sources.pack('p')
    glShaderSource__(shader, sources.length, source_pointers, source_lengths)
  end

  # Returns the version or release number. Calls glGetString.
  def gl_version()
    glGetString(GL_VERSION)
  end

  # Returns the implementation vendor. Calls glGetString.
  def gl_vendor()
    glGetString(GL_VENDOR)
  end

  # Returns the renderer. Calls glGetString.
  def gl_renderer()
    glGetString(GL_RENDERER)
  end

  # Returns the shading language version. Calls glGetString.
  def gl_shading_language_version()
    glGetString(GL_SHADING_LANGUAGE_VERSION)
  end

  # Gets an array of GL extensions. This calls glGetIntegerv and glGetStringi,
  # so be aware that you should probably cache the results.
  def gl_extensions()
    (0 ... glGetInteger(GL_NUM_EXTENSIONS)).map { |index| glGetStringi(GL_EXTENSIONS, index) }
  end

  def glGetShader(shader, pname)
    base = String.new(INT_BASE[:packed])
    glGetShaderiv__(shader, pname, base)
    base.unpack(INT_BASE[:unpack])[0]
  end

  def glGetShaderInfoLog(shader)
    length = glGetShader(shader, GL_INFO_LOG_LENGTH)
    return '' if length == 0
    output = ' ' * length
    glGetShaderInfoLog__(shader, output.bytesize, 0, output)
    output
  end

  def glGetShaderSource(shader)
    length = glGetShader(shader, GL_SHADER_SOURCE_LENGTH)
    return '' if length == 0
    output = ' ' * length
    glGetShaderInfoLog__(shader, output.bytesize, 0, output)
    output
  end

  def glGetProgram(program, pname)
    base = String.new(INT_BASE[:packed])
    glGetProgramiv__(program, pname, base)
    base.unpack(INT_BASE[:unpack])[0]
  end

  def glGetProgramInfoLog(program)
    length = glGetProgram(program, GL_INFO_LOG_LENGTH)
    return '' if length == 0
    output = ' ' * length
    glGetProgramInfoLog__(program, output.bytesize, 0, output)
    output
  end

  def glGetProgramBinary(program)
    binary_length = glGetProgram(program, GL_PROGRAM_BINARY_LENGTH)
    return [nil, nil] if binary_length == 0
    format_buffer = String.new(UINT_BASE[:packed])
    binary_buffer = ' ' * binary_length
    glGetProgramBinary(program, binary_buffer.bytesize, 0, format_buffer, binary_buffer)
    [format_buffer.unpack(UINT_BASE[:unpack])[0], binary_buffer]
  end

  extend self

end
