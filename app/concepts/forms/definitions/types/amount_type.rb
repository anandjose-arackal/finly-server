class Forms::Definitions::Types::AmountType < Forms::Definitions::Property

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

  def initialize(section, parent, key, options = {}, &block)
    options[:populate_if_empty] = Amount
    new_block = Proc.new {
      integer :value, editable: true, validates: {presence: true, numericality: {greater_than_or_equal_to: 0}}
      string :currency, required: true, editable: true, validates: {presence: true}

      validate
    }
    super(section, parent, key, options, &new_block)
  end

  def field_type
    :amount
  end

  def placeholder
    'Enter amount'
  end

end