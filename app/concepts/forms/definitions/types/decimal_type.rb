class Forms::Definitions::Types::DecimalType < Forms::Definitions::Property

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
    :decimal
  end

  def placeholder
    'Enter value'
  end

end