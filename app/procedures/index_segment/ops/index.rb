class IndexSegment::Ops::Index < Transactions::API

  user_model [User, AdminUser]

  step Resolver::Transactions::Load(model: IndexViewSegment)
  pass :load_system_views
  pass :load_user_views

  def load_system_views(context, params:, current_user:, **)
    context[:views] = {}
    IndexSegment::SystemViews::Registry.registry.each_pair do |screen, views|
      next if params[:screen].present? and not screen.to_s == params[:screen].to_s

      views.each do |view|
        next unless view.system_subscription.to_s == RequestStoreUtil.current_app.to_s

        val = view.build(current_user)
        next if val.blank?

        context[:views][screen] ||= {system_views: [], user_views: []}
        context[:views][screen][:system_views] << val
      end
    end
  end

  def load_user_views(context, params:, **)
    context['model.records'].each do |record|
      next if params[:screen].present? and not record.screen.to_s == params[:screen].to_s

      context[:views][record.screen] ||= {system_views: [], user_views: []}
      context[:views][record.screen][:user_views] << record
    end
  end

end