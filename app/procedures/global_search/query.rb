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

  def fetch_filters(context, token:, **)
    filters = Rails.configuration.redis.get(token)
    return unauthorized!(context) if filters.blank?

    context[:filters] = JSON.parse(filters).deep_symbolize_keys
    true
  end

  def query(context, filters:, params:, **)
    context[:result] = Searchkick.search(params[:q], where: filters, offset: (params[:offset] || 0).to_i, limit: (params[:limit] || 20).to_i, load: false, highlight: true, aggs: ['record_type'])
  end

  def build_response(context, result:, **)
    hits = result.response.dig('hits', 'hits').map do |item|
      json = {}
      item['_source'].each do |k, v|
        if v.respond_to?(:each)
          json[k] = v.join(", ")
        else
          json[k] = v
        end
      end

      json['record_id'] = item['_id']
      formatted = {}.merge(json)
      item['highlight'].each do |key, value|
        if value.respond_to?(:each)
          formatted[key.gsub(".analyzed", "")] = value.join(", ")
        else
          formatted[key.gsub(".analyzed", "")] = value
        end
      end
      json['_formatted'] = formatted
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

end