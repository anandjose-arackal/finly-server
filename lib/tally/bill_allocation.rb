class Tally::BillAllocation < NonPersistentModel
  attr_accessor :name, :type
  attr_writer :amount

  validates_presence_of :name, :type

  def amount
    @amount ||= 0
  end

  def add(value)
    self.amount += value&.to_f&.round(2)
  end

  def as_json(options = {})
    Tally::Utils.format(
        {
            "name": self.name,
            "billtype": self.type,
            "amount": self.amount
        }
    )
  end

end