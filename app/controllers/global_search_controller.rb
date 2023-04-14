class GlobalSearchController < BaseControllers::WebBase

  def skip_finly_authorize?
    params[:action].to_s == 'index'
  end

  def create
    endpoint GlobalSearch::Config
    # Going with direct rendering as it is faster than jbuilder
    if @op.success?
      render json: {
          token: @op[:token],
          expires_in: @op[:expires_in],
          documents: @op[:documents],
          indicator_map: @op[:indicator_map]
      }
    end
  end

  def index
    RequestStoreUtil.set_current_request(request)
    RequestStoreUtil.set_request_params(params)
    RequestStoreUtil.set_current_user(current_user)
    RequestStoreUtil.set_current_company(current_user&.company)

    endpoint GlobalSearch::Query
    if @op.success?
    # Going with direct rendering as it is faster than jbuilder
      render json: {
          data: @op[:response]
      }
    end
  end

  def form_features_state
    forms_state = FormsState.new(current_user)
    forms_configured = forms_state.form_configurations("forms_features")&.split(',')&.to_a&.collect(&:strip)
    enabled = forms_configured.map{ |feature| forms_state.feature_enabled?(feature)}
    render json: forms_configured.zip(enabled).to_h unless forms_configured.to_s.empty?
  end

  def set_client_version
    # Displaying to reduce the query
  end

end
