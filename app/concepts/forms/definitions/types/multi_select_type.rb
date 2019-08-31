class Forms::Definitions::Types::MultiSelectType < Forms::Definitions::Property

  allowed_filters %i(
    eq
    not_eq
    matches
    does_not_match
    matches_any
    does_not_match_any
  )

  def field_type
    :multi_select
  end

  def placeholder
    'Select item'
  end

  def default_options
    {
        can_editable_be_changed: true,
        can_required_be_changed: true,
        can_uniqueness_be_changed: true,
        can_label_be_renamed: true,
        can_not_be_hidden: false,
    }
  end

end