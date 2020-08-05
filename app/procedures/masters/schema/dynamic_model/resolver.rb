class Masters::Schema::DynamicModel::Resolver < Resolver::API

  def load(params)
    params[:model].where(company_id: user.company_id)
  end

end