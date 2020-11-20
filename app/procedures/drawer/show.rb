class Drawer::Show < Transactions::API
  include DynamicAttributes
  extend Dry::Container::Mixin

  class_attr :model
  class_attr :policy
  class_attr :json_builder
  class_attr :find_by_key

  schema do
    params do
      required(:id).filled
    end
  end
  step :find_builder
  step :find_model
  step :render

  def find_builder(context, params:, **)
    route = Drawer::Router[params[:route]]&.first
    unless route.present?
      return on_error context, :route, 'not found'
    end

    context[:builder] = route.klass
    true
  end

  def find_model(context, params:, current_user:, **)
    find_key = context[builder].find_by_key
    context['model'] = context['result.model'] = context[:builder].model.where(id: params[:id])
    context['model'].present?
  end

  def authorize!(context, model:, current_user:, **)
    policy = context[:builder].policy&.new(current_user, model)
    if policy.present? and not policy.send(context[:builder].policy_action)
      context[:'result.authorization'] = Failure(message: 'Breach')
      return false
    end

    true
  end

  def render(context, params:, current_user:, **)
    context['result'] = context[:builder].build(current_user,context['model'])
    true
  end

  end