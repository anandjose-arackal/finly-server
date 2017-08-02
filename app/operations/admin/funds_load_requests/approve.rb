class Admin::FundsLoadRequests::Approve < Admin::Base
  attr_accessor :funds_load_request, :payment_request, :company

  def init
    self.funds_load_request = CompanyFundsLoadRequest.find(params[:id])
    unless funds_load_request.present?
      add_message :error, "Company Funds Load Request Not Found"
      return
    end
    self.company = funds_load_request.company

    self.payment_request = PaymentRequest.new
  end

  def process
    # Add Company Balance for the particular company

    self.payment_request.initiating_user_id = user.id
    self.payment_request.company_id = funds_load_request.company_id
    self.payment_request.payment_order_type_id = PaymentOrderType.id_for(:outside_finly)
    self.payment_request.scheduled_at = Date.today
    self.payment_request.synchronous = true
    self.payment_request.payment_items = [
        {
            receiving_account_id: company.yes_bank_company_account.id,
            receiving_account_type: company.yes_bank_company_account.class.to_s,
            payment_type_id: PaymentType.id_for(:credit),
            payment_purpose_id: PaymentPurpose.id_for(:fund_transfer_outside_finly),
            date: Date.today,
            amount_attributes: {
                value: funds_load_request.amount.value,
                currency_id: Currency.id_for(:INR)
            }
        }
    ]

    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request, company_id: company&.id})
    unless op.success?
      # op.payment_order.destroy
      add_message :error, op.messages[:error]
    else
      self.funds_load_request.update(is_active: false)
      add_message :success, "Successfully added balance for Company"
    end
  end
end