class Forms::Definitions::Types::MultiSelectType < Forms::Definitions::Property

  field_type :multi_select
  hint 'Select item'
  consumes_choices!
  consumes_data_url!
  attributes(
      {
          min_items: 1,
          max_items: 25,
          mode: 1
      }
  )

end