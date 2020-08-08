class Masters::Schema::Records::Ops::Destroy < Masters::Schema::Records::Base

  schema do
    params do
      required(:master_key).filled
    end
  end

  # This is defined in base class
  step RecordModel(:find)
  step Policy::Pundit(Masters::Schema::Records::Policy, :destroy?)
  step :destroy
  step Transactions::Messages::SuccessMessage('Deleted')

  def destroy(context, model:, **)
    model.destroy
  end

end