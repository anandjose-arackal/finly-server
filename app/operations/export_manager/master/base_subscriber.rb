class ExportManager::Master::BaseSubscriber
  include EventBus::Subscriber
  include Supporters::ErrorTracker
  include DynamicProperty

  attr_accessor :user, :params, :input, :messages

  define_property :fields, :processor
  define_property_array :validate, :generators

  def initialize(user, params)
    self.user = user
    self.params = params
  end

  def self.validations
    validate
  end

  def valid?
    clear_messages
    self.class.validations&.each do |method|
      self.send method
    end
    self.messages[:error].blank?
  end

  # As every exportor subscribes to a single event, we can use handle to retrieve the subscribed event
  def self.handle
    subscriptions&.first
  end

  # Input is the what is used for generating the
  def input
    # To be written by every adapter
    raise "Input has not been defined for #{self.class.name}"
  end

end