class IndexSegment::Resolver < Resolver::API

  entity IndexViewSegment

  def load(params)
    records = entity.where(user_id: user.id)
    records = entity.where(screen: params[:screen]) if params[:screen].present?
    records = records.where(application: RequestStoreUtil.current_app)
    records
  end

end