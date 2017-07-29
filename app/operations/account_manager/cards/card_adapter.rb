class AccountManager::Cards::CardAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :card

  def initialize(source_id)
    init(source_id)
  end

  def init(source_id)
    self.card = Card.find_by(id: source_id)
    self.errors = []
  end

  def name
    "Card"
  end

  def credit(payment)
    # operation that credits a particular card
    op = ItzCash::Credit.(card.user, {card: card, amount: payment.amount_value})
    unless op.success?
      self.errors = op.messages[:error]
      return false
    end
    true
  end

  def debit(payment)
    # operation that debits a particular card
    op = ItzCash::Debit.(card.user, {card: card, amount: payment.amount_value})
    unless op.success?
      self.errors = op.messages[:error]
      return false
    end
    true
  end

  def balance
    op = ItzCash::AccountDetails.(card.user, card: card)
    balance = op.balance
  end

  def creditable_accounts
    [Card, "Card", UserWallet, "UserWallet", CompanyBalance, "Company"]
  end

  def debitable_accounts
    [Card, "Card", UserWallet, "UserWallet", CompanyBalance, "Company"]
  end

  def eligibility(amount)
    # checks if the particular card can be credited with so and so amount

  end
end