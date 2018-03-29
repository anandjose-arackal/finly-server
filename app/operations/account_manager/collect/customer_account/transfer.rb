class AccountManager::Collect::CustomerAccount::Transfer < AccountManager::Collect::Base
  attr_accessor :customer, :customer_account, :amount, :customer_account_transaction

  def init

  end

  def validate

  end

  def process
    customer_account_balance = customer_account.balance.value
    if self.customer_account.balance.update(value: (customer_account_balance + self.amount))
      customer_account.customer_account_transactions.create({
                                                               virtual_account_transaction_id: virtual_account_transaction_id,
                                                               transaction_type: 'credit',
                                                           })
    end

  end

end