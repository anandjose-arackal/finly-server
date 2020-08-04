class Forms::Entities::Ops::Destroy < Transactions::API

  step Model(FormEntity, :find_by_uuid)

  step Policy::Pundit(Forms::Entities::Policy, :destroy?)

  step :destroy!

  step Transactions::Messages::SuccessMessage('Successfully Deleted Field')

  def destroy!(options, model:, **)
    model.destroy
  end
end