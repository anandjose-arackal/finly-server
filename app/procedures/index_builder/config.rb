class IndexBuilder::Config < Transactions::API

  step :find_builder
  step :load_config

  schema do
    params do
      required(:route)
    end
  end

  def find_builder(context, params:, **)
    context[:route] = IndexBuilder::Router[params[:route]]&.first
    unless context[:route].present?
      return on_error context, :route, "not found"
    end

    true
  end

  def load_config(context, route:, current_user:, **)
    context[:config] = route.klass.config(current_user)

    true
  end

end