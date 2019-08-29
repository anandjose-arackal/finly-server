class Transaction < Trailblazer::Operation
  include Contract::DSL, Model, TransactionMessages

  def self.SuccessMessage(message)
    -> (options) {Transaction.on_success(options, :base, message)}
  end

  def self.AssignModelUser(key: :user)
    -> (options) do
      options["model"].send("#{key}=", options['current_user'])
      options["model"].company = options["model"].send(key)&.company
      true
    end
  end

end