class AccountingExports::Master::BaseSubscriber
  include EventBus::Subscriber


  attr_accessor :user, :params, :input, :messages

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


end