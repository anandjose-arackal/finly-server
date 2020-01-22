class Forms::Entity::Types::Formula < Forms::Entity::Base
  register :formula
  hint 'Auto-Generated'
  editable false
  can_editable_be_changed false

  consumes_choices!
end