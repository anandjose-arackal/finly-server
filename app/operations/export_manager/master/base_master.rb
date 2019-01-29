class ExportManager::Master::BaseMaster
  include Observer::Master, Observer::Observable

  attr_accessor :user, :params, :input, :messages

  observer_keys :handle, :generators, :processor, :fields
  observers_path "#{Rails.root}/app/operations/export_manager/master"

  def self.validate(method)
    register_multiple :validations, method
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