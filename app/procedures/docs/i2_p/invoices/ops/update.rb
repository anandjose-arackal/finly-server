class Docs::I2P::Invoices::Ops::Update < Transactions::API

  step :retrieve_form
  step Model(Invoice, :find_by)
  # step Policy::Pundit(Docs::I2P::Invoices::Policy, :update?)
  step Forms::Contracts::Build()

  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Invoice Updated')


  def retrieve_form(options, params:, current_user:, **)
    invoice_id = params['id'].to_i
    invoice_type = Invoice.find(invoice_id)&.invoice_type&.name&.to_sym
    options['form'] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(invoice_type)&.name, company_id: current_user.company_id)
  end
end