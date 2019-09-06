class Forms::Definitions::Types::DropdownType < Forms::Definitions::Property

  field_type :dropdown
  hint 'Select item'
  attributes(
      {
          choices: [],
          data_url: {
              model: nil,
              filter: nil
          },
      }
  )

end