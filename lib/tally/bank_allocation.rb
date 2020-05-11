class Tally::BankAllocation < NonPersistentModel
  attr_accessor :name, :date, :transaction_type, :payment_mode, :party_name, :utr, :instrument_date
  attr_writer :amount

  validates_presence_of :name, :date, :party_name

  def amount
    @amount ||= 0
  end

  def add(value)
    self.amount += value&.to_f&.round(2)
  end

  def as_json(options = {})
    Tally::Utils.format(
        {
            name: name,
            date: date,
            instrumentdate: (instrument_date || date),
            uniquereferencenumber: utr,
            transaction_type: transaction_type,
            payment_mode: payment_mode,
            party_name: party_name,
            amount: amount
        }
    )
  end

end