class Invoicing::VirtualBankAccount::Payments::Show < Invoicing::VirtualBankAccount::Base

  attr_accessor :payments, :virtual_bank_account

  class Invoicing::VirtualBankAccount::Payments::Show::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payments

    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      self.payments = params[:payments]
      self.payments = apply_scopes(self.payments, params)
    end
  end


  def init
    self.virtual_bank_account = params[:virtual_bank_account]
    if self.virtual_bank_account.blank?
      id = params[:id] || params[:virtual_bank_account_id]
      self.virtual_bank_account = user&.company.virtual_bank_accounts.find_by(id: id)
    end
  end

  def validate
    if self.virtual_bank_account.blank?
      add_message :error, "Virtual Bank Account not found"
    end
  end

  def process
    self.payments = Payment.with_initiating_account(self.virtual_bank_account).completed
  end

  def success
    params[:payments] = self.payments
    Invoicing::VirtualBankAccount::Payments::Show::PaymentsPresenter.new(user, params, messages)
  end

end