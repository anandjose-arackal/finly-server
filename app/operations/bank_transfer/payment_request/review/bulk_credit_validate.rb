class BankTransfer::PaymentRequest::Review::BulkCreditValidate < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_requests, :result, :processable_amount, :unprocessable_amount, :scheduled_amount,
                :initiating_account_adapter, :source_account_balance,
                :wallet_adapter, :company_credits_adapter

  class BankTransfer::PaymentRequest::Review::BulkCreditValidate::BulkCreditValidationPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :result, :processable_amount, :unprocessable_amount, :scheduled_amount, :source_account_balance,
                  :wallet_balance, :company_credits_balance

    def init
      self.result = params[:result]
      self.processable_amount = params[:processable_amount]
      self.unprocessable_amount = params[:unprocessable_amount]
      self.scheduled_amount = params[:scheduled_amount]
      self.source_account_balance = params[:source_account_balance]
      self.wallet_balance = params[:wallet_balance]
      self.company_credits_balance = params[:company_credits_balance]
    end

    def processable?
      self.source_account_balance >= (self.processable_amount + self.scheduled_amount)
    end

  end

  def init
    ids = params[:payment_request_ids]
    unless ids.is_a?(Array)
      ids = ids.split(",")
    end
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.payment_requests = op.payment_requests.with_id(ids)
    else
      add_message :error, op.messages[:error]
    end
    self.result = []
    self.processable_amount = self.unprocessable_amount = self.scheduled_amount = 0
    self.initiating_account_adapter = retrieve_initiating_account_adapter
    self.source_account_balance = self.initiating_account_adapter.balance
    self.wallet_adapter = AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
    self.company_credits_adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
  end

  def validate
    if self.payment_requests.empty?
      add_message :error, "No payment orders to process"
      return
    end

    # validating that the source account has enough balance for the above transaction

  end

  def process
    self.payment_requests.each do |payment_request|
      hash = {
          id: payment_request.id,
          name: payment_request.name,
          payment_request: payment_request,
          allowed: TransferTimingUtils.within_timeframe?(payment_request.payment_order.payment_mode, nil) ,
          next_date: TransferTimingUtils.next_valid_date(nil, payment_request.payment_order.payment_mode),
          total_amount: payment_request.payment_order.amount_requested&.value,
          created_at: payment_request.created_at.strftime("%d-%m-%Y"),
          selectable: true,
          payment_mode: payment_request.payment_mode
      }
      errors = []
      if payment_request.credit_card?
        self.unprocessable_amount += payment_request.payment_order.amount_requested&.value
        errors << "Credit Card payments cannot be processed from this screen. You can mark them as credited from the Payment Orders screen"
        hash[:allowed] = false
        hash[:selectable] = false
      else
        # check if the payment request can be credited by the selecting user
        # if (payment_request.controlling_user_id == user.id) || (user.vendor_payments_admin? && payment_request.approved?)
        if (payment_request.get_reviewers.include?(user)) || (user.vendor_payments_admin? && payment_request.approved?) || (user.vendor_payments_creditor? && payment_request.document_role_users(:creditor).include?(user) && payment_request.approved?)
          if hash[:allowed]
            self.processable_amount += payment_request.payment_order.amount_requested&.value
          else
            errors << "#{payment_request.payment_mode} transfers are outside the bank transfer window for today. You can either change the transfer type to IMPS and try again or proceed and we will schedule the payment for the next transfer window"
            errors << "Next available window for this order starts at: 8:00 AM on #{hash[:next_date].strftime("%d %B, %Y")}"
            self.scheduled_amount += payment_request.payment_order.amount_requested&.value
          end
        else
          errors << "You can only credit payment orders which are awaiting your approval or have already been approved"
          hash[:selectable] = false
          self.unprocessable_amount += payment_request.payment_order.amount_requested&.value
        end

        if self.user.vendor_payments_creditor? && !self.user.vendor_payments_admin?
          minimum = payment_request.policy.policy_user_roles.with_user_id(self.user).with_role_id(UserRole.id_for(:creditor)).first.min_amount
          maximum = payment_request.policy.policy_user_roles.with_user_id(self.user).with_role_id(UserRole.id_for(:creditor)).first.max_amount || 999999999999999999999999
          if payment_request.payments.joins(:amount).sum(:value) > maximum
            hash[:selectable] = false
            self.unprocessable_amount += payment_request.payment_order.amount_requested&.value
            errors << "You are not eligible to credit the payment order, you are eligible to credit only upto #{maximum}"
          elsif payment_request.payments.joins(:amount).sum(:value) < minimum
            hash[:selectable] = false
            self.unprocessable_amount += payment_request.payment_order.amount_requested&.value
            errors << "You are not eligible to credit the payment order, you are eligible to credit only greater than #{minimum}"
          end
        end
      end

      hash[:errors] = errors
      self.result << hash
    end
  end

  def post_process
    # sorting the payment orders as creditable, schedulable, and non-creditable
    creditable_orders = []
    schedulable_orders = []
    non_creditable_orders = []
    self.result.each do |order|
      if order[:selectable]
        if order[:allowed]
          creditable_orders << order
        else
          schedulable_orders << order
        end
      else
        non_creditable_orders << order
      end
    end
    self.result = creditable_orders + schedulable_orders + non_creditable_orders
  end

  def success
    params[:result] = self.result
    params[:processable_amount] = self.processable_amount
    params[:unprocessable_amount] = self.unprocessable_amount
    params[:scheduled_amount] = self.scheduled_amount
    params[:source_account_balance] = self.source_account_balance
    params[:wallet_balance] = self.wallet_adapter.balance
    params[:company_credits_balance] = self.company_credits_adapter.balance
    BankTransfer::PaymentRequest::Review::BulkCreditValidate::BulkCreditValidationPresenter.new(user, params, messages)
  end

  private

  def retrieve_initiating_account_adapter
    case params[:initiating_account_type]
      when 1, '1'
        return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
      when 2, '2'
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
      else
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
    end
  end

end