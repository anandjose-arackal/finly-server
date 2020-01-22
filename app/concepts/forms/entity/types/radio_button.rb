class Forms::Entity::Types::RadioButton < Forms::Entity::Base
  register :radio_button
  hint 'Select option'

  consumes_choices!
end