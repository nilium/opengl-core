#!/usr/bin/env ruby -w

require 'nokogiri'
require 'open-uri'
require 'fiddle'

KHRONOS_GL_XML = 'https://cvs.khronos.org/svn/repos/ogl/trunk/doc/registry/public/api/gl.xml'

if !File.exist?('gl.xml')
  puts "gl.xml doesn't exist: downloading <#{KHRONOS_GL_XML}>..."
  curl_pid = Process.spawn("curl --output 'gl.xml' '#{KHRONOS_GL_XML}'")
  Process.wait(curl_pid)
  if !$?.exited? || !$?.success?
    puts "Download failed. Try again."
    exit 1
  end
  puts "Download complete."
end

# name => String
# value => String
# alias => nil | String
GLEnum = Struct.new(:name, :value, :alias)

# name => String
# type => String
# core => String (substring of type or nil)
GLParam = Struct.new(:name, :type, :core)

# name       => String
# type       => GLParam (name -> nil)
# parameters => [GLParam]
GLCommand = Struct.new(:name, :type, :parameters)

# command_suffix => String
# enum_suffix    => String
GLVendor = Struct.new(:command_suffix, :enum_suffix)

# Set to false to generate bindings for non-core profile functions/enums
GEN_GL3_AND_UP = true

TYPE_MAPPINGS = {
  "void"              => 'Fiddle::TYPE_VOID',
  'GLvoid'            => 'Fiddle::TYPE_VOID',
  'GLenum'            => 'Fiddle::TYPE_INT',
  'GLboolean'         => 'Fiddle::TYPE_CHAR',
  'GLbitfield'        => 'Fiddle::TYPE_INT',
  'GLbyte'            => 'Fiddle::TYPE_CHAR',
  'GLshort'           => 'Fiddle::TYPE_SHORT',
  'GLint'             => 'Fiddle::TYPE_INT',
  'GLclampx'          => 'Fiddle::TYPE_INT',
  'GLubyte'           => 'Fiddle::TYPE_CHAR',
  'GLushort'          => 'Fiddle::TYPE_SHORT',
  'GLuint'            => 'Fiddle::TYPE_INT',
  'GLsizei'           => 'Fiddle::TYPE_INT',
  'GLfloat'           => 'Fiddle::TYPE_FLOAT',
  'GLclampf'          => 'Fiddle::TYPE_FLOAT',
  'GLdouble'          => 'Fiddle::TYPE_DOUBLE',
  'GLclampd'          => 'Fiddle::TYPE_DOUBLE',
  'GLchar'            => 'Fiddle::TYPE_CHAR',
  'GLcharARB'         => 'Fiddle::TYPE_CHAR',
  'GLhandleARB'       => 'Fiddle::TYPE_UINTPTR_T',
  'GLhalfARB'         => 'Fiddle::TYPE_SHORT',
  'GLhalf'            => 'Fiddle::TYPE_SHORT',
  'GLfixed'           => 'Fiddle::TYPE_INT',
  'GLintptr'          => 'Fiddle::TYPE_PTRDIFF_T',
  'GLsizeiptr'        => 'Fiddle::TYPE_PTRDIFF_T',
  'GLint64'           => 'Fiddle::TYPE_LONG_LONG',
  'GLuint64'          => 'Fiddle::TYPE_LONG_LONG',
  'GLintptrARB'       => 'Fiddle::TYPE_PTRDIFF_T',
  'GLsizeiptrARB'     => 'Fiddle::TYPE_PTRDIFF_T',
  'GLint64EXT'        => 'Fiddle::TYPE_LONG_LONG',
  'GLuint64EXT'       => 'Fiddle::TYPE_LONG_LONG',
  'GLsync'            => 'Fiddle::TYPE_VOIDP',
  'GLhalfNV'          => 'Fiddle::TYPE_SHORT',
  'GLvdpauSurfaceNV'  => 'Fiddle::TYPE_PTRDIFF_T',
  'GLDEBUGPROC'       => 'Fiddle::TYPE_VOIDP',
  'GLDEBUGPROCARB'    => 'Fiddle::TYPE_VOIDP',
  'GLDEBUGPROCKHR'    => 'Fiddle::TYPE_VOIDP',
  'GLDEBUGPROCAMD'    => 'Fiddle::TYPE_VOIDP'
}

SELECT_ENUMS_XPATH    = 'registry/enums/enum[@name and @value and (not(@api) or not(starts-with(@api, "gles")))]'
SELECT_COMMANDS_XPATH = 'registry/commands/command'
SELECT_TYPEDEFS_XPATH = 'registry/types/type[(not(@api) or not(starts-with(@api, "gles"))) and (not(@name) or not(starts-with(@name, "khr")))]'
SELECT_TYPE_XPATH     = 'ptype/text()|text()'

def fiddle_type(param)
  if param.type.end_with? '*'
    'Fiddle::TYPE_VOIDP'
  elsif TYPE_MAPPINGS.include?(param.core)
    TYPE_MAPPINGS[param.core]
  else
    raise "Unrecognized type: #{param.core}"
  end
