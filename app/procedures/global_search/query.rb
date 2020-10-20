class GlobalSearch::Query < Transactions::API

  skip_user_authorization!

  step :fetch_token
  step :fetch_filters
  step :query
  step :build_response

  def fetch_token(context, **)
    context[:token] = RequestStoreUtil.current_request.headers['Authorization']
    return unauthorized!(context) if context[:token].blank?

    true
  end

  def fetch_filters(context, token:, params:, **)
    filters = Rails.configuration.redis.get(token)
    return unauthorized!(context) if filters.blank?

    context[:filters] = JSON.parse(filters).deep_symbolize_keys
    context[:filters][:_and] << params[:filters] if params[:filters].present?
    true
  end

  def query(context, filters:, params:, **)
    context[:result] = Searchkick.search(
        params[:q],
        models: Searchkick.models,
        where: filters,
        offset: (params[:offset] || 0).to_i,
        limit: (params[:limit] || 20).to_i,
        load: false,
        highlight: true,
        aggs: ['record_type'],
    )
  end

  def build_response(context, result:, **)
    hits = result.response.dig('hits', 'hits').map do |item|
      json = {}
      model = model_from_index(item['_index'])
      searchkick_api = model.searchkick_api
      displayable_fields = searchkick_api.displayable_fields
      item['_source'].slice(*displayable_fields).each do |k, v|
        if v.respond_to?(:each)
          json[k] = v.join(", ")
        else
          json[k] = v
        end
      end

      json['record_id'] = item['_id']
      formatted = {}.merge(json)
      item['highlight'].each do |key, value|
        formatted_key = key.gsub('.analyzed', '')
        next unless displayable_fields.include?(formatted_key)

        if value.respond_to?(:each)
          formatted[formatted_key] = value.join(", ")
        else
          formatted[formatted_key] = value
        end
      end
      json['_formatted'] = formatted
      json['_matchesInfo'] = formatted
      json
    end
    aggregations = {}
    result.response&.dig("aggregations", 'record_type', 'record_type', 'buckets').each do |aggr|
      aggregations[aggr['key']] = aggr['doc_count']
    end
    context[:response] = {
        count: result.response.dig('aggregations', 'record_type', 'doc_count'),
        aggregations: aggregations,
        records: hits.group_by { |hit| hit['record_type'] },
    }
  end

  def model_from_index(index)
    index_model_map.each do |ind, model|
      return model if index.start_with?(ind)
    end

    nil
  end

  def index_model_map
    return @index_model_map if @index_model_map.present?

    @index_model_map = {}
    Searchkick.models.each do |model|
      @index_model_map[model.searchkick_index.name] = model
    end
    @index_model_map
  end

end