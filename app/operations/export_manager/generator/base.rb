class ExportManager::Generator::Base < BaseOperation
  cattr_accessor :formats
  attr_accessor :master, :options, :config

  def self.register_format(*format)
    unless format.is_a?(Array)
      format = [format]
    end
    if self.formats.nil?
      self.formats = []
    end
    self.formats += format
  end

  def self.accept?(format, options={})
    return false if self.formats.blank?
    self.formats.include?(format.to_sym)
  end

  def initialize(user, params, master, options)
    super(user, params)
    self.master = master
    self.options = options
    self.config = ExportManager::Config::ExportConfigHandler.config_for(self.user, self.master)
  end

  def run

  end

end