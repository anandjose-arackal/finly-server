class Api::Fm::V1::TokenController < Oauth::TokenController
  include AbstractController::Callbacks
  include ActionController::Head

  protected
  def pre_process
    #todo - temporary for testing
    # if block_foreign_hosts(WhitelistedIpType.id_for(:api))
    #   return false
    # end
    super
  end

  def on_create_success(response)
    render_json 'api/fm/v1/token/create.json.jbuilder', response.status
  end

  def whitelisted?(ip, type_id)
    return true if WhitelistedIp.with_type(type_id).with_ip(ip).present?
    false
  end

  def block_foreign_hosts(type_id)
    return false if whitelisted?(request.remote_ip, type_id)
    head(403)
  end

  def auth_scope
    :api
  end

end
