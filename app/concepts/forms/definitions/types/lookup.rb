class Forms::Definitions::Types::Lookup < Forms::Definitions::Entity
  register :lookup
  hint 'Select value'

  consumes_choices!
end