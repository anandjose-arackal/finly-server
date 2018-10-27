class ExportManager::Master::BaseMaster
  cattr_accessor :key, :fields, :generators, :processor, :config, :validations

  attr_accessor :user, :params, :input, :messages

  MASTERS = {
      test: '::ExportManager::Master::Test::Provider',
      procurement: '::ExportManager::Master::Procurements::Provider',
      budget_summary: '::ExportManager::Master::Budgets::UsageSummary',
      budget_entities: '::ExportManager::Manager::Budgets::UsageEntities'
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
    clear_messages
    self.validations&.each do |method|
      self.send method
    end
    self.messages[:error].blank?
  end

  # Input is the what is used for generating the
  def input
    # To be written by every adapter
  end

  def clear_messages
    self.messages = {error: [], failure: [], success: [], message: [], notice: []}
  end

  def add_message(type, message)
    return if type.blank? or message.blank? or (type != :error and type != :failure and type != :success and type != :message and type != :notice)
    clear_messages if self.messages.blank?
    if message.is_a?(Array)
      messages[type].concat message
    elsif message.is_a?(String)
      messages[type] << message
    end
  end

end