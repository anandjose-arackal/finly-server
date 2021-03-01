class Docs::I2P::Invoices::Ops::Update < Transactions::API

  step Model(Invoice, :find_by)
  step Policy::Pundit(Docs::I2P::Invoices::Policy, :update?)
  step :retrieve_form
  step Forms::Contracts::Build()
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Invoice Updated')

  def retrieve_form(options, params:, current_user:, model:, **)
    options['form'] = model.form
  end
end