end

def get_type(from)
  from.inner_text.chomp(from.at('name').text)
end

def get_enums(document)
  enums = {}
  document.xpath(SELECT_ENUMS_XPATH).each {
    |gl_enum|

    enum_name = gl_enum['name']
    enum_value = gl_enum['value']
    enum_alias = gl_enum['alias']

    enums[enum_name] = GLEnum.new(enum_name, enum_value, enum_alias)
  }
  enums
end

def get_commands(document)
  commands = {}
  document.xpath(SELECT_COMMANDS_XPATH).each {
    |gl_command|

    proto = gl_command.at('proto')
    name = proto.at('name').text
    params = []
    gl_command.xpath('param').each {
      |gl_param|
      ptype = gl_param.at('ptype')
      full_type = get_type(gl_param)
      params << GLParam.new(gl_param.at('name').text, full_type, ptype ? ptype.text : full_type.strip)
    }

    ptype = proto.at('ptype')
    full_return_type = get_type(proto)
    return_type = GLParam.new(nil, full_return_type, ptype ? ptype.text : full_return_type.strip)

    commands[name] = GLCommand.new(name, return_type, params)
  }
  commands
end

def generate_binding_impl(document)
  filtered_commands = {}
  filtered_enums = {}

  begin
    gl_commands = get_commands(document)
    gl_enums = get_enums(document)

    pull_feature = proc { |feature|
      feature_name = feature['name']
      feature_kind = feature.name

      case feature_kind
      when 'enum' then filtered_enums[feature_name] = gl_enums[feature_name]
      when 'command' then filtered_commands[feature_name] = gl_commands[feature_name]
      else raise "Unrecognized feature kind"
      end
    }

    drop_feature = proc { |feature|
      feature_name = feature['name']
      feature_kind = feature.name

      case feature_kind
      when 'enum' then filtered_enums.delete(feature_name)
      when 'command' then filtered_commands.delete(feature_name)
      else raise "Unrecognized feature kind"
      end
    }

    extensions = document.xpath("registry/extensions/extension")
    core_exts = extensions.select { |ext| ext['supported'] =~ /\bglcore\b/ }
    core_exts.each { |ext|
      ext.xpath('extension/require/*[(self::command|self::enum)]').each(&pull_feature)
    }

    features = document.xpath('registry/feature')
    gl_features = features.select { |feature| feature['api'] =~ /\bgl\b/ }
    gl_features.each { |feature|
      feature.xpath('require/*[(self::command|self::enum)]').each(&pull_feature)
      if GEN_GL3_AND_UP
        feature.xpath('remove[@profile="core"]/*[(self::command|self::enum)]').each(&drop_feature)
      end
    }
  end

  enum_name_length  = filtered_enums.map { |k, enum| enum.name.length }.max
  prefix            = document.url.chomp(File.extname(document.url))

  File.open("lib/opengl-core/#{prefix}_enums.rb", 'w') {
    |io|

    io.puts <<-EOS
module Gl
EOS

    filtered_enums.select { |name, enum| enum.alias.nil? }.each {
      |name, enum|
      io.puts "  # @api raw\n  #{name.ljust(enum_name_length)} = #{enum.value}"
    }

    filtered_enums.select { |name, enum| !enum.alias.nil? }.each {
      |name, enum|
      if !filtered_enums[enum.alias]
        prefixed_alias = "GL_#{enum.alias}"
        if filtered_enums[prefixed_alias]
          enum.alias = prefixed_alias
        else
          next if enum.value.nil?
          enum.alias = enum.value
        end
      end


      io.puts "  # @api raw\n  #{name.ljust(enum_name_length)} = #{enum.alias}"
    }

    io.puts 'end # module Gl'
  }

  File.open("lib/opengl-core/#{prefix}_commands.rb", 'w') {
    |io|

    io.puts <<-EOS
require 'fiddle'
require 'opengl-core/gl_sym'

module Gl

#{
  filtered_commands.map {
    |name, cmd|
    # Put a _ on the end of each argument to avoid conflicts with reserved words
    param_string = cmd.parameters.map { |p| "#{p.name}_" }.join(', ')

    <<-EOS_INNER
  GlSym::GL_COMMAND_TYPES[:#{name}] = {
    :parameter_types => [#{cmd.parameters.map { |p| fiddle_type(p) }.join(', ') }],
    :return_type     => #{ fiddle_type(cmd.type) }
  }

  # @api raw
  def #{name}__(#{param_string})
    unless (fn = GlSym.__load_gl_sym__(:#{name}))
      raise NotImplementedError, "GL function #{name} is not available."
    end
    fn.call(#{param_string})
  end

  alias_method :'#{name}', :'#{name}__'

    EOS_INNER
  }.join('')
}
end # module Gl
EOS
  }
end



# Read gl.xml

document_paths = [ 'gl.xml' ]

document_paths.each {
  |path|
  document = Nokogiri.XML(File.open(path, 'r'), path)
  generate_binding_impl(document)
}
