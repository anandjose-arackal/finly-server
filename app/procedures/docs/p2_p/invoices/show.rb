class Docs::P2P::Invoices::Show < Transactions::API

  # step Form(route: 'invoices')
  # step Model(Invoice, :find_by)
  # step Policy::Pundit(Docs::P2P::Invoices::Policy, :show?)
  # step Forms::Contracts::Build()

  step Model(Invoice, :find_by)
  step :retrieve_form

  def retrieve_form(options, params:, current_user:, **)
    options['form'] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(:invoices)&.name, company_id: current_user.company_id)
  end

end