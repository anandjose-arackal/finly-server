class Masters::Schema::Records::Resolver < Resolver::API

  def load(params)
    params[:model_class].where(company_id: user.company_id)
  end

end