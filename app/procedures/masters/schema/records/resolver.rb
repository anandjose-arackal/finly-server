class Masters::Schema::Records::Resolver < Resolver::API

  def load(params)
    params[:record_model].where(company_id: user.company_id)
  end

end