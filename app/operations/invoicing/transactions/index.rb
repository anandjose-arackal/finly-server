class  Invoicing::Transactions::Index < Invoicing::Transactions::Base
  attr_accessor :incoming_payments, :virtual_bank_accounts

  def init
    virtual_account_op = Invoicing::VirtualBankAccount::Index.(user, params)

    if virtual_account_op.success?
      self.virtual_bank_accounts = virtual_account_op.virtual_bank_accounts
    else
      add_message :error, virtual_account_op.errors.full_messages
    end
  end

  def validate

  end

  def process
    self.incoming_payments = Payment.with_initiating_account(self.virtual_bank_accounts)
  end

  def success
    params[:incoming_payments] = self.incoming_payments
    Invoicing::Transactions::Index::IndexPresenter.new(user, params, messages)
  end

  class Invoicing::Transactions::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :incoming_payments, :paginated_payments, :count

    has_scope :virtual_account_transaction_purpose
    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      self.incoming_payments = params[:incoming_payments]
      self.incoming_payments = apply_scopes(self.incoming_payments, params)
      self.paginated_payments = self.incoming_payments.paginate(page: params[:page], per_page: params[:per_page])
      self.count = self.incoming_payments.count
    end
  end
end