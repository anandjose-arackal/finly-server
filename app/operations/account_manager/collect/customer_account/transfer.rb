class AccountManager::Collect::CustomerAccount::Transfer < AccountManager::Collect::Base
  attr_accessor :virtual_account_transaction,
                :virtual_account, :customer,
                :customer_account, :amount,
                :customer_account_transaction,
                :transaction_type, :invoice,
                :associated_object

  def init
    configuration_type = params[:type]

    case configuration_type
      when 'virtual_account_to_customer_account'
        self.virtual_account_transaction = params[:virtual_account_transaction]
        self.associated_object = self.virtual_account_transaction
        self.virtual_account = virtual_account_transaction.virtual_account
        self.customer = virtual_account.customer
        self.customer_account = customer.customer_account
        self.transaction_type = 'credit'
        self.amount = params[:amount].to_f
      when 'customer_account_to_invoice'
        self.invoice = params[:invoice]
        self.associated_object = self.invoice
        self.customer = self.invoice.customer
        self.customer_account = self.customer.customer_account
        self.transaction_type = 'debit'
        self.amount = 0 - params[:amount].to_f
      when 'invoice_to_customer_account'
        self.invoice = params[:invoice]
        self.associated_object = self.invoice
        self.customer = self.invoice.customer
        self.customer_account = self.customer.customer_account
        self.transaction_type = 'credit'
        self.amount = params[:amount].to_f
        # pulling money back from invoice
      when 'customer_account_to_customer'
        # reversal of money to customer
      else
        add_message :error, 'Invalid configuration type'
    end

  end

  def validate
    unless self.customer_account.is_a?(CustomerAccount)
      add_message :error, 'Customer Account not found'
    end

  end

  def process
    customer_account_balance = customer_account.balance.value.to_f
    if self.customer_account.balance.update(value: (customer_account_balance + self.amount))
      self.customer_account_transaction = customer_account.customer_account_transactions.create({
                                                               associated_object: associated_object,
                                                               transaction_type: transaction_type,
                                                               transaction_amount_attributes: {
                                                                   value: self.amount.abs,
                                                                   currency_id: 1 # todo change it later
                                                               }
                                                           })
    end
  end

  def success
    params[:customer_account_transaction] = self.customer_account_transaction
    AccountManager::Collect::CustomerAccount::Transfer::TransferPresenter.new(user, params)
  end

  class AccountManager::Collect::CustomerAccount::Transfer::TransferPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :customer_account_transaction

    def init

      self.customer_account_transaction = params[:customer_account_transaction]

    end
  end

end