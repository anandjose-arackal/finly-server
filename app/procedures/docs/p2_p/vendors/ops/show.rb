class Docs::P2P::Vendors::Ops::Show < Transactions::API

  step Model(YesBankVendor, :find_by)
  step :retrieve_form


  def retrieve_form(options, params:, current_user:, **)
    options['form'] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(:vendors)&.name, company_id: current_user.company_id)
  end

end