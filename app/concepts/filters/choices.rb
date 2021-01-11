class Filters::Choices < Transactions::API

  schema do
    params do
      required(:route).filled
      required(:field_key).filled
    end
  end

  step :verify_route
  pass :init_klass
  step :find_attribute
  # step :verify_choices
  pass :build_choices

  def verify_route(context, params:, **)
    unless Filters::Router[params[:route]]
      return on_error context, :base, 'Route not found'
    end

    true
  end

  def init_klass(context, params:, current_user:, **)
    context[:filter_config] = Filters::Router[params[:route]]&.first&.klass
    op = Filters::Router.dispatch(params[:route], { params: { route: params[:route]}, current_user: current_user})
    context[:filters] = op[:filters]

    true
  end
  
  def find_attribute(context, params:, filter_config:, **)
    context[:attribute] = (context[:filters].filter do |filter|
      filter[:field_key] == params[:field_key].to_sym
    end).first

    unless context[:attribute].present?
      return on_error context, :base, 'Invalid Request'
    end

    true
  end

  # def verify_choices(context,  attribute:, **)
  #   unless attribute.choices.present?
  #     return on_error(context, :base, 'Invalid Request')
  #   end

  #   true
  # end

  def build_choices(context, params:, current_user:, attribute:, **)
    context[:data] = attribute[:data]

    true
  end

end