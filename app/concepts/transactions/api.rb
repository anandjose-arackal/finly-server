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

    included do
      include Sidekiq::Worker
    end

    class_methods do
      def call_async(payload)
        encoded_data = Events::Serializer.encode(payload)
        self.perform_async(encoded_data)
      end
    end

    def perform(payload)
      decoded_data = Events::Serializer.decode(payload)
      self.class.call(decoded_data)
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
      matcher.(result, &handlers) if block_given?
    end
    result
  end

  class Transactions::API::Background < Transactions::API
    # include Trailblazer::Operation::Worker

    # Todo


  end

end