class Forms::API::Entity::Types::RadioButton < Forms::API::Entity::Base
  register :radio_button
  hint 'Select option'

  consumes_choices!
end