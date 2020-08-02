class Forms::ChoiceDependencies::Ops::Destroy < Transactions::API

  step Model(FormChoiceDependency, :find_by_uuid)

  step Policy::Pundit(Forms::ChoiceDependencies::Policy, :destroy?)

  step :destroy!

  step Transactions::Messages::SuccessMessage('Successfully Deleted Dependency')

  def destroy!(options, model:, **)
    model.destroy
  end
end