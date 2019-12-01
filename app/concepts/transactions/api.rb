class Transactions::API < Trailblazer::Operation
  include Contract::DSL
  include Model
  include Transactions::Messages
  include Transactions::Schema::DSL
  include Transactions::Authorization::DSL
  include Transactions::Matcher::DSL
  include Dry::Monads[:result]
  include Transactions::API::BackgroundHandler

  module Transactions::API::BackgroundHandler
    extend ActiveSupport::Concern

    class_methods do
      def call_async(payload)
        self.perform_async(payload)
      end

      def perform_async(payload)
        encoded_data = Events::Serializer.encode(payload)
        super(encoded_data)
      end

    end

    def perform(payload)
      decoded_data = Events::Serializer.decode(data)
      self.class.call(decoded_data)
    end
  end

  # Dummy step to help define schema after operation has started
  step ->(options) { true }, name: 'operations.start'

  # Step options: :before, :after, :replace, :delete, :override

  def self.AssignModelUser(key: :user)
    -> (options) do
      options["model"].send("#{key}=", options['current_user'])
      options["model"].company = options["model"].send(key)&.company
      true
    end
  end

  def self.call(options = {}, *dependencies, &handlers)
    result = super(options, *dependencies)
    if matcher.present?
      matcher.(result, &handlers) if block_given?
    end
    result
  end

end