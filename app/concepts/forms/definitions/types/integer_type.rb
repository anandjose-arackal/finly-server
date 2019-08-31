class Forms::Definitions::Types::IntegerType < Forms::Definitions::Property

  allowed_filters %i(
    eq
    not_eq
    matches
    lt
    lteq
    gt
    gteq
    present
    blank
  )

  def field_type
    :integer
  end

  def placeholder
    "Enter value"
  end

end