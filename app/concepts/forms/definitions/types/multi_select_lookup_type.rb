class Forms::Definitions::Types::MultiSelectLookupType < Forms::Definitions::Property

  field_type :lookup
  hint 'Enter value'
  attributes(
      {
          data_url: {
              model: nil,
              filter: nil
          },
          min_items: 1,
          max_items: 25,
          mode: 1
      }
  )

end