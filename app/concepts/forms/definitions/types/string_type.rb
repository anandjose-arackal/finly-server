class Forms::Definitions::Types::StringType < Forms::Definitions::Property

  field_type :string
  hint 'Enter value'
  consumes_regex!
  attributes(
      {
          char_limit: 255
      }
  )

end