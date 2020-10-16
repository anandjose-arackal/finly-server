class SearchIndex::Ops::Query < Transactions::API

  skip_user_authorization!

  step :fetch_token
  step :fetch_filters
  step :query

  def fetch_token(context, **)
    context[:token] = RequestStoreUtil.current_request.headers['Authorization']
    return unauthorized!(context) if context[:token].blank?

    true
  end

  def fetch_filters(context, token:, **)
    context[:config] = Rails.configuration.redis.get(token)
    context[:config] = JSON.parse(context[:config]).with_indifferent_access if context[:config]
    return unauthorized!(context) if context[:config].blank? or context[:config][:filters].blank? or context[:config][:facets].blank?

    true
  end

  def query(context, config:, params:, **)
    filters = config[:filters]
    facets = config[:facets]
    facets += JSON.parse(params[:facets]) if params[:facets].present?
    context[:response] = Indexes::Vp.index.search(params[:q], {filters: filters, facets: facets, facets_distribution: ['record_type'], offset: (params[:offset] || 0), limit: (params[:limit] || 20)})
  end

end