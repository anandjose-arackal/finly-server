class Forms::API::Entity::Types::RadioButton < Forms::API::Entity::Base
  register :radio_button
  hint 'Select option'

  consumes_choices!

  operators operators :eq_any, :blank, :present
end