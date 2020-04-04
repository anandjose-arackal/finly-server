class IndexSegment::Ops::Index < Transactions::API

  schema do
    params do
      required(:screen).filled
    end
  end

  step Resolver::Transactions::Load(model: IndexViewSegment)
  pass :load_system_views
  pass :load_user_views

  def load_system_views(context, params:, current_user:, **)
    screen = params[:screen]
    context[:system_views] = []
    IndexSegment::SystemViews::Registry.system_views(screen).each do |view|
      val = view.build(current_user)
      next if val.blank?

      context[:system_views] << val
    end
  end

  def load_user_views(context, params:, **)
    context[:user_views] = context['model.records'] || []
  end

end