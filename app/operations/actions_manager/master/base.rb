class ActionsManager::Master::Base

  cattr_accessor :data_map
  attr_accessor :user, :params, :input

  MASTERS = {
    payment_request_index: '::ActionsManager::Master::BankTransfer::PaymentRequest::Index',
    payment_request_show: '::ActionsManager::Master::BankTransfer::PaymentRequest::Show',
    account_owners_index: '::ActionsManager::Master::BankTransfer::AccountOwners::Index',
    account_owners_show: '::ActionsManager::Master::BankTransfer::AccountOwners::Show',
    inward_invoices_index: '::ActionsManager::Master::BankTransfer::InwardInvoices::Index',
    inward_invoices_show: '::ActionsManager::Master::BankTransfer::InwardInvoices::Show',
    inventory_line_item_index: '::ActionsManager::Master::Invoicing::InventoryLineItem::Index',
    inventory_line_item_show: '::ActionsManager::Master::Invoicing::InventoryLineItem::Show',
    templates_index: '::ActionsManager::Master::Procurements::PurchaseOrders::Templates::Index',
    purchase_orders_index: '::ActionsManager::Master::Procurements::PurchaseOrders::Index',
    purchase_orders_show: '::ActionsManager::Master::Procurements::PurchaseOrders::Show',
    procurements_index: '::ActionsManager::Master::Procurements::Index',
    procurements_show: '::ActionsManager::Master::Procurements::Show' 

  }.with_indifferent_access


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

  def self.register_actions(fields)
    set_data_map[:actions] = fields
  end

  def initialize(user, params)
    self.user = user
    self.params = params
  end

  def self.fields
    set_data_map[:fields]
  end

  def self.actions
    set_data_map[:actions]
  end

  # Get allowed actions as hash
  def run
    actions = self.class.set_data_map[:actions]
    allowed_actions = allowed_actions(actions)
  end

  def input
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

  def allowed_actions(actions)
    result = {}
    actions.each do |action|
      result[action] = self.send(action) if self.send(action)
    end
    return result
  end

end