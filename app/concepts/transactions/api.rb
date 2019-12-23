class Transactions::API < Trailblazer::Operation
  include Contract::DSL
  include Trailblazer::Macro
  include Transactions::Messages
  include Transactions::Schema::DSL
  include Transactions::Authorization::DSL
  include Transactions::Matcher::DSL
  extend Trailblazer::Activity::TaskBuilder
  include Dry::Monads[:result]

  module Transactions::API::BackgroundWorker
    extend ActiveSupport::Concern

    WAIT_TIMEOUT = 30.seconds

    included do
      include Sidekiq::Worker
    end

    class_methods do
      def call_async(payload, wait: false, wait_timeout: WAIT_TIMEOUT)
        encoded_data = Events::Serializer.encode(payload)
        if wait
          return perform_with_wait encoded_data, wait_timeout
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
      end
    end

    def perform(payload, response_handle = nil)
      decoded_data = Events::Serializer.decode(payload)
      result = self.class.call(decoded_data)
      respond_to_handle(result, response_handle) if response_handle
      result
    end

    def respond_to_handle(result, response_handle)
      queue = Struct.new(:queue).new(response_handle)
      response = result.as_json.except('params', 'current_user')
      success = result.success? ? true : false
      Resque.enqueue(queue, {success: success, result: response, errors: result.errors})
    end
  end

  # Dummy step to help define schema after operation has started
  step ->(context, options) {true}, id: 'operations.start'

  # Step options: :before, :after, :replace, :delete, :override

  def self.AssignModelUser(key: :user)
    Transactions::Task.build id: "assign_model_user" do |context, **|
      context[:model].send("#{key}=", context[:current_user])
      context[:model].company = context[:model].send(key)&.company
      true
    end
  end

  def self.call(options = {}, &handlers)
    result = super(options)
    if matcher.present?
      if matcher.is_a?(Symbol)
        matcher_klass = self.send(matcher, options, result)
      else
        matcher_klass = matcher
      end
      matcher_klass.(result, &handlers) if block_given?
    end
    result
  end

  class Transactions::API::Background < Transactions::API
    # include Trailblazer::Operation::Worker

    # Todo


  end

end