

module GlSym

  @@opengl_lib = nil

  def self.load_gl_sym__(name)
    if @@opengl_lib.nil?
      lib_path = case
      when macos? then nil
      when unix? then nil
      end
      puts lib_path
    end
  end

end # module GlSym