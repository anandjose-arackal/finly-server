class Forms::Definitions::Types::AmountType < Forms::Definitions::Property

  field_type :amount
  hint 'Enter amount'
  filters %i(
    lteq
    gteq
  )
  attributes(
      {
          min_amount: 0,
          max_amount: 200000000,
          multi_currency: false
      }
  )

  def initialize(section, parent, key, options = {}, &block)
    options[:populate_if_empty] = Amount
    new_block = Proc.new {
      integer :value, editable: true, validates: {presence: true, numericality: {greater_than_or_equal_to: 0}}
      string :currency, required: true, editable: true, validates: {presence: true}
    }
    super(section, parent, key, options, &new_block)
  end

end