class Tally::Voucher < NonPersistentModel
  attr_accessor :voucher_type, :date, :effective_date, :reference_date, :voucher_number, :state, :gl_name, :gstin, :narration, :reference

  validates_presence_of :voucher_type, :date, :gl_name
  validate :zero_sum_ledgers
  validate :ledgers_validation

  def find_ledger(name)
    ledgers.find { |ledger| ledger.name == name }
  end

  def ledgers
    @ledgers ||= []
  end

  def add(name, amount, is_party_ledger: false, bill_allocations: [], category_allocations: [], bank_allocations: [])
    ledger = find_ledger(name)
    if ledger.nil?
      ledger = Tally::Ledger.new(name: name, is_party_ledger: is_party_ledger)
      ledgers << ledger
    end
    ledger.add amount
    bill_allocations&.each do |allocation|
      allocation_amount = allocation[:amount] || 0
      ledger.add_bill_allocation allocation[:name], allocation[:type], -allocation_amount
    end
    category_allocations&.each do |allocation|
      allocation_amount = allocation[:amount] || 0
      ledger.add_category_allocation allocation[:name], allocation[:cost_center], -allocation_amount
    end
    bank_allocations&.each do |allocation|
      allocation[:amount] ||= 0
      allocation[:amount] = allocation[:amount].to_f
      ledger.add_bank_allocation allocation
    end
  end

  def as_json(options = {})
    debugger
    Tally::Utils.format(
        {
            'voucher': {
                "date": Tally::Utils.to_date(self.date),
                "referencedate": Tally::Utils.to_date((self.reference_date || self.date)),
                "statename": self.state,
                "narration": self.narration,
                "countryofresidence": "India",
                "reference": self.reference,
                "vouchernumber": self.voucher_number,
                "partygstin": self.gstin,
                "partyname": self.gl_name,
                "vouchertypename": self.voucher_type,
                "partyledgername": self.gl_name,
                "basicbasepartyname": self.gl_name,
                "effectivedate": Tally::Utils.to_date((self.effective_date || self.date)),
                "allledgerentries.list": self.ledgers.as_json(options)
            }, attributes!: {
            'voucher':
                {
                    "remoteid": "",
                    "vchkey": "",
                    "vchtype": self.voucher_type,
                    "action": "Create"
                }
        }
        }
    )
  end

  protected

  def zero_sum_ledgers
    sum = 0
    self.ledgers.each do |ledger|
      sum += ledger.amount
    end

    errors.add :base, "Sum of ledgers is not zero. Sum : #{sum}" unless sum.to_f.round(2) == 0
  end

  def ledgers_validation
    self.ledgers.each do |ledger|
      unless ledger.valid?
        ledger.errors.full_messages.each do |message|
          errors.add :ledger, message
        end
      end
    end
  end


end