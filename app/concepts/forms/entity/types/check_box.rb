class Forms::Entity::Types::CheckBox < Forms::Entity::Base
  register :checkbox
  hint 'Select option'
  multiple true

  consumes_choices!

  option :min_choices
  option :max_choices

  contract do
    optional(:min_choices).value(:int?)
    optional(:max_choices).value(:int?)
  end
end