class Forms::API::Entity::Types::Lookup < Forms::API::Entity::Base
  register :lookup
  hint 'Select value'

  consumes_choices!
end