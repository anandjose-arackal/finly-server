class BankTransfer::PaymentRequest::Update::UpdatePayments < BankTransfer::PaymentRequest::Update::Base

  attr_accessor :order_params, :requested_total

  def pre_validate
    super
    if params[:bank_payment_request][:payments_attributes].blank?
      add_message :error, "Missing payment details, try again"
      return
    end
  end

  def init
    super
    self.order_params = payment_order_params
  end

  def validate
    self.requested_total = 0
    params[:bank_payment_request][:payments_attributes].each do |details|
      self.requested_total += details[:amount]&.to_f
    end
    adapter = nil
    case payment_order.initiating_account_type
      when "VendorPaymentWallet"
        adapter = AccountManager::BankWallet::VendorPaymentWalletAdapter.new(payment_order.payments.first.initiating_account)
      when "YesBankCompanyAccount"
        adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
    end
    if requested_total > adapter.balance
      add_message :error, "Amount being requested is greater than the source account's balance"
      return
    end
  end

  def pre_process
    # nothing to do here, I guess?
  end

  def process
    unless payment_order.update(order_params)
      add_message :error, payment_order.errors.full_messages
    end
    payment_order.amount_requested.update(value: requested_total)
  end

  def post_process

  end

  private

  def payment_order_params
    p = {}
    p = params.require(:bank_payment_request).permit(payments_attributes: [:bank_account_number, :ifsc, :amount, :name, :id])
    p[:payments_attributes].each do |account_details|
      bank_account = BankAccount.with_company(user.company_id).find_by(account_number: account_details[:bank_account_number])
      vendor = bank_account&.account_owner || YesBankVendor.find_or_create_by(name: account_details[:name], company_id: user.company_id)
      if bank_account.nil?
        bank_account = BankAccount.create(name: account_details[:name], account_number: account_details[:bank_account_number], ifsc: account_details[:ifsc], account_owner: vendor, company_id: user.company_id)
      end
      account_details.delete(:bank_account_number)
      account_details.delete(:ifsc)
      account_details.delete(:name)
      # changing the receiving account to the newly created account or the old one itself
      account_details[:receiving_account_id] = bank_account.id
      account_details[:receiving_user_id] = vendor.id
      account_details[:receiving_user_type] = vendor.class.name
      account_details[:amount_attributes] = {
          value: account_details[:amount],
          currency_id: Currency.first.id
      }
      account_details.delete(:amount)

    end
    p.permit!
  end
end
