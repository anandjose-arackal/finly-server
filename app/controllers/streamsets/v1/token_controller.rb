class Streamsets::V1::TokenController < Oauth::TokenController

  protected

  def on_create_success(response)
    render_json 'api/fm/v1/token/create.json.jbuilder', response.status
  end

  def auth_scope
    :streamsets
  end

end
