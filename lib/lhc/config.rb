require 'singleton'

class LHC::Config
  include Singleton

  attr_accessor :config

  def initialize
    self.config = {}
  end

  def self.set(name, endpoint, options = {})
    instance.config[name] = OpenStruct.new({
      endpoint: endpoint,
      options: options
    })
  end

  def self.[](name)
    instance.config[name]
  end
end
