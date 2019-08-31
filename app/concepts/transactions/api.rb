class Transactions::API < Trailblazer::Operation
  include Contract::DSL, Model, Transactions::Messages

  def self.AssignModelUser(key: :user)
    -> (options) do
      options["model"].send("#{key}=", options['current_user'])
      options["model"].company = options["model"].send(key)&.company
      true
    end
  end

end