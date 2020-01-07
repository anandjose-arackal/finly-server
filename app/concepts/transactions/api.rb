class Transactions::API < Trailblazer::Operation
  include Contract::DSL
  include Trailblazer::Macro
  include Transactions::Messages
  include Transactions::Schema::DSL
  include Transactions::Authorization::DSL
  include Transactions::Matcher::DSL
  extend Trailblazer::Activity::TaskBuilder
  include Dry::Monads[:result]

  # Dummy step to help define schema after operation has started
  step ->(context, options) { true }, id: 'operations.start'

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
    match_result(options, result, &handlers)
    # if matcher.present?
    #   if matcher.is_a?(Symbol)
    #     matcher_klass = self.send(matcher, options, result)
    #   else
    #     matcher_klass = matcher
    #   end
    #   matcher_klass.(result, &handlers) if block_given?
    # end
    result
  end

  class Transactions::API::Background < Transactions::API
    # include Trailblazer::Operation::Worker
    # Todo
  end

end