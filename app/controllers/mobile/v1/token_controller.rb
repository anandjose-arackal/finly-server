class Mobile::V1::TokenController < Oauth::TokenController

  protected
  def on_create_success(response)
    render_json 'mobile/v1/token/create.json.jbuilder', response.status
  end

  def auth_scope
    :mobile
  end

  def decode_params
    return if params[:password].blank?
    # override decode for IOS APP
    # IOS user agent name start with finly then app version
    return if request.headers['User-Agent']&.downcase&.include?("finly")
    params[:password] = Base64.decode64(params[:password])
  end

end
