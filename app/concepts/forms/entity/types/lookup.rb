class Forms::Entity::Types::Lookup < Forms::Entity::Base
  register :lookup
  hint 'Select value'

  consumes_choices!
end