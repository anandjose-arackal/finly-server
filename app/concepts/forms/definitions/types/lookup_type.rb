class Forms::Definitions::Types::LookupType < Forms::Definitions::Property

  field_type :lookup
  hint 'Enter value'
  attributes(
      {
          data_url: {
              model: nil,
              filter: nil
          }
      }
  )

end