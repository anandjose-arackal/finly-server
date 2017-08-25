class BankTransfer::PaymentRequest::Update::UpdatePayments < BankTransfer::PaymentRequest::Update::Base

  attr_accessor :order_params

  def pre_validate

  end

  def init
    super
    self.order_params = payment_order_params
  end

  def pre_process
    # nothing to do here, I guess?
  end

  def process
    unless payment_order.update(order_params)
      add_message :error, payment_order_params.errors.full_messages
    end
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
        bank_account = BankAccount.create(name: account_details[:name], account_number: account_number, ifsc: ifsc, account_owner: vendor, company_id: user.company_id)
      end
      account_details.delete(:bank_account_number)
      account_details.delete(:ifsc)
      account_details.delete(:name)
      # changing the receiving account to the newly created account or the old one itself
      account_details[:receiving_account_id] = bank_account.id
      account_details[:amount_attributes] = {
          value: account_details[:amount],
          currency_id: Currency.first.id
      }
    end
    p
  end
end
