class Forms::Definitions::Types::DateType < Forms::Definitions::Property

  allowed_filters %i(
    eq
    not_eq
    lt
    lteq
    gt
    gteq
    present
    blank
  )

  def field_type
    :date
  end

  def placeholder
    'Select Date'
  end

end