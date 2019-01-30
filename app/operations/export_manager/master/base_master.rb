class ExportManager::Master::BaseMaster
  include Observer::Master, Observer::Observable, Supporters::ErrorTracker

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

end