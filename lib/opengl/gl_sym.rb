require 'fiddle'
require 'opengl/opengl_stub'

module GlSym

  @@opengl_lib = nil

  def self.load_gl_sym__(name)
    if @@opengl_lib.nil?
      lib_path = case
      when apple?
        '/System/Library/Frameworks/OpenGL.framework/OpenGL'
      when unix? || linux?
        'libGL.so.1'
      when windows?
        'opengl32.dll'
      else
        raise 'Unrecognized platform'
      end
      @@opengl_lib = Fiddle.dlopen(lib_path)
    end

    @@opengl_lib[name]
  end

end # module GlSym