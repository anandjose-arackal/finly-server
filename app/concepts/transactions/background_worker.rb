module Transactions::BackgroundWorker
  extend ActiveSupport::Concern

  WAIT_TIMEOUT = 45.seconds

  included do
    include Sidekiq::Worker
  end

  class_methods do
    def call_async(payload, wait: false, wait_timeout: WAIT_TIMEOUT, &handlers)
      encoded_data = Events::Serializer.encode(payload)
      if wait
        result = perform_with_wait encoded_data, wait_timeout
        match_result(payload, result, &handlers)
        return result
      else
        self.perform_async(encoded_data)
      end
    end

    def perform_with_wait(encoded_data, timeout)
      response_handle = "#{self.object_id}_#{DateTime.now.strftime("%y%m%d%s%m")}"
      self.perform_async(encoded_data, response_handle)
      timeout ||= WAIT_TIMEOUT
      now = Time.now
      while (Time.now - now) < timeout
        result = Resque.reserve(response_handle)

        next if result.blank?

        return result.args.first
      end
      {success: false, timeout: true} # todo Add timeout messages
    end

    def respond_to_handle(result, response_handle)
      queue = Struct.new(:queue).new(response_handle)
      response = result.to_hash
      success = result.success? ? true : false
      Resque.enqueue(queue, filter_result(response).merge({success: success, errors: result.errors}))
    end

    # Filter hash/array to only keep basic data types such as Numeric, Symbol and Strings.
    # This is to primarily prevent the stack too deep exception that happens when converting certain
    # objects such as Faraday::Response to json
    def filter_result(value)
      if value.is_a?(Numeric) or value.is_a?(Symbol) or value.is_a?(String)
        return value
      elsif value.is_a?(Array)
        result = []
        value.each do |v|
          data = filter_result(v)
          result << data unless data == NoObject
        end
        result
      elsif value.is_a?(Hash)
        result = {}
        value.each do |k, v|
          data = filter_result(v)
          result[k] = data unless data == NoObject
        end
        result
      else
        NoObject
      end
    end
  end

  def perform(payload, response_handle = nil)
    decoded_data = Events::Serializer.decode(payload).with_indifferent_access
    result = self.class.call(decoded_data)
    self.class.respond_to_handle(result, response_handle) if response_handle
    result
  end
end
