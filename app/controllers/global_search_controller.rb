class GlobalSearchController < BaseControllers::WebBase

  def skip_finly_authorize?
    params[:action].to_s == 'index'
  end

  def create
    endpoint SearchIndex::GenerateToken
  end

  def index
    RequestStoreUtil.set_current_request(request)
    endpoint SearchIndex::Query
  end

  def set_client_version

  end

end
