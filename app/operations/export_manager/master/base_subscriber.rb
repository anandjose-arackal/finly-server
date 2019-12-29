class ExportManager::Master::BaseSubscriber
  include EventBus::Subscriber
  include Supporters::ErrorTracker
  include DynamicProperty
  include DynamicAttributes
  include MathUtil

  attr_accessor :user, :params, :input, :messages

  class_attr :label
  class_attr :job_name
  class_attr :generator_klass
  class_attr :processor
  class_attr :screen
  class_attr :validations, default: []

  bus ExportManager::Master::BaseMaster
  job_name :job_name

  def job_name(user, params, input)
    self.class.label
  end

  def self.config(options = {})
    # raise "Label is not defined for #{self.name}" if label.blank?
    # raise "#{self.name} has not subscribed to any event" if event.blank?

    {
        label: label,
        type: type,
        key: event,
        screen: screen,
        config: generator_config
    }
  end

  def self.type
    generator&.type
  end

  def self.generator_config
    generator.config(self)
  end

  def self.validate(method)
    validations << method
  end

  def self.generator(klass = NoObject)
    unless klass == NoObject
      generator_klass(klass)
      ExportManager::Generator::Spreadsheet.setup(self)
    end
    generator_klass
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