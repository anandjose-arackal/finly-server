class Forms::Definitions::Types::SequenceType < Forms::Definitions::Property

  allowed_filters %i(
    eq
    not_eq
    matches
    does_not_match
    matches_any
    does_not_match_any
  )

  def initialize(section, parent, key, options = {}, &block)
    options[:populate_if_empty] = -> (fragment:) {
      if fragment.blank?

      end
      fragment
    }
    super(section, parent, key, options, &new_block)
  end

  def field_type
    :sequence
  end

  def placeholder
    'Auto-generated'
  end

end