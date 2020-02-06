class Forms::DSL::Entity::Types::Lookup < Forms::DSL::Entity::Base
  register :lookup
  hint 'Select value'

  consumes_choices!
end