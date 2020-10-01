class GlobalSearchController < BaseControllers::WebBase

  def skip_finly_authorize?
    params[:action].to_s == 'index'
  end

  def create
    endpoint SearchIndex::GenerateToken
    # Going with direct rendering as it is faster than jbuilder
    if @op.success?
      render json: {
          token: @op[:token],
          documents: @op[:documents]
      }
    end
  end

  def index
    RequestStoreUtil.set_current_request(request)
    endpoint SearchIndex::Query
    # Going with direct rendering as it is faster than jbuilder
    if @op.success?
      render json: {
          data: {
              records: @op[:response]&.dig('hits').group_by {|hit| hit['record_type']},
              facets_distribution: @op[:response]&.dig('facetsDistribution')['record_type'],
              count: @op[:response]['nbHits']
          }
      }
    end
  end

  def set_client_version
    # Displaying to reduce the query
  end

end
