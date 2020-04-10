class Filters::Choices < Transactions::API

  schema do
    params do
      required(:route).filled(inclusion?: Filters::Router.routes)
      required(:field_key).filled
    end
  end

  pass :init_klass
  step :find_attribute
  step :verify_choices
  pass :build_choices

  def init_klass(context, params:, **)
    context[:filter_config] = Filters::Router[params[:route]]&.first&.klass
  end

  def find_attribute(context, params:, filter_config:, **)
    context[:attribute] = filter_config.attributes[params[:field_key]]
    unless context[:attribute].present?
      return on_error context, :base, 'Invalid Request'
    end

    true
  end

  def verify_choices(context,  attribute:, **)
    unless attribute.choices.present?
      return on_error(context, :base, 'Invalid Request')
    end

    true
  end

  def build_choices(context, params:, current_user:, attribute:, **)
    context[:data] = attribute.choices.as_json(params: params, user: current_user)
  end

end