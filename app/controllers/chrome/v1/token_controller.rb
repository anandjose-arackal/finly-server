class Chrome::V1::TokenController < Oauth::TokenController

  protected
  def on_create_success(response)
    render_json 'chrome/v1/token/create.json.jbuilder', response.status
  end

  def auth_scope
    :chrome
  end

end
