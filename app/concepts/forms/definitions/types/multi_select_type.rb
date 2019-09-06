class Forms::Definitions::Types::MultiSelectType < Forms::Definitions::Property

  field_type :multi_select
  hint 'Select item'
  attributes(
      {
          choices: [],
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