class IndexBuilder::StatusCount < Transactions::API

  step :find_builder
  step :verify_counter
  pass :resolve
  step :count

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

  def verify_counter(context, builder:, **)
    unless builder.counter.present?
      return on_error context, :base, "unable to summarize request"
    end
    true
  end

  def resolve(context, builder:, params:, **)
    builder.resolve(context)
  end


  def count(context, builder:, **)
    counter = builder.counter.call(context['model.records'])
    context['counter'] = counter.as_json

    true
  end

end