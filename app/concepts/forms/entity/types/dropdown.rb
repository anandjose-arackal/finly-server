class Forms::Entity::Types::DropDown < Forms::Entity::Base
  register :dropdown
  hint 'Select value'

  consumes_choices!

  option :min_choices
  option :max_choices

  contract do
    optional(:min_choices).value(:int?)
    optional(:max_choices).value(:int?)
  end
end