#  This file is part of the opengl-core project.
#  <https://github.com/nilium/ruby-opengl>
#
#  -----------------------------------------------------------------------------
#
#  gl_sym.rb
#    GL symbol loader front-end.


module GL

# @api private
#
# Symbol loading is currently handled by Fiddle, though it's entirely possible
# for someone to swap out loaders they want.
#
# Loaders must provide two methods:
#   - load_sym(name, types)
#     name is the name of the GL symbol to load, types is a dictionary
#     of keys return_type and parameter_types, the former being a symbol
#     defining the return type of the function and parameter_types being an
#     array of the parameter types received by the function.
#
#   - unload()
#     Called to unload any resources held by the loader in the event that the
#     loader is swapped out at runtime.
#
module GLSym

  # Filled by gl_commands.rb
  GL_COMMAND_TYPES = {}

  class << self

    attr_accessor :loader
    attr_accessor :__cached_functions__

    alias_method :__loader__=, :loader=
    def loader=(new_loader)
      return if self.loader == new_loader
      self.loader.unload if self.loader
      self.__cached_functions__.clear if self.__cached_functions__
      self.__loader__ = new_loader
    end

    # Loads the GL symbol with the given name. It's assumed that this symbol
    # has its types defined in GL_COMMAND_TYPES.
    def load_sym(name)
      functions = (self.__cached_functions__ ||= {})
      functions[name] ||= begin
        symfunc = self.loader.load_sym(name, GL_COMMAND_TYPES[name])

        if symfunc.nil?
          raise NoMethodError, "GL function #{name} could not be loaded"
        end

        symfunc
      end
    end

  end # singleton_class

end # GLSym

end # GL


begin
  require 'opengl-core/gl-sym/fiddle-symbol-loader'

  GL::GLSym.loader = GL::GLSym::FiddleSymbolLoader.new
rescue LoadError
  warn "FiddleSymbolLoader could not be loaded - GLSym has no default loader"
end
