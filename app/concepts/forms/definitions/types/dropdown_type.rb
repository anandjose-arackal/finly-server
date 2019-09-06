class Forms::Definitions::Types::DropdownType < Forms::Definitions::Property

  field_type :dropdown
  hint 'Select item'
  consumes_choices!
  consumes_data_url!

end