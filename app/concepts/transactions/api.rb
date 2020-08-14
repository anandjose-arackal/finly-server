class Transactions::API < Trailblazer::Operation
  include Contract::DSL
  include Trailblazer::Macro
  include Forms::Transactions::Macro
  include Transactions::Messages
  include Transactions::Schema::DSL
  include Transactions::Authorization::DSL
  include Transactions::Matcher::DSL
  extend Trailblazer::Activity::TaskBuilder
  include Transactions::Result::Evaluator
  include Dry::Monads[:result]

  # Dummy step to help define schema after operation has started
  step ->(context, options) { true }, id: 'operations.start'

  # Step options: :before, :after, :replace, :delete, :override

  def self.AssignModelUser(key: :user)
    Transactions::Task.build id: "assign_model_user" do |context, **|
      context[:model].send("#{key}=", context[:current_user]) if context[:model].respond_to?("#{key}=")
      context[:model].company = context[:current_user]&.company if context[:model].respond_to?("company=")
      true
    end
  end

  def self.ModelDestroy(key: :model)
    Transactions::Task.build id: "destroy" do |context, **|
      unless context[key].destroy
        return on_error context, :base, context[key].errors.full_messages
      end

      true
    end
  end

  def self.call(options = {}, *args, &handlers)
    result = super(options, *args)
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