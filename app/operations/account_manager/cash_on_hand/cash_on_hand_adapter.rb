class AccountManager::CashOnHand::CashOnHandAdapter < AccountManager::BaseAdapter

  attr_accessor :cash_on_hand

  def initialize(source_id)
    # source is the source from where the credit / debit is supposed to happen
    # params is general, can be anything
    init(source_id)
  end

  def name
    "Cash On Hand"
  end

  def credit(payment)
    if self.cash_on_hand.credit_funds(payment.amount_value)
      return true
    end
    self.errors = cash_on_hand.errors.full_messages
    false
  end

  def debit(payment)
    if self.cash_on_hand.debit_funds(payment.amount_value)
      return true
    end
    self.errors = cash_on_hand.errors.full_messages
    false
  end

  def balance
    self.cash_on_hand.balance_value
  end

  def eligibility(source_id)

  end

  def creditable_accounts
    ["OutsideFinly"]
  end

  def debitable_accounts
    ["OutsideFinly"]
  end

  def init(source_id)
    # method that retrieves the correct account to transact with
    self.cash_on_hand = CashOnHand.find_by(id: source_id)
  end

end

