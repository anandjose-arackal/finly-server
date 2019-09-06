class Forms::Definitions::Types::CheckboxType < Forms::Definitions::Property

  field_type :checkbox
  attributes(
      {
          choices: []
      }
  )
  options(
      {
        min_items: 1,
        max_items: 5
      }
  )

end