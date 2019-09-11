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
            match: ->(result) {result.failure? && result["result.model"] && result["result.model"].failure?},
            resolve: ->(result) {result}),
        # TODO: we could add unauthorized here.
        unauthorized: Dry::Matcher::Case.new(
            match: ->(result) {result.failure? && result["result.policy.default"].failure?}, # FIXME: we might need a &. here ;)
            resolve: ->(result) {result}),
        unauthenticated: Dry::Matcher::Case.new(
            match: ->(result) {result.failure? && result["result.policy.default"].failure?}, # FIXME: we might need a &. here ;)
            resolve: ->(result) {result}),
        invalid: Dry::Matcher::Case.new(
            match: ->(result) {result.failure? && result["result.contract.default"] && result["result.contract.default"].failure?},
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
        @path = options[:path]# || controller&.path
        @block = block
      end

      attr_reader :controller, :block, :path

      def call
        ->(m) do
          block.call(m) if block.present?
          m.not_found {|result| controller.head 404}
          m.unauthorized {|result| controller.head 401}
          m.unauthenticated {|result| controller.head 401}
          m.created {|result| controller.render json: {success: true, id: result["model"].id}, status: 200}
          m.success {|result| controller.render json: {success: true}, status: 200}
          m.invalid {|result| controller.render json: {success: false, errors: result['result.contract.default'].errors.as_json}, status: 422}
        end
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