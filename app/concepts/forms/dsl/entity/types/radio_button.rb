class Forms::DSL::Entity::Types::RadioButton < Forms::DSL::Entity::Base
  register :radio_button
  hint 'Select option'

  consumes_choices!
end