class Docs::I2P::Invoices::Ops::Show < Transactions::API

  step Model(Invoice, :find_by)
  step Policy::Pundit(Docs::P2P::Invoices::Policy, :show?)

  step :retrieve_form

  def retrieve_form(options, model:, params:, current_user:, **)
    options['form'] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(:invoices)&.name, company_id: current_user.company_id)
  end

end