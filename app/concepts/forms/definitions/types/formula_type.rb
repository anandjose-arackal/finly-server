class Forms::Definitions::Types::FormulaType < Forms::Definitions::Property

  allowed_filters %i(
    eq
    not_eq
    matches
    does_not_match
    matches_any
    does_not_match_any
    lt
    lteq
    gt
    gteq
    present
    blank
    true
    false
  )

  def field_type
    :formula
  end

  def placeholder
    'Auto generated'
  end

end