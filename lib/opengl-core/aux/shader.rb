require 'opengl-core/aux/gl'
require 'opengl-core/aux/marked'

class Gl::Shader < Gl::GlInternalMarked

  attr_reader :name
  attr_reader :kind

  def initialize(kind, name = nil)
    super()
    @name = (name != 0 && name) || Gl.glCreateShader(kind)
    @kind = kind
    __mark__
  end

  def delete
    if @name != 0
      Gl.glDeleteShader(@name)
      @name = 0
      super
    end
    self
  end

  def source=(sources)
    Gl.glShaderSource(@name, sources)
    sources
  end

  def source
    Gl.glGetShaderSource(@name)
  end

  def compile
    Gl.glCompileShader(@name)
    @compile_status = nil
    compiled?
  end

  def compiled?
    @compile_status = (!@compile_status.nil? && @compile_status) ||
      Gl.glGetShader(@name, Gl::GL_COMPILE_STATUS) == GL_TRUE
  end

  def info_log
    Gl.glGetShaderInfoLog(@name)
  end

end
