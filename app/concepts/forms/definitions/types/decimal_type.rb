class Forms::Definitions::Types::DecimalType < Forms::Definitions::Property

  field_type :decimal
  hint 'Enter value'
  filters %i(
    lteq
    gteq
  )
  attributes(
      {
          min_value: nil,
          max_value: nil
      }
  )

end