# this operation will take a payment order id and return whether the particular order can
# be processed at the current time or not - can return a flag, or the actual timings as well

class BankTransfer::Configuration::TransferTimings < BankTransfer::Configuration::Base

  attr_accessor :timings, :payment_order, :payment_request, :payment_mode, :date, :bank_accounts

  class BankTransfer::Configuration::TransferTimings::TimingsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :timings, :allowed, :next_valid_date, :bank_accounts

    def init
      self.bank_accounts = []
      self.allowed = params[:allowed]
      self.timings = params[:timings]
      self.next_valid_date = params[:next_date]

      bank_accounts_op = AccountManager::CompanyBankAccounts::Index.(user, {balance: true}) rescue nil

      if bank_accounts_op&.success?
        self.bank_accounts = bank_accounts_op.bank_accounts
      end
    end
  end

  def pre_validate
  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    if id.present?
      init_bank_payment_request(id)
    else
      self.payment_mode = params[:payment_mode]
      self.date = params[:date]
    end

    self.bank_accounts = []
  end

  def validate
    id = params[:id] || params[:bank_payment_request_id]
    if id.present? and self.payment_request.blank? and self.payment_order.blank?
      add_message :error, 'Payment order not found'
      return
    end
    if self.payment_mode.blank?
      add_message :error, 'Payment mode cannot be blank'
      return
    end
  end

  def success
    params[:allowed] = TransferTimingUtils.within_timeframe?(self.payment_mode, self.date)
    params[:next_date] = TransferTimingUtils.next_valid_date(self.date, self.payment_mode)
    BankTransfer::Configuration::TransferTimings::TimingsPresenter.new(user, params, messages)
  end

  protected

  def init_bank_payment_request(id)
    self.payment_request = BankPaymentRequest.find_by(id: id)
    self.payment_order = payment_request&.payment_order
    self.date = payment_order&.scheduled_at
    self.payment_mode = payment_order&.payment_mode
  end

end