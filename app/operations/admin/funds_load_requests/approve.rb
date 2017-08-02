class Admin::FundsLoadRequests::Approve < Admin::Base
  attr_accessor :funds_load_request, :payment_request, :company

  def init
    self.funds_load_request = CompanyFundsLoadRequest.find(params[:id])
    unless funds_load_request.present?
      add_message :error, "Company Funds Load Request Not Found"
      return
    end
    self.company = funds_load_request.company

  end

  def process
    # Add Company Balance for the particular company
    self.payment_request = PaymentRequest.(user, nil, company.yes_bank_company_account.class.name, :credit, :corporate_balance_load)
    self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(nil, receiving_account, self.funds_load_request.amount.value))

    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request})
    unless op.success?
      # op.payment_order.destroy
      add_message :error, op.messages[:error]
    else
      self.funds_load_request.update(is_active: false)
      add_message :success, 'Successfully added balance for Company'
    end
  end
end
