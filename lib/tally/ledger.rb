class Tally::Ledger < NonPersistentModel
  attr_accessor :name
  attr_writer :is_party_ledger, :amount

  validates_presence_of :name, :amount
  validate :bill_allocations_validate
  validate :cost_allocations_validate
  validate :bank_allocations_validate

  def amount
    @amount ||= 0
  end

  def is_party_ledger
    @is_party_ledger ||= false
  end

  def bill_allocations
    @bill_allocations ||= []
  end

  def category_allocations
    @category_allocations ||= []
  end

  def bank_allocations
    @bank_allocations ||= []
  end

  def add(value)
    self.amount += value
  end

  def find_bill_allocation(name)
    bill_allocations.find {|bill_allocation| bill_allocation.name == name}
  end

  def find_bank_allocation(name)
    bank_allocations.find {|bank_allocation| bank_allocation.name == name}
  end

  def find_category_allocation(name)
    bank_allocations.find {|category_allocation| category_allocation.name == name}
  end

  def add_bill_allocation(name, type, amount)
    bill_allocation = find_bill_allocation name
    if bill_allocation.nil?
      bill_allocation = Tally::BillAllocation.new(name: name, type: type)
      bill_allocations << bill_allocation
    end
    bill_allocation.add amount
  end

  def add_category_allocation(name, cost_center, amount)
    category_allocation = find_category_allocation name
    if category_allocation.nil?
      category_allocation = Tally::CategoryAllocation.new(name: name)
      category_allocations << category_allocation
    end
    category_allocation.add cost_center, amount
  end

  def add_bank_allocation(name, date, transaction_type, payment_mode, party_name, amount)
    bank_allocation = find_bank_allocation name
    if bank_allocation.nil?
      bank_allocation = Tally::BankAllocation.new(
          name: name,
          date: date,
          transaction_type: transaction_type,
          payment_mode: payment_mode,
          party_name: party_name
      )
      bank_allocations << bank_allocation
    end
    bank_allocation.add amount
  end

  def as_json(options)
    Tally::Utils.format(
        {
            "ledgername": self.name,
            "isdeemedpositive": Tally::Utils.is_deemed_positive?(self.amount),
            "ispartyledger": Tally::Utils.to_bool(self.is_party_ledger),
            "amount": self.amount,
            "billallocations.list": self.bill_allocations.as_json(options),
            "categoryallocations.list": self.category_allocations.as_json(options),
            "bankallocations.list": self.bank_allocations.as_json(options)
        }
    )
  end

  protected

  def bill_allocations_validate
    self.bill_allocations.each do |bill_allocation|
      unless bill_allocation.valid?
        bill_allocation.errors.full_messages.each do |message|
          errors.add :bill_allocation, message
        end
      end
    end
  end

  def cost_allocations_validate
    self.category_allocations.each do |category_allocation|
      unless category_allocation.valid?
        category_allocation.errors.full_messages.each do |message|
          errors.add :category_allocation, message
        end
      end
    end
  end

  def bank_allocations_validate
    self.bank_allocations.each do |bank_allocation|
      unless bank_allocation.valid?
        bank_allocation.errors.full_messages.each do |message|
          errors.add :bank_allocation, message
        end
      end
    end
  end

end