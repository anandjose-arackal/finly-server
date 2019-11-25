class Forms::Definitions::Types::RadioButton < Forms::Definitions::Entity
  register :radio_button
  hint 'Select option'

  consumes_choices!
end