# assuming I get bunch of payments object that need to be processed
# in a payment_order object

class Payment::PaymentProcessor < BaseOperation

  attr_accessor :payment, :payment_item, :receiving_account_adapter, :source_account_adapter

  def init
    self.payment = params[:payment]
    self.receiving_account_adapter = retrieve_adapter(payment_item.receiving_account_type)
    self.source_account_adapter = retrieve_adapter(payment_item.initiating_account_type)
  end

  def validate
    unless receiving_account_adapter.creditable_accounts.include?(payment_item.initiating_account_type)
      add_message :error, "You cannot credit from this account"
      return
    end

    unless source_account_adapter.debitable_accounts.include?(payment_item.receiving_account_type)
      add_message :error, "You cannot debit to this account"
      return
    end

    unless source_account_adapter.balance(payment_item.initiating_account_id) > payment.amount_value
      add_message :error, "This account does not have enough balance for this"
      return
    end

    unless source_account_adapter.eligibility(payment_item.receiving_account_id) > payment.amount_value
      add_message :error, "This account does not have the eligibility for this"
    end
  end

  def process
    if source_account_adapter.credit(payment_item.amount.value)
      receiving_account_adapter.debit(payment_item.amount.value)
    else
      source_account_adapter.debit(payment_item.amount.value)
    end
  end

  def post_process
    # create a payment out of the repective transaction above
    # add success message
  end

  private

  def retrieve_adapter(account_type)
    case account_type
      when 1, :card
        # Card, for example
        return Payments::CardAdapter.new
      when 2, :wallet
        # Wallet for example
        return Payments::WalletAdapter.new
    end
  end

end