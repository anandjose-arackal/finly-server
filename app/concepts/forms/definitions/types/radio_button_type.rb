class Forms::Definitions::Types::RadioButtonType < Forms::Definitions::Property

  allowed_filters %i(
    eq
    not_eq
    matches
    does_not_match
    matches_any
    does_not_match_any
  )

  def field_type
    :radio_button
  end

end