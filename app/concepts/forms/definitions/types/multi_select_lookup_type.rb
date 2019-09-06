class Forms::Definitions::Types::MultiSelectLookupType < Forms::Definitions::Property

  field_type :lookup
  hint 'Enter value'
  consumes_data_url!
  attributes(
      {
          min_items: 1,
          max_items: 25,
          mode: 1
      }
  )

end