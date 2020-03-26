class IndexSegment::Resolver < Resolver::API

  entity IndexViewSegment

  def load(params)
    entity.where(company_id: user.company_id, user_id: user.id, screen: params[:screen])
  end

end