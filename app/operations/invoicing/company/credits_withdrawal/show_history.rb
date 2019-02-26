class Invoicing::Company::CreditsWithdrawal::ShowHistory < Invoicing::Company::Base

  attr_accessor :credit_payments, :collect_credit_account

  class Invoicing::Company::CreditsWithdrawal::ShowHistory::CreditHistoryPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :credit_payments

    def init
      self.credit_payments = params[:credit_payments]
    end

  end

  def init
    self.collect_credit_account = user.company.collect_credit_account
  end

  def process
    self.credit_payments = Payment.with_receiving_account(self.collect_credit_account).with_payment_purpose(PaymentPurpose.id_for(:collect_funds_withdrawal)).include_for_index
  end

  def success
    params[:credit_payments] = self.credit_payments
    Invoicing::Company::CreditsWithdrawal::ShowHistory::CreditHistoryPresenter.new(user, params, messages)
  end
end