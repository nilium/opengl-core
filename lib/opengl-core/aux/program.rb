require 'opengl-core/aux/gl'
require 'opengl-core/aux/marked'

# Needed even if the class isn't actually used
class Gl::Shader ; end

class Gl::Program < Gl::GlInternalMarked

  attr_reader :name

  def initialize(name = nil)
    super()
    @name = (name != 0 && name) || Gl.glCreateProgram()

    @validate_status   = nil
    @link_status       = nil
    @uniform_locations = {}
    __mark__
  end

  def load_binary(binary_format, binary_string)
    Gl.glProgramBinary(@name, binary_format, binary_string, binary_string.bytesize)
    @link_status = nil
    __reload_uniforms__  if (link_successful = linked?)
    link_successful
  end

  def binary
    Gl.glGetProgramBinary(@name)
  end

  def delete
    if @name != 0
      Gl.glDeleteProgram(@name)
      @name = 0
      super
    end
    self
  end

  def __reload_uniforms__
    @uniform_locations.keys.each {
      |key|
      @uniform_locations[key] = Gl.glGetUniformLocation(@name, key.to_s)
    }
  end

  def link
    Gl.glLinkProgram(@name)
    @link_status = nil
    __reload_uniforms__ if (link_successful = linked?)
    link_successful
  end

  def linked?
    @link_status = (!@link_status.nil? && @link_status) ||
      Gl.glGetProgram(@name, Gl::GL_LINK_STATUS) == GL_TRUE
  end

  def validate
    Gl.glValidateProgram(@name)
    @validate_status = nil
    valid?
  end

  def valid?
    @validate_status = (!@validate_status.nil? && @validate_status) ||
      Gl.glGetProgram(@name, Gl::GL_VALIDATE_STATUS) == GL_TRUE
  end

  def info_log
    Gl.glGetProgramInfoLog(@name)
  end

  def use
    Gl.glUseProgram(@name)
    self
  end

  def attach_shader(shader)
    case shader
    when ::Gl::Shader then Gl.glAttachShader(@name, shader.name)
    else Gl.glAttachShader(@name, shader)
    end
    self
  end

  def hint_uniform(uniform_name)
    uniform_name = uniform_name.to_sym
    @uniform_locations[uniform_name] ||= -1
    self
  end

  # Implicitly hints that a uniform exists.
  def uniform_location(uniform_name)
    uniform_sym = uniform_name.to_sym
    @uniform_locations[uniform_sym] ||=
      Gl.glGetUniformLocation(@name, uniform_name.to_s)
  end
  alias_method :[], :uniform_location

  def each_hinted_uniform(&block)
    return @uniform_locations.each_key unless block_given?
    @uniform_locations.each_key(&block)
    self
  end

  def subroutine_uniform_location(shader_kind, uniform_name)
    Gl.glGetSubroutineUniformLocation(@name, shader_kind, uniform_name)
  end

  def bind_attrib_location(attrib_index, attrib_name)
    Gl.glBindAttribLocation(@name, attrib_index, attrib_name.to_s)
    self
  end

  def bind_frag_data_location(color_number, frag_data_name)
    Gl.glBindFragDataLocation(@name, color_number, frag_data_name.to_s)
    self
  end

end
