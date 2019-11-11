class AccountManager::BbpsBiller::BbpsAccountsAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :company

  def account_class
    BbpsBiller
  end
  # this method will not do anyhing as this account can only be credited
  # nothing to do here ¯\_(ツ)_/¯
  def debit(payment, options = {})
    return true
  end

  # this method will consume YesBank's APIs so that they can fulfill our
  # BBPS billers. Have to understand the adapters to implement this
  def credit(payment, options = {})
    # first we determine if the associated payment to this particular transaction is is completed or not
    if payment.reference_resource.present? and !payment.reference_resource.retriable?  
      self.errors << "This bill payment cannot be processed at this time"
      return false
    end
    
    bank_transaction = create_bbps_bank_transaction(payment)

    params = {
      amount: bank_transaction.amount_value,
      bill_date: bank_transaction.bill_date,
      due_date: bank_transaction.due_date,
      bill_number: bank_transaction.bill_number,
      bill_period: bank_transaction.bill_period,
      biller_id: bank_transaction.biller_id
    }
    op = Bbps::BillPay.(params, "user" => payment.initiating_user)
    
  end

  # balance doesn't make sense here as there is no such thing defined for this particular account
  def balance
    return 0
  end

  private

  def create_bbps_bank_transaction(payment)
    bank_transaction = company.bbps_yes_bank_transactions.create(
      biller_id: payment.parent.subscription_id,
      transfer_status_id: BankTransferStatus.id_for(:opem),
      bill_date: payment.parent.bill_date,
      bill_period: payment.parent.bill_period,
      due_date: payment.parent.due_date,
      bill_number: payment.parent.bill_number,
      amount_attributes: {
          value: payment.amount_value,
          currency_id: Currency.first.id
    })
    bank_transaction.save
  end



end