class AccountManager::Cards::CardAdapter < AccountManager::BaseAdapter

  def account_class
    Card
  end

  def credit(payment, options)
    super
    # Since this function debits ItzCashCompanyAccount, create 2 transactions, one for company account and other for card
    company_balance = nil
    company_adapter = nil
    if payment.initiating_account.class.name == ItzCashCompanyAccount.name
      company_adapter = AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(payment.initiating_account)
    end
    if payment.receiving_account.class.name == ItzCashCompanyAccount.name
      company_adapter = AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(payment.receiving_account)
    end
    if company_adapter.present?
      company_balance = company_adapter.balance
    end

    # operation that credits a particular card
    opening_balance = balance
    op = ItzCash::Credit.(account.user, {card: account, amount: payment.amount_value})
    unless op.success?
      # retry no. 1
      op = ItzCash::Credit.(account.user, {card: account, amount: payment.amount_value})
      unless op.success?
        # retry no. 2
        op = ItzCash::Credit.(account.user, {card: account, amount: payment.amount_value})
        unless op.success?
          self.errors = op.messages[:error]
          closing_balance = balance
          store_transaction payment, :credit, :failure, opening_balance, closing_balance, account.user.company_id, op.messages
          return false
        end
      end
    end

    closing_balance = balance
    store_transaction payment, :credit, :success, opening_balance, closing_balance, account.user.company_id

    if company_adapter.present?
      closing_company_balance = company_adapter.balance
      company_adapter.store_transaction payment, :debit, :success, company_balance, closing_company_balance, company_adapter.account.id
    end
    true
  end

  def debit(payment, options)
    super
    # Since this function debits ItzCashCompanyAccount, create 2 transactions, one for company account and other for card
    company_balance = nil
    company_adapter = nil
    if payment.initiating_account.class.name == ItzCashCompanyAccount.name
      company_adapter = AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(payment.initiating_account)
    end
    if payment.receiving_account.class.name == ItzCashCompanyAccount.name
      company_adapter = AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(payment.receiving_account)
    end
    if company_adapter.present?
      company_balance = company_adapter.balance
    end

    opening_balance = balance
    # operation that debits a particular card
    op = ItzCash::Debit.(account.user, {card: account, amount: payment.amount_value})
    unless op.success?
      # retry no. 1
      op = ItzCash::Debit.(account.user, {card: account, amount: payment.amount_value})
      unless op.success?
        # retry no. 2
        op = ItzCash::Debit.(account.user, {card: account, amount: payment.amount_value})
        unless op.success?
          self.errors = op.messages[:error]
          closing_balance = balance
          store_transaction payment, :debit, :failure, opening_balance, closing_balance, account.user.company_id, op.messages
          return false
        end
      end
    end
    closing_balance = balance
    store_transaction payment, :debit, :success, opening_balance, closing_balance, account.user.company_id

    if company_adapter.present?
      closing_company_balance = company_adapter.balance
      company_adapter.store_transaction payment, :credit, :success, company_balance, closing_company_balance, company_adapter.account.id
    end

    true
  end

  def balance(options = {})
    op = ItzCash::AccountDetails.(account.user, card: account)
    op.balance rescue 0
  end

  def creditable_accounts
    [Card, UserWallet, ItzCashCompanyAccount]
  end

  def debitable_accounts
    [Card, UserWallet, ItzCashCompanyAccount]
  end

  def eligibility(amount)
    return true
    # credit_eligibility >= amount
  end

  def credit_eligibility
    op = ItzCash::AccountDetails.(account.user, card: account)
    op.available_card_eligibility rescue 0
  end


  def on_completion(options)
    payment = options[:payment]
    if PaymentPurpose.ids_for(:medical_benefit, :meal_benefit).include?(payment&.payment_purpose_id)
      if payment.credit?
        Event::EWallet::Credit.(payment.initiating_user, payment: payment)
      elsif payment.debit?
        Event::EWallet::Debit.(payment.initiating_user, payment: payment)
      end
    end
  end

end