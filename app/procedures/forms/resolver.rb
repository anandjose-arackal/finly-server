class Forms::Resolver < Resolver::API

  def load(params)
    entity.where(company_id: user.company_id)
  end

end