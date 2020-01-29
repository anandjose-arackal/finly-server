class Notifier::API < Transactions::API
  include DynamicAttributes
  include Events::Consumer

  # def self.event(event_name)
  #   consumes_event! 'report.submit'
  # end

  def on_event(user, payload)
    self.class.(params: params, current_user: user)
  end

  attr_accessor :user, :params, :payload

  class_attr :payload, default: {}
  class_attr :user
  # class_attr :processor
  # class_attr :mail_config, default: {
  #     'Invoice' => {
  #         template: "../template.html.erb",
  #         subject: "You have submitted {{invoice.name}}"
  #     }
  # }.with_indifferent_access


  def process_params(user, params)
    payload = {}
    self.class.payload.each do |key, value|
      if value[:value].present?
        new_payload[key] = value[:value]
      elsif value[:block].present?
        debugger
        new_payload[key] = value[:block].call(user, params)
      end
    end
    new_payload
  end


  def self.set(key, value = nil, &block)
    if value.present?
      payload[key] = {value: value}
    elsif block_given?
      payload[key] = {block: block}
    end
  end

  def self.recipients(values = [], &block)
    if values.present? && values.is_a?(Array)
      instance_variable_set("@recipient_users", values)
    elsif block_given?
      instance_variable_set("@recipient_users", block)
    end
  end

  step :prepare
  step :validate
  step :permissions
  step :dispatch

  def prepare
    true
  end

  def validate
    true
  end

  def permissions
    true
  end

  def dispatch(ctx, options)
    unless self.class.processor.validate(params: params)
      self.class.processor.log_failure()
    end

    # Method to be overridden in SMS, Push, Mail classes
    true
  end
end