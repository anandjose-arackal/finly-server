class Transactions::API < Trailblazer::Operation
  include Contract::DSL
  include Trailblazer::Macro
  include Transactions::Messages
  include Transactions::Schema::DSL
  include Transactions::Authorization::DSL
  include Transactions::Matcher::DSL
  include Dry::Monads[:result]

  # Dummy step to help define schema after operation has started
  step ->(context, options) { true }, name: 'operations.start'

  # Step options: :before, :after, :replace, :delete, :override

  def self.AssignModelUser(key: :user)
    -> (context, options) do
      context["model"].send("#{key}=", context['current_user'])
      context["model"].company = context["model"].send(key)&.company
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