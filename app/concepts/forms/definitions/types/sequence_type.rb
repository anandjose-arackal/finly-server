class Forms::Definitions::Types::SequenceType < Forms::Definitions::Property

  field_type :sequence
  hint 'Auto-generated'
  attributes(
      {
          override: true
      }
  )

  def initialize(section, parent, key, options = {}, &block)
    options[:populate_if_empty] = -> (fragment:) {
      if fragment.blank?

      end
      fragment
    }
    super(section, parent, key, options, &new_block)
  end


end