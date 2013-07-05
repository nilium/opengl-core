require 'opengl-core/aux/gl'
require 'opengl-core/aux/marked'

class Gl::VertexArray < Gl::GlInternalMarked

  attr_reader :name

  def initialize(name = nil)
    super()
    @name = name || 0
    __mark__ if @name != 0
  end

  def delete
    if @name != 0
      Gl.glDeleteVertexArrays(@name)
      @name = 0
      super
    end
    self
  end

  def bind
    if @name == 0
      @name = Gl.glGenVertexArrays(1)[0]
      __mark__
    end

    Gl.glBindVertexArray(@name)
    self
  end

  def unbind
    self.class.unbind
    self
  end

  def self.unbind
    Gl.glBindVertexArray(0)
    self
  end

end
