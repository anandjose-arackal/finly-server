class ExportManager::Master::BaseSubscriber
  include EventBus::Subscriber
  include Supporters::ErrorTracker
  include DynamicProperty
  include DynamicAttributes
  include MathUtil

  attr_accessor :user, :params, :input, :messages

  class_attr :generator
  class_attr :processor
  class_attr :validations, default: []

  bus ExportManager::Master::BaseMaster

  def initialize(user, params)
    self.user = user
    self.params = params
  end

  def self.validate(method)
    validations << method
  end

  def self.fields(list)

  end

  # def self.generator(klass = NoObject, &block)
  #   generator_klass({klass: klass, block: block}) unless klass == NoObject
  #   generator_klass
  # end
  #
  # def self.processor(klass = NoObject, &block)
  #   processor_klass({klass: klass, block: block}) unless klass == NoObject
  #   processor_klass
  # end

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