class ExportManager::Master::BaseMaster
  include MathUtil
  cattr_accessor :data_map

  attr_accessor :user, :params, :input, :messages

  MASTERS ||= {
      test: '::ExportManager::Master::Test::Provider',
      procurement: '::ExportManager::Master::Procurements::Provider',
      budget_summary: '::ExportManager::Master::Budgets::UsageSummary',
      budget_entities: '::ExportManager::Master::Budgets::UsageEntities',
      vendor_details: '::ExportManager::Master::Vendors::DetailsIndex',
      purchase_order_items: '::ExportManager::Master::PurchaseOrders::PurchaseOrderItems::Index',
      non_po_items: '::ExportManager::Master::Invoices::InvoiceLineItems::Index'
  }.with_indifferent_access

  DEFAULT_CONFIG ||= {spreadsheet: true, pdf: true}


  def self.key
    self.set_data_map[:key]
  end

  def self.fields
    self.set_data_map[:fields]
  end

  def self.generators
    self.set_data_map[:generators]
  end

  def self.processor
    self.set_data_map[:processor]
  end

  def self.config
    self.set_data_map[:config]
  end

  def self.validations
    self.set_data_map[:validations]
  end

  def self.set_data_map
    if self.data_map.nil?
      self.data_map = {}
    end
    if self.data_map[self.name].nil?
      self.data_map[self.name] = {}
    end
    self.data_map[self.name]
  end

  def self.register_handle(key)
    set_data_map[:key] = key
    MASTERS[key] = self
  end

  def self.register_fields(fields)
    set_data_map[:fields] = fields
  end

  def self.register_generator(generator, options = {})
    if set_data_map[:generators].nil?
      set_data_map[:generators] = []
    end
    set_data_map[:generators] << {generator: generator, options: options}
  end

  def self.register_processor(p)
    set_data_map[:processor] = p
  end

  def self.register_config(c)
    set_data_map[:config] = c
  end

  def self.validate(method)
    if set_data_map[:validations].nil?
      set_data_map[:validations] = []
    end
    set_data_map[:validations] << method
  end

  def initialize(user, params)
    self.user = user
    self.params = params
  end

  def valid?
    clear_messages
    self.class.validations&.each do |method|
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