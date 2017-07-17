class Payments::CardAdapter < Payments::BaseAdapter

  attr_accessor :card

  def init(source_id)
    self.card = Card.find_by(id: source_id)
  end

  def credit(source_id, amount)
    # operation that credits a particular card
    init(source_id)
    ItzCash::Credit.(source.user, {card: source, amount: amount})
  end

  def debit(source_id, amount)
    # operation that debits a particular card
    init(source_id)
    ItzCash::Credit.(source.user, {card: source, amount: amount})
  end

  def balance(source_id)
    init(source_id)
    op = ItzCash::AccountDetails.(card.user, card: card)
    balance = op.balance
  end

  def creditable_accounts
    [Card, UserWallet, CompanyBalance]
  end

  def debitable_accounts
    [Card, UserWallet, CompanyBalance]
  end

  def eligibility(source_id)

  end
end