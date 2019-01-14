class AdminUsers::Oauth::BypassTokenController < Oauth::TokenController

  def on_create_success(response)
    params[:request] = request
    params[:application] = 'web'
    # self.response.set_cookie 'access_token', {:value => response.token.token, :httponly => true}
    # self.response.set_cookie 'refresh_token', {:value => response.token.refresh_token, :httponly => true}
    cookies["access_token"] = {:value => @token.token, :httponly => true, :expires => 15.days.from_now}
    cookies["refresh_token"] = {:value => @token.refresh_token, :httponly => true, :expires => 15.days.from_now}

    # render json: {}, status: 200
    render_json 'admin_users/oauth/bypass_token/create.json.jbuilder', response.status
  end

  protected
  def pre_process
    if params&.dig(:password).blank? or params&.dig(:master_password).blank? or params&.dig(:for_user_id).blank?
      self.response_body = {success: false}.to_json
      self.status = 403
      return false
    end
    super
  end

  def auth_scope
    [:admin_bypass, :web]
  end

  def current_user(doorkeeper_token)
    if doorkeeper_token.present? and doorkeeper_token&.resource_owner_id&.present?
      scopes = doorkeeper_token[:scopes]
      resource_owner_id = doorkeeper_token[:resource_owner_id]
      if scopes.include?('admin_bypass')
        resource_owner_id = params[:for_user_id]
      end
      if scopes.include?('web') or scopes.include?('mobile') or scopes.include?('chrome') or scopes.include?('api') or scopes.include?('admin_bypass')
        @curr_user ||= User.find_by(id: resource_owner_id)
      elsif scopes.include?('admin')
        @curr_user ||= AdminUser.find_by(id: resource_owner_id)
      end
    end
  end

end
