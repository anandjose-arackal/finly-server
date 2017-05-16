class Oauth::TokenController < Opro::Oauth::TokenController


  def create
    # super()
    application = Opro::Oauth::ClientApp.authenticate(params[:client_id], params[:client_secret])

    if application.present? && (@auth_grant = auth_grant_for(application, params)).present?
      @auth_grant.refresh!

      if @auth_grant
        cookies["access_token"] = { :value => @auth_grant.access_token, :httponly => true }
        cookies["refresh_token"] = { :value => @auth_grant.refresh_token, :httponly => true }
        @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/feature_subscription.yml.erb", {current_company: @auth_grant.user.company, current_user: @auth_grant.user})
      end
      render :create
    else
      render_error debug_msg(params, application)
    end

    # # Setting access tokens in cookies, will be removed at the time of signing out
    # if @auth_grant
    #   cookies["access_token"] = { :value => @auth_grant.access_token, :httponly => true }
    #   cookies["refresh_token"] = { :value => @auth_grant.refresh_token, :httponly => true }
    #   @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/feature_subscription.yml.erb", {current_company: @auth_grant.user.company, current_user: @auth_grant.user})
    #   debugger
    # end
  end
end