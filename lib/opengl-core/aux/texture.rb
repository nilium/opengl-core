require 'opengl-core/aux/gl'
require 'opengl-core/aux/marked'

class Gl::Texture < Gl::GlInternalMarked

  attr_reader :name
  attr_reader :target

  def initialize(target, name = nil)
    super()
    @name = name || 0
    @target = target
    __mark__ if @name != 0
  end

  def delete
    if @name != 0
      Gl.glDeleteTextures(@name)
      @name = 0
      super
    end
    self
  end

  def bind(target = nil)
    if @name == 0
      @name = Gl.glGenTextures(1)[0]
      __mark__
    end

    Gl.glBindTexture(target || @target, @name)
    self
  end

  def unbind(target = nil)
    self.class.unbind(target || @target)
    self
  end

  def self.unbind(target)
    Gl.glBindTexture(target, 0)
    self
  end

end
