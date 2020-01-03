require "dry/matcher"

module Transactions
  class Endpoint
    Matcher = Dry::Matcher.new(
        created: Dry::Matcher::Case.new(
            match: ->(result) {result.created?},
            resolve: ->(result) {result}),
        not_found: Dry::Matcher::Case.new(
            match: ->(result) {result.not_found?},
            resolve: ->(result) {result}),
        unauthorized: Dry::Matcher::Case.new(
            match: ->(result) {result.unauthorized?},
            resolve: ->(result) {result}),
        success: Dry::Matcher::Case.new(
            match: ->(result) {result.success?},
            resolve: ->(result) {result}),
        failure: Dry::Matcher::Case.new(
            match: ->(result) {result.failure?}, # && result["result.contract.default"] && result["result.contract.default"].failure?},
            resolve: ->(result) {result})
    )

    # `call`s the operation.
    def self.call(controller, operation_class, handlers, *args, &block)
      result = operation_class.(*args)
      new.(controller, result, handlers, &block)
    end

    def call(controller, result, handlers = nil, &block)
      if block_given?
        handlers = Handlers.new(controller, &block).()
        matcher.(result, &handlers)
        return
      end
      matcher.(result, &handlers) # then, generic Rails handlers in controller context.
      result
    end

    def matcher
      Matcher
    end

    class Handlers
      def initialize(controller, options = {}, &block)
        @controller = controller
        @representer = options[:representer] || {class: nil, name: nil, data_key: 'model'}
        @path = options[:path] # || controller&.path
        @block = block
      end

      attr_reader :controller, :block, :path, :representer

      def call
        ->(m) do
          block.call(m) if block.present?
          m.not_found {|result| not_found(result)}
          m.unauthorized {|result| unauthorized(result)}
          # m.unauthenticated {|result| unauthenticated(result)}
          m.created {|result| created(result)}
          m.success {|result| success(result)}
          m.failure {|result| failure(result)}
        end
      end

      def not_found(result)
        controller.head 404
      end

      def unauthorized(result)
        controller.head 401
      end

      def unauthenticated(result)
        controller.head 401
      end

      def created(result)
        # unless respond_with_representer(result)
          response = {
              id: (result["model"].respond_to?(:uuid) ? result["model"].uuid : result["model"].id)
          }
          controller.render json: response, status: 200
        # end
      end

      def success(result)
        # controller.render json: result['result'], status: 200
        # unless respond_with_representer(result)
        #   controller.render json: {success: true}, status: 200
        # end
      end

      def failure(result)
        controller.render json: {success: false, messages: result.messages.as_json}, status: 422
      end

      # Todo deprecated
      # def respond_with_representer(result)
      #   return false unless self.representer.present?
      #
      #   name = self.representer[:name]
      #   representer = self.representer[:class]
      #   data_key = self.representer[:data_key]
      #   return false unless (name.present? or representer.present?) and data_key.present?
      #
      #   representer = result["representer.#{name}.class"] if representer.blank?
      #   data = result[data_key]
      #   return false if representer.blank?
      #   return false if data.blank?
      #   data = data.to_a if data.is_a?(ActiveRecord::Relation)
      #
      #   controller.render json: representer.represent(data).to_json, status: 200
      #   true
      # end

    end

    module Controller
      # endpoint(Create) do |m|
      #   m.not_found { |result| .. }
      # end
      def endpoint(operation_class, options = {}, &block)
        options[:args] = [params: params.to_unsafe_h, current_user: current_user] if options[:args].nil?

        handlers = Handlers.new(self, options, &block).()
        @op = Endpoint.(self, operation_class, handlers, *options[:args], &block)
      end
    end
  end
end