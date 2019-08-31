class Forms::Definitions::Types::DropdownType < Forms::Definitions::Property

  allowed_filters %i(
    eq
    not_eq
    matches
    does_not_match
    matches_any
    does_not_match_any
  )

  def field_type
    :dropdown
  end

  def placeholder
    'Select item'
  end

end