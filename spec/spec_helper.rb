$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'quiescent'
require 'erb'
require 'digest/md5'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

SClass = Struct.new(:name, :decls)
SQConst = Struct.new(:name, :default, :block)
SDo = Struct.new(:body)

class SDo
  def to_s
    "do ; #{body} ; end"
  end
end

class SQConst
  def to_s
    "quiescent #{name.to_sym.inspect}#{(", " + default) if default} #{block if block}"
  end
end

class SClass
  TEMPLATE = ERB.new <<-END
  class <%= name %>
<% decls.each do |decl| %>    <%= decl.to_s %>
<% end %>
  end
END
  def to_s
   TEMPLATE.result(binding)
  end
end

def Klass(name, *decls)
  SClass.new(name, decls)
end

def QConst(name, *values)
  default, block = nil

  if values.size == 1
    if values[0].is_a?(SDo)
      block = values[0]
    else
      default = values[0]
    end
  elsif values.size == 2
    default, block = values
  end
  
  SQConst.new(name, default, block)
end

def Do(body)
  SDo.new(body)
end

def gen_id(base)
  "#{base}_#{Digest::MD5.hexdigest(Time.now.iso8601(11))}"
end

RSpec.configure do |config|
  
end
