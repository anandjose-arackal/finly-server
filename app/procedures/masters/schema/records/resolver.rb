class Masters::Schema::Records::Resolver < Resolver::API

  def load(params)
    if params[:route].present?
      init_record_model_class(params, user)
    end
    data = params[:model_class].where(company_id: user.company_id)
    if params[:model_class].schema.has_nesting
      data = data.where(ancestry: nil)
    end

    data
  end

  def init_record_model_class(params, user)
    # master_key can be fetched from the route with the format masters.<master_key>
    master_key = params[:route].split(".")[1]

    params[:model] = MasterSchema.find_by(company_id: user.company_id, master_key: master_key)
    unless params[:model].present?
      raise 'master not found'
    end
    params[:model_class] = params[:model].record_model_class
    unless params[:model_class].present?
      raise 'master not found'
    end

    true
  end

end