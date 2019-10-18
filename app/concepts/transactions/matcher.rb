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
    end

    module ClassMethods
      def matcher(config = NoObject)
        @matcher = config unless config == NoObject
        @matcher ||= Transactions::Matcher::Default
      end
    end
  end

end