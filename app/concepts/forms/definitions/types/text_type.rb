class Forms::Definitions::Types::TextType < Forms::Definitions::Property

  field_type :text
  hint 'Enter value'
  attributes(
      {
          regex: nil,
          char_limit: 1000
      }
  )

end