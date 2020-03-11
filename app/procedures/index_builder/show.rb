class IndexBuilder::Show < Transactions::API

  step :find_builder
  step :resolve
  step :sanitize_columns
  step :include_associations
  step :load_config

  schema do
    params do
      required(:route)
    end
  end

  def find_builder(context, params:, **)
    route = IndexBuilder::Router[params[:route]]&.first
    unless route.present?
      return on_error context, :route, 'not found'
    end

    context[:builder] = route.klass
    true
  end

  def resolve(context, builder:, params:, **)
    builder.resolve(context)

    true
  end

  def sanitize_columns(context, params:, **)
    if params[:columns].present? and not params[:columns].respond_to?(:each)
      params[:columns] = params[:columns].split(",")
    end
  end

  def include_associations(context, builder:, params:, **)
    context['model.records'] = builder.include_associations!(context['model.records'], params[:columns])

    true
  end

  def load_config(context, builder:, current_user:, params:, **)
    context['model.index'] = []
    context['model.records'].each do |record|
      context['model.index'] << builder.build(current_user, record.to_exposure, params[:columns])
    end

    true
  end

end