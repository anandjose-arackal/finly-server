class AccountManager::UserPockets::UserPocketsAdapter < AccountManager::BaseAdapter

  def initialize(account = nil)
    super(account)
    case self.account.user_pocket_type_id
      when UserPocketType.id_for(:cash)
        return AccountManager::CashPockets::CashPocketsAdapter.new(self.account)
      when UserPocketType.id_for(:reimbursement)
        return AccountManager::ReimbursementPockets::ReimbursementPocketsAdapter.new(self.pocket)
      when UserPocketType.id_for(:paid_by_company)
        return AccountManager::PaidByCompanyPockets::PaidByCompanyPocketsAdapter.new(self.account)
      when UserPocketType.id_for(:credit_card)
        return AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(self.account)
      else
        # nothing to do here
    end
  end
end