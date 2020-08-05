class Masters::Schema::Resolver < Resolver::API

  def load(params)
    MasterSchema.where(company_id: user.company_id)
  end

end