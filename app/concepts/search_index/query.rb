class SearchIndex::Query < Transactions::API

  skip_user_authorization!

  step :fetch_token
  step :fetch_filters
  step :query

  def fetch_token(context, **)
    context[:token] = RequestStoreUtil.current_request.headers['Authorization']
    return unauthorized! if context[:token].blank?

    true
  end

  def fetch_filters(context, token:, **)
    context[:config] = Rails.configuration.redis.get(token)
    context[:config] = JSON.parse(context[:config]).with_indifferent_access if context[:config]
    return unauthorized! if context[:config].blank? or context[:config][:filters].blank? or context[:config][:facets].blank?

    true
  end

  def query(context, config:, params:, **)
    filters = config[:filters]
    facets = config[:facets]
    context[:response] = VpRecordsIndex.index.search(params[:q], {filters: filters, facets: facets})
  end

end