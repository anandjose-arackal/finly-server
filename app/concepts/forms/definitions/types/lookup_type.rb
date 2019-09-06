class Forms::Definitions::Types::LookupType < Forms::Definitions::Property

  field_type :lookup
  hint 'Enter value'
  consumes_data_url!

end