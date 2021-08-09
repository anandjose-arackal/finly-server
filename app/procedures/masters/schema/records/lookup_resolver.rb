class Masters::Schema::Records::LookupResolver < Masters::Schema::Records::Resolver

  def load(params)
    if params[:route].present?
      init_record_model_class(params, user)
    end
    params[:model_class].where(company_id: user.company_id)
  end

end