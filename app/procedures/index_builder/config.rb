class IndexBuilder::Config < Transactions::API

  pass :load_config

  def load_config(context, params:, current_user:, **)
    routes = IndexBuilder::Router.map
    context[:config] = {}
    params[:route] = [params[:route]] unless params[:route].blank? or params[:route].respond_to?(:each)

    routes.each do |route, route_dispatchers|
      next if params[:route].present? and not params[:route].include?(route.to_s)

      klass = route_dispatchers.first.klass
      # mandatory to specify the system
      next if klass.system_subscription.blank?
      next unless klass.system_subscription.map{|item| item.to_s}.include?(RequestStoreUtil.current_app.to_s)
      next if klass.feature_subscription and not current_user.company.feature_subscription.send(klass.feature_subscription)
      next if klass.user_subscription and not current_user.user_panel_subscription.send(klass.user_subscription)
      # Defining permissions is mandatory
      next if klass.permissions.blank? or not current_user.has_roles?(klass.permissions)

      context[:config][route] = klass.config(current_user)
    end

    true
  end

end