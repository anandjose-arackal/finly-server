class Invoicing::VirtualBankAccount::Base < BaseOperation

  attr_accessor :virtual_bank_account

  class Invoicing::VirtualBankAccount::Base::VirtualAccountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :virtual_bank_account, :company, :total_transaction_count, :total_transaction_amount

    def init
      self.virtual_bank_account = params[:virtual_bank_account]
      self.company = virtual_bank_account.company
      op = Invoicing::VirtualBankAccount::Payments::Show.(user, virtual_bank_account_id: self.virtual_bank_account.id)
      self.total_transaction_count = op.payments.count
      self.total_transaction_amount = op.payments.sum_amounts
    end

  end

  def init
    id = params[:id] || params[:virtual_bank_account_id]
    op = Invoicing::VirtualBankAccount::Index.(user, params)
    self.virtual_bank_account = op.virtual_bank_accounts.find_by(id: id)
  end

end