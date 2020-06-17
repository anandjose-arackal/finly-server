class Forms::API::Entity::Types::Formula < Forms::API::Entity::Base
  register :formula
  hint 'Auto-Generated'
  editable false
  can_editable_be_changed false

  consumes_choices!

  operators :eq_any, :not_eq_all, :blank, :present
end