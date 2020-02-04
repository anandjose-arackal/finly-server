class Notifier::API < Transactions::API
  include DynamicAttributes
  include Events::Consumer

  def self.event(event_name)
    consumes_event! 'mail'
  end

  def on_event(user, payload)
    self.class.(params: params, current_user: user)
  end

  attr_accessor :user, :params, :payload

  class_attr :payload, default: {}

  def self.set(key, value = nil, &block)
    if value.present?
      payload[key] = value.class.name == 'Proc' ? {block: value} : {value: value}
    elsif block_given?
      payload[key] = {block: block}
    end
  end

  step :permissions
  step :prepare
  step :validate
  step :dispatch

  def permissions(ctx, options)
    true
  end

  def prepare(options, params:, current_user:, **)
    payload = {}
    self.class.payload.each do |key, value|
      if value[:value].present?
        payload[key] = value[:value]
      elsif value[:block].present?
        payload[key] = value[:block].call(user, params)
      end
    end

    options[:payload] = payload
    true
  end

  def validate(options, payload:, **)
    true
  end

  def dispatch(options, params:, current_user:, **)
    true
  end
end