class Forms::Definitions::Types::StringType < Forms::Definitions::Property

  allowed_filters %i(
    eq
    not_eq
    matches
    does_not_match
    matches_any
    does_not_match_any
  )

  def field_type
    :string
  end

  def placeholder
    'Enter value'
  end

end