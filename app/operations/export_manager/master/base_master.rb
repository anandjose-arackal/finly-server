class ExportManager::Master::BaseMaster
  cattr_accessor :key, :fields, :generators, :processor, :config, :validations

  attr_accessor :user, :params, :input, :errors

  MASTERS = {
      test: 'ExportManager::Master::Test::Provider',
      procurement: 'ExportManager::Master::Procurement::Provider'
  }.with_indifferent_access

  DEFAULT_CONFIG = {spreadsheet: true, pdf: true}

  def self.register_handle(key)
    self.key = key
    MASTERS[key] = self
  end

  def self.register_fields(fields)
    self.fields = fields
  end

  def self.register_generator(generator, options = {})
    if self.generators.nil?
      self.generators = []
    end
    self.generators << {generator: generator, options: options}
  end

  def self.register_processor(p)
    self.processor = p
  end

  def self.register_config(c)
    self.config = c
  end

  def self.validate(method)
    if self.validations.blank?
      self.validations = []
    end
    self.validations << method
  end

  def initialize(user, params)
    self.user = user
    self.params = params
  end

  def valid?
    self.errors = []
    self.validations&.each do |method|
      self.send method
    end
    self.errors.blank?
  end

  # Input is the what is used for generating the
  def input
    # To be written by every adapter
  end

  def add_error(message)
    self.errors = [] if errors.blank?
    return if message.blank?
    unless message.is_a?(Array)

    end
    self.errors << message
  end

end