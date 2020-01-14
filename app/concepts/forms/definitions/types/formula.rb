class Forms::Definitions::Types::Formula < Forms::Definitions::Entity
  register :formula
  hint 'Auto-Generated'
  editable false
  can_editable_be_changed false

  consumes_choices!
end