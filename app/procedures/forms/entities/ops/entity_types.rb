class Forms::Entities::Ops::EntityTypes < Transactions::API

  step Policy::Pundit(Forms::Entities::Policy, :get_entity_types?)

  step :retrieve_types

  def retrieve_types(options, params:, **)
    options['model.types'] = Forms::Entity::Registry.types
  end
end