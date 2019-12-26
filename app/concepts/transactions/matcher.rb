module Transactions::Matcher

  DefaultCases = {
      created: Dry::Matcher::Case.new(
          match: ->(result) { result.created? },
          resolve: ->(result) { result },
      ),
      not_found: Dry::Matcher::Case.new(
          match: ->(result) { result.not_found? },
          resolve: ->(result) { result },
      ),
      unauthorized: Dry::Matcher::Case.new(
          match: ->(result) { result.unauthorized? },
          resolve: ->(result) { result },
      ),
      success: Dry::Matcher::Case.new(
          match: ->(result) { result.success? },
          resolve: ->(result) { result },
      ),
      failure: Dry::Matcher::Case.new(
          match: ->(result) { result.failure? },
          resolve: ->(result) { result }
      )
  }

  Default = Dry::Matcher.new(
      DefaultCases
  )

  module Transactions::Matcher::DSL
    def self.included(base)
      base.extend ClassMethods
      base.include DynamicAttributes
      base.class_attr :matcher, default: Transactions::Matcher::Default
    end

    module ClassMethods
      def match_result(options, result, &block)
        return nil unless matcher.present?

        return nil unless block_given?

        if matcher.is_a?(Symbol)
          matcher_klass = self.send(matcher, options, result)
        else
          matcher_klass = matcher
        end

        # handlers = Transactions::Endpoint::Handlers.new(self, options, &block).()

        matcher_klass.(result, &block) if block_given?
      end
    end
  end

end