class HoverCard::API < Transactions::API
  include DynamicAttributes
  extend Dry::Container::Mixin

  class_attr :model
  class_attr :policy
  class_attr :policy_action
  class_attr :json_builder

  schema do
    params do
      required(:id).filled
    end
  end

  step :find_model
  step :authorize!
  step :render

  def find_model(context, params:, current_user:, **)
    context['model'] = context['result.model'] = self.class.model.find_by(id: params[:id])
    context['model'].present?
  end

  def authorize!(context, model:, current_user:, **)
    policy = self.class.policy&.new(current_user, model)
    if policy.present? and not policy.send(self.class.policy_action)
      context[:'result.authorization'] = Failure(message: 'Breach')
    end

    true
  end

  def render(context, options)
    context['data'] = render_record(context, **options)

    true
  end

  def render_record(context, model:, **)
    raise "JSON Builder is not defined for #{self.class.name}" unless json_builder.present?

    if json_builder[:block]
      json_builder[:block].call(context, model)
    elsif json_builder[:args]
      json = {}
      json_builder[:args].each do |attribute|
        json[attribute] = model.send(attribute)
      end
      json
    end

  end

  def self.json(*args, &block)
    json_builder({args: args, block: block})
  end

  def json_builder
    self.class.json_builder
  end

end