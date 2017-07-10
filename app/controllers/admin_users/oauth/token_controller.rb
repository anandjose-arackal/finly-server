class AdminUsers::Oauth::TokenController < Oauth::TokenController

  def on_create_success(response)
    params[:request] = request
    params[:application] = 'admin_panel'
    # self.response.set_cookie 'access_token', {:value => response.token.token, :httponly => true}
    # self.response.set_cookie 'refresh_token', {:value => response.token.refresh_token, :httponly => true}
    cookies["access_token"] = {:value => @token.token, :httponly => true}
    cookies["refresh_token"] = {:value => @token.refresh_token, :httponly => true}

    # render json: {}, status: 200
    render_json 'admin_users/oauth/token/create.json.jbuilder', response.status
  end

end