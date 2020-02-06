class Forms::DSL::Entity::Types::Formula < Forms::DSL::Entity::Base
  register :formula
  hint 'Auto-Generated'
  editable false
  can_editable_be_changed false

  consumes_choices!
end