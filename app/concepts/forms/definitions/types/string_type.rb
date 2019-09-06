class Forms::Definitions::Types::StringType < Forms::Definitions::Property

  field_type :string
  hint 'Enter value'
  attributes(
      {
          regex: nil,
          char_limit: 255
      }
  )

end