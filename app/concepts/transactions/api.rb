class Transactions::API < Trailblazer::Operation
  include Contract::DSL
  include Model
  include Transactions::Messages
  include Transactions::Schema::DSL
  include Transactions::Authorization::DSL

  # Dummy step to help define schema after operation has started
  step ->(options) {true}, name: 'operations.start'

  # Step options: :before, :after, :replace, :delete, :override

  def self.AssignModelUser(key: :user)
    -> (options) do
      options["model"].send("#{key}=", options['current_user'])
      options["model"].company = options["model"].send(key)&.company
      true
    end
  end

end