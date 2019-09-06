class Forms::Definitions::Types::IntegerType < Forms::Definitions::Property

  field_type :integer
  hint "Enter value"
  filters %i(
    lteq
    gteq
  )


end