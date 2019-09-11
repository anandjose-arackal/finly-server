require "dry/matcher"

module Transactions
  class Endpoint
    Matcher = Dry::Matcher.new(
        success: Dry::Matcher::Case.new(
            match: ->(result) {result.success?},
            resolve: ->(result) {result}),
        created: Dry::Matcher::Case.new(
            match: ->(result) {result.success? && result["model.action"] == :new}, # the "model.action" doesn't mean you need Model.
            resolve: ->(result) {result}),
        not_found: Dry::Matcher::Case.new(
            match: ->(result) {result.failure? && result["result.model"] && result["result.model"]&.failure?},
            resolve: ->(result) {result}),
        # TODO: we could add unauthorized here.
        # unauthorized: Dry::Matcher::Case.new(
        #     match: ->(result) {result.failure? && result["result.policy.default"].failure?}, # FIXME: we might need a &. here ;)
        #     resolve: ->(result) {result}),
        unauthenticated: Dry::Matcher::Case.new(
            match: ->(result) {result.failure? && result["result.policy.default"]&.failure?}, # FIXME: we might need a &. here ;)
            resolve: ->(result) {result}),
        invalid: Dry::Matcher::Case.new(
            match: ->(result) {result.failure?},# && result["result.contract.default"] && result["result.contract.default"].failure?},
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
    end

    def matcher
      Matcher
    end

    class Handlers
      def initialize(controller, options = {}, &block)
        @controller = controller
        @representer = options[:representer] || {class: nil, name: nil, data: 'result.model'}
        @path = options[:path] # || controller&.path
        @block = block
      end

      attr_reader :controller, :block, :path, :representer

      def call
        ->(m) do
          block.call(m) if block.present?
          m.not_found {|result| not_found(result)}
          m.unauthenticated {|result| unauthenticated(result)}
          m.created {|result| created(result)}
          m.success {|result| success(result)}
          m.invalid {|result| invalid(result)}
        end
      end

      def not_found(result)
        controller.head 404
      end

      def unauthenticated(result)
        controller.head 401
      end

      def created(result)
        unless respond_with_representer(result)
          controller.render json: {success: true, id: result["result.model"].id}, status: 200
        end
      end

      def success(result)
        unless respond_with_representer(result)
          controller.render json: {success: true}, status: 200
        end
      end

      def invalid(result)
        controller.render json: {success: false, errors: result.errors.as_json}, status: 422
      end

      def respond_with_representer(result)
        return false unless self.representer.present?

        name = self.representer[:name]
        representer = self.representer[:class]
        data_key = self.representer[:data_key]
        return false unless (name.present? or representer.present?) and data_key.present?

        representer = result["representer.#{name}.class"] if representer.blank?
        data = result[data_key]
        return false if representer.blank?
        return false if data.blank?

        controller.render json: {success: true}.merge(representer.represent(data)).to_json, status: 200
        false
      end

    end

    module Controller
      # endpoint(Create) do |m|
      #   m.not_found { |result| .. }
      # end
      def endpoint(operation_class, options = {}, &block)
        handlers = Handlers.new(self, options, &block).()
        Endpoint.(self, operation_class, handlers, *options[:args], &block)
      end
    end
  end
end