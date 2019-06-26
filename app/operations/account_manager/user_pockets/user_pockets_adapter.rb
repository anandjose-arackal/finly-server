class AccountManager::UserPockets::UserPocketsAdapter < AccountManager::BaseAdapter

  attr_accessor :pockets_adapter

  def account_class
    UserPocket
  end

  def initialize(account = nil, payment = nil)
    super(account)
    case self.account.user_pocket_type_id
      when UserPocketType.id_for(:cash)
        self.pockets_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(self.account)
      when UserPocketType.id_for(:reimbursement)
        self.pockets_adapter = AccountManager::ReimbursementPockets::ReimbursementPocketsAdapter.new(self.account)
      when UserPocketType.id_for(:paid_by_company)
        self.pockets_adapter = AccountManager::PaidByCompanyPockets::PaidByCompanyPocketsAdapter.new(self.account)
      when UserPocketType.id_for(:credit_card)
        self.pockets_adapter = AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(self.account)
      else
        # nothing to do here
    end
  end
end