class Forms::Definitions::Types::TextType < Forms::Definitions::Property

  field_type :text
  hint 'Enter value'
  consumes_regex!
  attributes(
      {
          char_limit: 1000
      }
  )

end